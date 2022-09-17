//
//  MovieTranslation.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 15.09.2022.
//

import Foundation
import CoreData

protocol MovieTranslation {
  func createMovies(from dtos: [MovieItemDTO], with context: NSManagedObjectContext) -> [MovieMO]
  func getMovieDTOs(from movies:[MovieMO]) -> [MovieItemDTO]
}

final class MovieTranslationImpl: MovieTranslation {
  private let translator: MovieTranslator
  
  init(translator: MovieTranslator) {
    self.translator = translator
  }
  
  func createMovies(from dtos: [MovieItemDTO], with context: NSManagedObjectContext) -> [MovieMO] {
    dtos.compactMap { translator.translate(from: $0, with: context) }
  }
  
  func getMovieDTOs(from movies: [MovieMO]) -> [MovieItemDTO] {
    movies.compactMap { translator.translate(from: $0) }
  }
}
