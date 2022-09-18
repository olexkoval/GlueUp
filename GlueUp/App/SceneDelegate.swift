//
//  SceneDelegate.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 08.09.2022.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  
  var window: UIWindow?
  var dependencyRegistry: DependencyRegistry!
  var coordinator: NavigationCoordinator!
  
  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else { return }
    
    dependencyRegistry = DependencyRegistryImpl()
    coordinator = dependencyRegistry.makeNavigationCoordinator()
    
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = UINavigationController(rootViewController: coordinator.rootViewController)
    window?.makeKeyAndVisible()
  }
  
}

