//
//  Logger.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 19.09.2022.
//

import Foundation


final class Logger {
  class func log(_ this: String, _ action: String) {
    
    let thisLength = this.count
    let firstMaxLength = 30
    let firstDiff = firstMaxLength - thisLength
    var firstSection = "AAAA - \(this)"
    for _ in 0...firstDiff {
      firstSection += " "
    }
    let actionLength = action.count
    let secondMaxLength = 60
    let secondDiff = secondMaxLength - actionLength
    var secondSection = action
    
    for _ in 0...secondDiff {
      secondSection += " "
    }
    print("\(firstSection)|\(secondSection)| \(Thread.current.isMainThread ? "M" : "B")")
  }
}
