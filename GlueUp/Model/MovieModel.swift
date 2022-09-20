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
  var publisher: AnyPublisher<[MovieItemDTO], MovieModelError> { get }
  
  func resetPublisher()
  func loadNextPage()
  func reloadData()
  func loadPesistentData() -> [MovieItemDTO]
  var pageNumber: Int { get }
}

final class MovieModelImpl {
  private let network: MovieNetwork
  private let translation: MovieTranslation
  private let database: MovieDatabase
  
  private var bindings = Set<AnyCancellable>()
  
  private var subject = PassthroughSubject<[MovieItemDTO], MovieModelError>()
  
  @Published private(set) var movies: [MovieItemDTO] = []
  
  init(network: MovieNetwork, translation: MovieTranslation, database: MovieDatabase) {
    self.network = network
    self.translation = translation
    self.database = database
    
    setupBindings()
  }
}

extension MovieModelImpl: MovieModel {
  
  func resetPublisher() {
    subject = PassthroughSubject<[MovieItemDTO], MovieModelError>()
  }
  
  var publisher: AnyPublisher<[MovieItemDTO], MovieModelError> {
    subject.eraseToAnyPublisher()
  }
  
  private(set) var pageNumber: Int {
    get { UserDefaults.standard.integer(forKey: C.pageNumberUserDefaultsKey) }
    set { UserDefaults.standard.set(newValue, forKey: C.pageNumberUserDefaultsKey) }
  }
  
  func loadNextPage() {
    network.load(page: pageNumber)
      .sink { [weak self] networkCompletion in
        guard let self = self else { return }
        switch networkCompletion {
        case .failure(let networkError):
          self.subject.send(completion: .failure(.networkError(networkError)))
        case .finished:
          break
        }
        
      } receiveValue: { [weak self] movies in
        guard let self = self else { return }
        self.database.save(dtos: movies, translation: self.translation, page: self.pageNumber)
        self.pageNumber += 1
      }.store(in: &bindings)
  }
  
  func reloadData() {
    self.database.reset()
    pageNumber = 0
  }
  
  func loadPesistentData() -> [MovieItemDTO] {
    translation.getMovieDTOs(from: database.fetchAllMovies())
  }
}

private extension MovieModelImpl {
  func setupBindings() {
    self.database.publisher.sink { [weak self] databaseCompletion in
      guard let self = self else { return }

      switch databaseCompletion {
      case .finished:
        break
      case .failure(let dbError):
        self.subject.send(completion: .failure(.databaseError(dbError)))
      }
    } receiveValue: { [weak self] movies in
      guard let self = self else { return }

      self.subject.send(self.translation.getMovieDTOs(from: movies))
    }.store(in: &bindings)
  }
}

private extension MovieModelImpl {
  struct C {
    static let pageNumberUserDefaultsKey = "PageNumber"
  }
}


