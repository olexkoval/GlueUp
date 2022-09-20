//
//  MovieDetailsViewModel.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 17.09.2022.
//


protocol MovieDetailsViewModel: MovieItemViewModel {}

class MovieDetailsViewModelImpl: MovieItemViewModelImpl, MovieDetailsViewModel {
  override var id: String { "ID: \(super.id)" }
  
  override var voteCount: String { "Votes Count: \(super.voteCount)" }
  
  override var releaseDate: String { "Release Date: \(super.releaseDate)" }
}


