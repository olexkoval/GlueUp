//
//  MovieCellViewModel.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 17.09.2022.
//

import Combine

protocol MovieCellViewModel: MovieItemViewModel {
  var movieTitle: String { get }
}

final class MovieCellViewModelImpl: MovieItemViewModelImpl, MovieCellViewModel {
  var movieTitle: String { super.title }
}
