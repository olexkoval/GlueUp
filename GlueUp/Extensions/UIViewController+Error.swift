//
//  UIViewController+Error.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 18.09.2022.
//

import UIKit

extension UIViewController {
  
  func showError(_ error: Error) {
    let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
    let alertAction = UIAlertAction(title: "OK", style: .default) { [unowned self] _ in
      dismiss(animated: true, completion: nil)
    }
    alertController.addAction(alertAction)
    present(alertController, animated: true, completion: nil)
  }
  
}
