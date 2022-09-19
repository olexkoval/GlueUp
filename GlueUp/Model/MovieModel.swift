//
//  MovieModel.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 15.09.2022.
//

import Foundation
import Combine

enum MovieModelError: Error {
  case networkError(MovieNetworkError)
  case databaseError(NSError)
}

protocol MovieModel {
  func loadNextPage() -> AnyPublisher<[MovieItemDTO], MovieModelError>
  func reloadData() -> AnyPublisher<[MovieItemDTO], MovieModelError>
  func loadPesistentData() -> [MovieItemDTO]
  var pageNumber: Int { get }
}

final class MovieModelImpl {
  private let network: MovieNetwork
  private let translation: MovieTranslation
  private let database: MovieDatabase
  
  private var bindings = Set<AnyCancellable>()
  
  @Published private(set) var movies: [MovieItemDTO] = []
  
  init(network: MovieNetwork, translation: MovieTranslation, database: MovieDatabase) {
    self.network = network
    self.translation = translation
    self.database = database
  }
}

extension MovieModelImpl: MovieModel {
  
  private(set) var pageNumber: Int {
    get { UserDefaults.standard.integer(forKey: C.pageNumberUserDefaultsKey) }
    set { UserDefaults.standard.set(newValue, forKey: C.pageNumberUserDefaultsKey) }
  }
  
  func loadNextPage() -> AnyPublisher<[MovieItemDTO], MovieModelError> {

    return Future<[MovieItemDTO], MovieModelError> { [unowned self] promise in
      self.network.load(page: self.pageNumber)
        .sink { networkCompletion in
          switch networkCompletion {

          case .failure(let networkError):
            promise(.failure(MovieModelError.networkError(networkError)))
          case .finished:
            self.pageNumber += 1
            break
          }
        } receiveValue: { [unowned self] movieDTOs in

          var dbSubscription: AnyCancellable?
          dbSubscription = self.database.save(dtos: movieDTOs, translation: self.translation, page: self.pageNumber)
            .sink { databaseCompletion in
              switch databaseCompletion {
              case .failure(let databaseError):
                promise(.failure(MovieModelError.databaseError(databaseError)))
              case .finished:
              }
            } receiveValue: { [unowned self] movies in
              if movies.count == 0 { return }
              dbSubscription?.cancel()
              promise(.success(self.translation.getMovieDTOs(from: movies)))
            }
            dbSubscription?.store(in: &bindings)
        }.store(in: &bindings)
    }.eraseToAnyPublisher()
  }
  
  func reloadData() -> AnyPublisher<[MovieItemDTO], MovieModelError> {
    return Future<[MovieItemDTO], MovieModelError> { [unowned self] promise in
      var dbSubscription: AnyCancellable?
      dbSubscription = self.database.reset()
        .sink { resetCompletion in
          switch resetCompletion {
          case .failure(let databaseError):
            promise(.failure(MovieModelError.databaseError(databaseError)))
          case .finished:
            break
          }
        } receiveValue: { [unowned self] movies in
          dbSubscription?.cancel()
          self.pageNumber = 0
          promise(.success([MovieItemDTO]()))
        }
      dbSubscription?.store(in: &bindings)
    }.eraseToAnyPublisher()
  }
  
  func loadPesistentData() -> [MovieItemDTO] {
    translation.getMovieDTOs(from: database.fetchAllMovies())
  }
}

private extension MovieModelImpl {
  struct C {
    static let pageNumberUserDefaultsKey = "PageNumber"
  }
}


