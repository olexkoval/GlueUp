//
//  ViewController.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 08.09.2022.
//

import UIKit
import Combine

final class MovieListViewController: UITableViewController {
  
  private typealias MoviesDataSource = UITableViewDiffableDataSource<MovieListViewModelSection, MovieItemDTO>
  private typealias MoviesSnapshot = NSDiffableDataSourceSnapshot<MovieListViewModelSection, MovieItemDTO>
  
  private let viewModel: MovieListViewModel
  weak var navigationCoordinator: NavigationCoordinator?
  private var movieCellMaker: DependencyRegistry.MovieCellMaker!
  
  private var bindings = Set<AnyCancellable>()
  
  private var dataSource: MoviesDataSource!
  
  init(viewModel: MovieListViewModel,
       navigationCoordinator: NavigationCoordinator,
       movieCellMaker: @escaping DependencyRegistry.MovieCellMaker) {
    
    self.viewModel = viewModel
    self.navigationCoordinator = navigationCoordinator
    self.movieCellMaker = movieCellMaker
    
    super.init(nibName: nil, bundle: nil)
    
    dataSource = MoviesDataSource(tableView: tableView, cellProvider: self.movieCellMaker)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(MovieTableViewCell.self, forCellReuseIdentifier: MovieTableViewCell.identifier)
    configRefreshControl()
    bindViewModelToView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if viewModel.hasLoadedData {
      viewModel.loadPersitentData()
    } else {
      viewModel.loadNextPage()
    }
  }
  
  private func configRefreshControl() {
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
  }
  
  private func bindViewModelToView() {
    viewModel.moviesPublisher
      .receive(on: RunLoop.main)
      .sink(receiveValue: { [weak self] _ in
        self?.updateSections()
      })
      .store(in: &bindings)
    
    let stateValueHandler: (MovieListViewModelState) -> Void = { [weak self] state in
      switch state {
      case .loading:
        self?.refreshControl?.beginRefreshing()
      case .finishedLoading:
        self?.refreshControl?.endRefreshing()
      case .error(let error):
        self?.refreshControl?.endRefreshing()
        self?.showError(error)
      }
    }
    
    viewModel.loadingStatePublisher
      .receive(on: RunLoop.main)
      .sink(receiveValue: stateValueHandler)
      .store(in: &bindings)
  }
  
  private func showError(_ error: Error) {
    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
      self.dismiss(animated: true, completion: nil)
    }
    alertController.addAction(alertAction)
    present(alertController, animated: true, completion: nil)
  }
  
  private func updateSections() {
    var snapshot = MoviesSnapshot()
    snapshot.appendSections([.movies])
    snapshot.appendItems(viewModel.movies)
    dataSource.apply(snapshot, animatingDifferences: true)
  }
  
  @objc private func refresh() {
    viewModel.reloadData()
  }
}
