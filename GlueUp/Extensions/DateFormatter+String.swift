//
//  DateFormatter+String.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 17.09.2022.
//

import Foundation

extension DateFormatter {
  class func sting(_ date: Date) -> String {
    dateFormatter.string(from: date)
  }
  
  class func date(_ string: String) -> Date? {
    dateFormatter.date(from: string)
  }
}

private extension DateFormatter {
  private class var dateFormatter: DateFormatter {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    return dateFormatter
  }
}


