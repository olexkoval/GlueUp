//
//  MoviePosterLoader.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 18.09.2022.
//

import Foundation
import Combine
import JLTMDbClient

protocol MoviePosterLoader {
  func loadMoviePosterImage(movie: MovieItemDTO) -> AnyPublisher<UIImage, MovieNetworkError>
}

final class MoviePosterLoaderImpl {
  let imageCache = NSCache<NSString, AnyObject>()
}

extension MoviePosterLoaderImpl: MoviePosterLoader {
  func loadMoviePosterImage(movie: MovieItemDTO) -> AnyPublisher<UIImage, MovieNetworkError> {
    var dataTask: URLSessionDataTask?
    
    let onSubscription: (Subscription) -> Void = { _ in dataTask?.resume() }
    let onCancel: () -> Void = { dataTask?.cancel() }
    
    return Future<UIImage, MovieNetworkError> { [weak self] promise in
      guard let urlRequest = self?.getMoviePosterUrlRequest(posterId: movie.posterPath) else {
        promise(.failure(MovieNetworkError.urlRequest))
        return
      }
      
      if let cachedImage = self?.imageCache.object(forKey: urlRequest.url!.absoluteString as NSString) as? UIImage {
        promise(.success(cachedImage))
        return
      }
      
      dataTask = URLSession.shared.dataTask(with: urlRequest) { [weak self] (data, response, error) in
        guard let data = data else {
          if let error = error {
            promise(.failure(MovieNetworkError.url(error)))
          }
          return
        }
        if let image = UIImage(data: data) {
          self?.imageCache.setObject(image, forKey: response!.url!.absoluteString as NSString)
          promise(.success(image))

        } else {
          promise(.failure(MovieNetworkError.decode))
        }

      }
    }
    .handleEvents(receiveSubscription: onSubscription, receiveCancel: onCancel)
    .receive(on: DispatchQueue.main)
    .eraseToAnyPublisher()
  }
}

private extension MoviePosterLoaderImpl {
  func getMoviePosterUrlRequest(posterId: String) -> URLRequest? {
#if DEBUG
    let scheme = kJLTMDbAPINoSSL
#else
    let scheme = kJLTMDbAPISSL
#endif
    let urlString = scheme + C.moviePosterLoadingBaseURL + posterId
    guard let baseURL = URL(string: urlString) else { return nil }
    
    var urlRequest = URLRequest(url: baseURL)
    urlRequest.timeoutInterval = C.timeoutInterval
    urlRequest.httpMethod = C.httpMethod
    
    return urlRequest
  }
  
  struct C {
    static let httpMethod = "GET"
    static let timeoutInterval: TimeInterval = 10.0
    static let maxPagesCount = 1000
    static let minPage = 1
    static let  moviePosterLoadingBaseURL = "://image.tmdb.org/t/p/w500/";
  }
}
