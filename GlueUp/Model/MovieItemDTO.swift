//
//  MovieItemDTO.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 15.09.2022.
//

import Foundation

struct MoviesData: Decodable {
  let results: [MovieItemDTO]
}

struct MovieItemDTO {
  let id: Int64
  let title: String
  let releaseDate: Date
  let voteCount: Int32
  let overview: String
  let posterPath: String
}

extension MovieItemDTO: Equatable {
  static func ==(lhs: MovieItemDTO, rhs: MovieItemDTO) -> Bool { lhs.id == rhs.id }
}

extension MovieItemDTO: Hashable {
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
    hasher.combine(title)
    hasher.combine(releaseDate)
    hasher.combine(voteCount)
    hasher.combine(overview)
    hasher.combine(posterPath)
  }
}

extension MovieItemDTO: Decodable {
  enum CodingKeys: String, CodingKey {
    case id
    case title
    case vote_count
    case release_date
    case overview
    case poster_path
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    id = try container.decode(Int64.self, forKey: .id)
    title = try container.decode(String.self, forKey: .title)
    voteCount = try container.decode(Int32.self, forKey: .vote_count)
    let releaseDateString = try container.decode(String.self, forKey: .release_date)
    releaseDate = DateFormatter.date(releaseDateString) ?? Date.distantPast
    overview = try container.decode(String.self, forKey: .overview)
    posterPath = try container.decode(String.self, forKey: .poster_path)
  }
}
