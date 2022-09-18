//
//  DependencyRegistry.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 17.09.2022.
//

import Foundation
import Swinject

protocol DependencyRegistry: AnyObject {
  
  typealias navigationCoordinatorMaker = () -> NavigationCoordinator
  func makeNavigationCoordinator() -> NavigationCoordinator
  
  typealias MovieCellMaker = (UITableView, IndexPath, MovieItemDTO) -> MovieTableViewCell
  func makeMovieCell(for tableView: UITableView, at indexPath: IndexPath, with movie: MovieItemDTO) -> MovieTableViewCell
  
  typealias MovieListViewControllerMaker = () -> MovieListViewController
  func makeMovieListViewController() -> MovieListViewController
  
  typealias MovieDetailsViewControllerMaker = (MovieItemDTO)  -> MovieDetailsViewController
  func makeMovieDetailsViewController(movie: MovieItemDTO) -> MovieDetailsViewController
}

final class DependencyRegistryImpl {
  
  private var container: Container
  
  init(container: Container = Container()) {
    
    Container.loggingFunction = nil
    
    self.container = container
    
    registerDependencies()
    registerViewModels()
    registerViewControllers()
  }
}

extension DependencyRegistryImpl: DependencyRegistry {
  
  func makeNavigationCoordinator() -> NavigationCoordinator {
    container.resolve(NavigationCoordinator.self)!
  }
  
  func makeMovieCell(for tableView: UITableView, at indexPath: IndexPath, with movie: MovieItemDTO) -> MovieTableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: MovieTableViewCell.identifier, for: indexPath) as! MovieTableViewCell
    cell.viewModel = container.resolve(MovieCellViewModel.self, argument: movie)!

    return cell
  }
  
  func makeMovieListViewController() -> MovieListViewController {
    container.resolve(MovieListViewController.self)!
  }

  func makeMovieDetailsViewController(movie: MovieItemDTO) -> MovieDetailsViewController {
    container.resolve(MovieDetailsViewController.self, argument: movie)!
  }
}

private extension DependencyRegistryImpl {
  
  func registerDependencies() {
    container.register(NavigationCoordinator.self) { [weak self] r in
      NavigationCoordinatorImpl(rootViewController: r.resolve(MovieListViewController.self)!, registry: self!)
    }.inObjectScope(.container)
    
    container.register(MovieErrorHandler.self) { _ in MovieErrorHandlerImpl() }.inObjectScope(.container)
    container.register(MovieNetwork.self) { _ in MovieNetworkImpl() }.inObjectScope(.container)
    container.register(MovieDatabase.self) { _ in MovieDatabaseImpl() }.inObjectScope(.container)
    container.register(MovieTranslator.self) { _ in MovieTranslatorImpl() }.inObjectScope(.container)
    container.register(MovieCellMaker.self) { [unowned self] _ in self.makeMovieCell }.inObjectScope(.container)

    container.register(MovieTranslation.self) { r in
      MovieTranslationImpl(translator: r.resolve(MovieTranslator.self)!)
    }.inObjectScope(.container)
    
    container.register(MovieModel.self){ r in
      MovieModelImpl(network: r.resolve(MovieNetwork.self)!,
                     translation: r.resolve(MovieTranslation.self)!,
                     database: r.resolve(MovieDatabase.self)!)
    }.inObjectScope(.container)
  }
  
  func registerViewModels() {
    container.register(MovieListViewModel.self) { r in MovieListViewModelImpl(model: r.resolve(MovieModel.self)!, errorHandler: r.resolve(MovieErrorHandler.self)!) }
    container.register( MovieDetailsViewModel.self) { (r, movie: MovieItemDTO) in MovieDetailsViewModelImpl(movie: movie) }
    container.register(MovieCellViewModel.self) { (r, movie: MovieItemDTO) in MovieCellViewModelImpl(movie: movie) }
  }
  
  func registerViewControllers() {
    
    container.register(MovieListViewController.self) { r in
      
      let viewModel = r.resolve(MovieListViewModel.self)!
      let movieCellMaker = r.resolve(MovieCellMaker.self)!
      
      return MovieListViewController(viewModel: viewModel, navigationCoordinator: nil, movieCellMaker: movieCellMaker) }
    
      .initCompleted{ r, vc in
        vc.navigationCoordinator = r.resolve(NavigationCoordinator.self)!
    }
    
    container.register(MovieDetailsViewController.self) { (r, movie: MovieItemDTO) in
      
      let viewModel = r.resolve(MovieDetailsViewModel.self, argument: movie)!
      let navigationCoordinator = r.resolve(NavigationCoordinator.self)!

      return MovieDetailsViewController(viewModel: viewModel, navigationCoordinator: navigationCoordinator)
    }
  }
}
