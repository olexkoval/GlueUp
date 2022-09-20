//
//  MovieNetwork.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 15.09.2022.
//

import Combine
import JLTMDbClient

enum MovieNetworkError: Error {
  case url(Error)
  case urlRequest
  case decode
}

protocol MovieNetwork {
  func load(page: Int) -> AnyPublisher<[MovieItemDTO], MovieNetworkError>
}

final class MovieNetworkImpl {}

extension MovieNetworkImpl: MovieNetwork {
  
  func load(page: Int) -> AnyPublisher<[MovieItemDTO], MovieNetworkError> {
    var dataTask: URLSessionDataTask?
    
    let onSubscription: (Subscription) -> Void = { _ in dataTask?.resume() }
    let onCancel: () -> Void = { dataTask?.cancel() }
    
    return Future<[MovieItemDTO], MovieNetworkError> { [weak self] promise in
      guard let urlRequest = self?.getUrlRequest(page: page) else {
        promise(.failure(MovieNetworkError.urlRequest))
        return
      }
      
      dataTask = URLSession.shared.dataTask(with: urlRequest) { (data, _, error) in
        guard let data = data else {
          if let error = error {
            promise(.failure(MovieNetworkError.url(error)))
          }
          return
        }
        do {
          let movies = try JSONDecoder().decode(MoviesData.self, from: data)
          promise(.success(movies.results))
        } catch {
          promise(.failure(MovieNetworkError.decode))
        }
      }
    }
    .handleEvents(receiveSubscription: onSubscription, receiveCancel: onCancel)
    .eraseToAnyPublisher()
  }
}

private extension MovieNetworkImpl {
  
  func getUrlRequest(page: Int) -> URLRequest? {
    
    if page > C.maxPagesCount || page < C.minPage {
      return nil
    }
    
#if DEBUG
    let scheme = kJLTMDbAPINoSSL
#else
    let scheme = kJLTMDbAPISSL
#endif
    let urlString = scheme + kJLTMDbAPIBaseURL + kJLTMDbAPIVersion + kJLTMDbMoviePopular
    guard let baseURL = URL(string: urlString),
          var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else { return nil }
    
    let apiKeyQuery = URLQueryItem(name: C.apiKeyQuery, value: C.apiValueQuery)
    let pageQuery = URLQueryItem(name: C.pageKeyQuery, value: String(page + 1))
    
    components.queryItems = [apiKeyQuery, pageQuery]
    guard let url = components.url else { return nil }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.timeoutInterval = C.timeoutInterval
    urlRequest.httpMethod = C.httpMethod
    
    return urlRequest
  }
  
  struct C {
    static let apiKeyQuery = "api_key"
    static let apiValueQuery = "be1eec9f57f124cd1f0a9ad37ecfd4db"
    static let pageKeyQuery = "page"
    static let httpMethod = "GET"
    static let timeoutInterval: TimeInterval = 10.0
    static let maxPagesCount = 999
    static let minPage = 0
  }
}
