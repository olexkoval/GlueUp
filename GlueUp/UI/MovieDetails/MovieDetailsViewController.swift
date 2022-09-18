//
//  MovieDetailsViewController.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 17.09.2022.
//

import UIKit

class MovieDetailsViewController: UIViewController {
  private let viewModel: MovieDetailsViewModel
  private weak var navigationCoordinator: NavigationCoordinator?
  
  init(viewModel: MovieDetailsViewModel, navigationCoordinator: NavigationCoordinator) {
    self.viewModel = viewModel
    self.navigationCoordinator = navigationCoordinator
    
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      
      navigationCoordinator?.movingBack()
  }
}
