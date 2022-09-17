//
//  SceneDelegate.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 08.09.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    
    guard let windowScene = scene as? UIWindowScene else { return }
    
    let db = MovieDatabaseImpl()
    let ntw = MovieNetworkImpl()
    let tr = MovieTranslatorImpl()
    let trn = MovieTranslationImpl(translator: tr)
    let mdl = MovieModelImpl(network: ntw, translation: trn, database: db)
    let vm = MovieListViewModelImpl(model: mdl)
    
    let vc = MovieListViewController(viewModel: vm)
    
    let window = UIWindow(windowScene: windowScene)
    window.rootViewController = UINavigationController(rootViewController: vc)
    self.window = window
    window.makeKeyAndVisible()
  }
  
}

