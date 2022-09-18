//
//  MovieErrorHandler.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 18.09.2022.
//

import Foundation

protocol MovieErrorHandler {
  func handleMovieFetch(error: MovieModelError) -> NSError
}

final class MovieErrorHandlerImpl: MovieErrorHandler {
  
  func handleMovieFetch(error: MovieModelError) -> NSError {
    
    let errorCode: Int
    let domain: String
    var userInfo: [String : Any]?
    switch error {
      
    case .networkError(let networkError):
      domain = C.networkErrorDomain
      let description: String
      switch networkError {
        
      case .url(let urlError):
        errorCode = C.networkErrorUrlCode
        description = urlError.localizedDescription
      case .decode:
        errorCode = C.networkErrorDecodeCode
        description = C.networkErrorDecodeMessage
      case .urlRequest:
        errorCode = C.networkErrorRequestCode
        description = C.networkErrorRequestMessage
      }
      userInfo = [NSLocalizedDescriptionKey : description]
    case .databaseError(let databaseError):
      errorCode = databaseError.code
      domain = databaseError.domain
      userInfo = databaseError.userInfo
    }
    
    return NSError(domain: domain, code: errorCode, userInfo: userInfo)
  }
}

private extension MovieErrorHandlerImpl {
  struct C {
    static let networkErrorDomain = "com.okoval.GlueUp.networkError"
    static let networkErrorUrlCode = 1000001
    static let networkErrorDecodeCode = 1000002
    static let networkErrorDecodeMessage = "JSON serialization failed"
    static let networkErrorRequestCode = 1000003
    static let networkErrorRequestMessage = "Bad Request. Check page number."
  }
}
