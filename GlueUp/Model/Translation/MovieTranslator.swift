//
//  MovieTranslator.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 15.09.2022.
//

import Foundation
import CoreData

protocol MovieTranslator {
  func translate(from movie: MovieMO?) -> MovieItemDTO?
  func translate(from dto: MovieItemDTO?, page: Int, with context: NSManagedObjectContext) -> MovieMO?
}

final class MovieTranslatorImpl: MovieTranslator {
  
  func translate(from movie: MovieMO?) -> MovieItemDTO? {
    guard let movie = movie else { return nil }
    
    return MovieItemDTO(id: movie.id,
                        title: movie.title,
                        releaseDate: movie.releaseDate,
                        voteCount: movie.voteCount,
                        overview: movie.overview,
                        posterPath: movie.posterPath)
  }
  
  func translate(from dto: MovieItemDTO?, page: Int, with context: NSManagedObjectContext) -> MovieMO? {
    guard let dto = dto else { return nil }
    
    let movie = MovieMO(context: context)
    
    movie.id = dto.id
    movie.title = dto.title
    movie.releaseDate = dto.releaseDate
    movie.voteCount = dto.voteCount
    movie.overview = dto.overview
    movie.posterPath = dto.posterPath

    movie.page = page
    
    return movie
  }
}
