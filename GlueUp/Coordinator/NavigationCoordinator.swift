//
//  NavigationCoordinator.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 17.09.2022.
//

import UIKit

protocol NavigationCoordinator: AnyObject {
  var rootViewController: UIViewController { get }
  func next(arguments: Dictionary<String, Any>?)
  func movingBack()
}

enum NavigationState {
  case atMoviesList,
       atMovieDetails
}

final class NavigationCoordinatorImpl: NavigationCoordinator {
  
  private(set) weak var registry: DependencyRegistry?
  let rootViewController: UIViewController
  
  var navState: NavigationState = .atMoviesList
  
  init(rootViewController: UIViewController, registry: DependencyRegistry) {
    self.rootViewController = rootViewController
    self.registry = registry
  }
  
  func movingBack() {
    switch navState {
    case .atMoviesList:
      break
    case .atMovieDetails:
      navState = .atMoviesList
    }
  }
  
  func next(arguments: Dictionary<String, Any>?) {
    switch navState {
    case .atMoviesList:
      showDetails(arguments: arguments)
    case .atMovieDetails:
      break
    }
  }
  
  private func showDetails(arguments: Dictionary<String, Any>?) {
    guard let movie = arguments?["movie"] as? MovieItemDTO,
          let detailViewController = registry?.makeMovieDetailsViewController(movie: movie) else { return }
        
    rootViewController.navigationController?.pushViewController(detailViewController, animated: true)
    navState = .atMovieDetails
  }
  
  private func showMoviesList() {
    rootViewController.navigationController?.popToRootViewController(animated: true)
    navState = .atMoviesList
  }
}
