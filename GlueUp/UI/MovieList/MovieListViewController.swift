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
  private let movieCellMaker: DependencyRegistry.MovieCellMaker
  
  private var bindings = Set<AnyCancellable>()  
  private var dataSource: MoviesDataSource!
  private var initialDataRequested = false
  private var activityIndicator: UIActivityIndicatorView!
  
  init(viewModel: MovieListViewModel,
       navigationCoordinator: NavigationCoordinator?,
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
    
    configActivityIndicator()
    configRefreshControl()
    bindViewModelToView()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if !initialDataRequested {
      if viewModel.hasLoadedData {
        viewModel.loadPersitentData()
      } else {
        startLoading(with: { viewModel.loadNextPage() })
      }
      initialDataRequested = true
    }
  }
  
  override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let bottomEdge = scrollView.contentOffset.y + scrollView.frame.size.height
    if bottomEdge >= scrollView.contentSize.height {
      tableLastItemReached()
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let movie = viewModel.movies[indexPath.row]
    let args = ["movie": movie]
    navigationCoordinator?.next(arguments: args)
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let cell = cell as? MovieTableViewCell else { return }
    
    cell.willAppear()
  }
  
  override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard let cell = cell as? MovieTableViewCell else { return }

    cell.didDisappear()
  }
  
  private func configRefreshControl() {
    refreshControl = UIRefreshControl()
    refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
  }
  
  private func configActivityIndicator() {
    activityIndicator = UIActivityIndicatorView(style: .large)
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    self.view.addSubview(activityIndicator)
    NSLayoutConstraint.activate([
      activityIndicator.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
      activityIndicator.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor)
    ])
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
        if !(self?.refreshControl?.isRefreshing ?? false) {
          self?.activityIndicator.startAnimating()
        }
      case .finishedLoading:
        self?.finishedLoading()
      case .error(let error):
        self?.finishedLoading()
        self?.showError(error)
      }
    }
    
    viewModel.loadingStatePublisher
      .receive(on: RunLoop.main)
      .sink(receiveValue: stateValueHandler)
      .store(in: &bindings)
  }
  
  private func tableLastItemReached() {
    startLoading(with: { viewModel.loadNextPage() })
  }
  
  private func startLoading(with action:(() -> Void)) {
    view.isUserInteractionEnabled = false
    if !(refreshControl?.isRefreshing ?? false) {
      activityIndicator.startAnimating()
    }
    action()
  }
  
  private func finishedLoading() {
    view.isUserInteractionEnabled = true
    refreshControl?.endRefreshing()
    activityIndicator.stopAnimating()
  }
  
  private func updateSections() {
    var snapshot = MoviesSnapshot()
    snapshot.appendSections([.movies])
    snapshot.appendItems(viewModel.movies)
    dataSource.apply(snapshot, animatingDifferences: true)
  }
  
  @objc private func refresh() {
    startLoading(with: { viewModel.reloadData() })
  }
}
