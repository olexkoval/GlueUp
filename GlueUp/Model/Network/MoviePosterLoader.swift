//
//  MoviePosterLoader.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 18.09.2022.
//

import Combine
import UIKit

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
          promise(.failure((error != nil) ? .url(error!) : .urlRequest))
          return
        }
        if let image = UIImage(data: data) {
          self?.imageCache.setObject(image, forKey: response!.url!.absoluteString as NSString)
          promise(.success(image))
          
        } else {
          promise(.failure(.decode))
        }
      }
    }
    .handleEvents(receiveSubscription: onSubscription, receiveCancel: onCancel)
    .eraseToAnyPublisher()
  }
}

private extension MoviePosterLoaderImpl {
  func getMoviePosterUrlRequest(posterId: String) -> URLRequest? {
    let urlString = TMDBConstants.apiScheme + TMDBConstants.apiPosterLoadingBaseURL + posterId
    guard let baseURL = URL(string: urlString) else { return nil }
    
    var urlRequest = URLRequest(url: baseURL)
    urlRequest.timeoutInterval = TMDBConstants.timeoutInterval
    urlRequest.httpMethod = TMDBConstants.httpMethod
    
    return urlRequest
  }
}
