//
//  TMDBConstants.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 21.09.2022.
//

import Foundation

struct TMDBConstants {
#if DEBUG
    static let apiScheme = "https"
#else
    static let apiScheme = "http"
#endif
    static let apiPopularMovieQuery = "movie/popular"
    static let apiPosterLoadingBaseURL = "://image.tmdb.org/t/p/w500/";
    static let apiVersion = "3/"
    static let apiBaseURL = "://api.themoviedb.org/"
    static let apiKeyQuery = "api_key"
    static let apiLoacalKey = "TMDB_API_KEY"
    static let pageKeyQuery = "page"
    static let httpMethod = "GET"
    static let timeoutInterval: TimeInterval = 10.0
    static let maxPagesCount = 999
    static let minPage = 0
}
