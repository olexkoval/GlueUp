//
//  MovieNetwork.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 15.09.2022.
//

import Foundation
import Combine

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
          promise(.failure((error != nil) ? .url(error!) : .urlRequest))
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
    
    if page > TMDBConstants.maxPagesCount || page < TMDBConstants.minPage {
      return nil
    }
    
    let urlString = TMDBConstants.apiScheme + TMDBConstants.apiBaseURL + TMDBConstants.apiVersion + TMDBConstants.apiPopularMovieQuery
    guard let baseURL = URL(string: urlString),
          var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else { return nil }
    let apiKey = Bundle.main.object(forInfoDictionaryKey: TMDBConstants.apiLoacalKey) as? String
    let apiKeyQuery = URLQueryItem(name: TMDBConstants.apiKeyQuery, value: apiKey)
    let pageQuery = URLQueryItem(name: TMDBConstants.pageKeyQuery, value: String(page + 1))
    
    components.queryItems = [apiKeyQuery, pageQuery]
    guard let url = components.url else { return nil }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.timeoutInterval = TMDBConstants.timeoutInterval
    urlRequest.httpMethod = TMDBConstants.httpMethod
    
    return urlRequest
  }
}
