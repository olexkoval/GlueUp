//
//  MovieListViewModel.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 16.09.2022.
//

import Foundation
import Combine

enum MovieListViewModelState: Equatable {
  case loading
  case finishedLoading
  case error(NSError)
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
  @Published private(set) var state: MovieListViewModelState = .finishedLoading
  
  private let model: MovieModel
  private let errorHandler: MovieErrorHandler

  private var bindings = Set<AnyCancellable>()
  private var subscription: AnyCancellable?
  
  init(model: MovieModel, errorHandler: MovieErrorHandler) {
    self.model = model
    self.errorHandler = errorHandler
    
    setupBindings()
  }
}

extension MovieListViewModelImpl: MovieListViewModel {
  
  var hasLoadedData: Bool { model.pageNumber > 0 }
  
  var moviesPublisher: Published<[MovieItemDTO]>.Publisher { $movies }
  var loadingStatePublisher: Published<MovieListViewModelState>.Publisher { $state }
  
  func loadNextPage() {
    
    if state == .loading { return }
    
    state = .loading
    model.loadNextPage()
  }
  
  func loadPersitentData() {
    movies = model.loadPesistentData()
  }
  
  func reloadData() {
    model.reloadData()
    loadNextPage()
  }
}

private extension MovieListViewModelImpl {
  func setupBindings() {
    subscription?.cancel()
    
    let loadMoviesCompletionHandler: (Subscribers.Completion<MovieModelError>) -> Void = { [weak self] completion in
      guard let self = self else { return }
      switch completion {
      case .failure(let modelError):
        self.state = .error(self.errorHandler.handleMovieFetch(error: modelError))
        self.model.resetPublisher()
        self.setupBindings()
      case .finished:
        self.state = .finishedLoading
      }
    }
    
    let loadMoviesValueHandler: ([MovieItemDTO]) -> Void = { [weak self] movies in
      self?.movies = movies
      self?.state = .finishedLoading
    }
    
    subscription = model.publisher.receive(on: RunLoop.main)
      .sink(receiveCompletion: loadMoviesCompletionHandler, receiveValue: loadMoviesValueHandler)
    
    subscription?.store(in: &bindings)
  }
}
