//
//  MovieListViewModel.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 16.09.2022.
//

import Foundation
import Combine

enum MovieListViewModelError: Error, Equatable {
  case moviesFetch
}

enum MovieListViewModelState: Equatable {
  case loading
  case finishedLoading
  case error(MovieListViewModelError)
}

protocol MovieListViewModel {
  var movies: [MovieItemDTO] { get }
  var hasLoadedData: Bool { get }
  
  var moviesPublisher: Published<[MovieItemDTO]>.Publisher { get }
  var loadingStatePublisher: Published<MovieListViewModelState>.Publisher { get }
  
  func loadNextPage()
  func loadPersitentData()
  func reloadData()
}

enum MovieListViewModelSection { case movies }

final class MovieListViewModelImpl {
  
  @Published private(set) var movies: [MovieItemDTO] = []
  @Published private(set) var state: MovieListViewModelState = .loading
  
  private let model: MovieModel
  private var bindings = Set<AnyCancellable>()
  
  init(model: MovieModel) {
    self.model = model
  }
}

extension MovieListViewModelImpl: MovieListViewModel {
  
  var hasLoadedData: Bool { model.pageNumber > 0 }
  
  var moviesPublisher: Published<[MovieItemDTO]>.Publisher { $movies }
  var loadingStatePublisher: Published<MovieListViewModelState>.Publisher { $state }
  
  func loadNextPage() {
    state = .loading
    
    let loadMoviesCompletionHandler: (Subscribers.Completion<Error>) -> Void = { [weak self] completion in
      switch completion {
      case .failure:
        self?.state = .error(.moviesFetch)
      case .finished:
        self?.state = .finishedLoading
      }
    }
    
    let loadMoviesValueHandler: ([MovieItemDTO]) -> Void = { [weak self] movies in
      self?.movies = movies
    }
    
    model.loadNextPage()
      .sink(receiveCompletion: loadMoviesCompletionHandler, receiveValue: loadMoviesValueHandler)
      .store(in: &bindings)
  }
  
  func loadPersitentData() {
    movies = model.loadPesistentData()
  }
  
  func reloadData() {
    model.reloadData().sink { [unowned self] completion in
      switch completion {
      case .failure(_):
        //TODO: Handle
        break
      case .finished:
        loadNextPage()
      }
    } receiveValue: { _ in }
      .store(in: &bindings)
  }
}
