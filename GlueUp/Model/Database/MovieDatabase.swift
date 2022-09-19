//
//  MovieDatabase.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 15.09.2022.
//

import Foundation
import CoreData
import Combine

protocol MovieDatabase {
  func save(dtos: [MovieItemDTO], translation: MovieTranslation, page: Int) -> AnyPublisher<[MovieMO], NSError>
  func reset() -> AnyPublisher<[MovieMO], NSError>
  func fetchAllMovies() -> [MovieMO]
}

final class MovieDatabaseImpl {
  
  private let persistentContainer: NSPersistentContainer
  private let backgroundContext: NSManagedObjectContext
  
  init() {
    persistentContainer = NSPersistentContainer(name: "GlueUp")
    persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    persistentContainer.loadPersistentStores(completionHandler: { storeDescription, error in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    backgroundContext = persistentContainer.newBackgroundContext()
  }
}

extension MovieDatabaseImpl: MovieDatabase {
  
  func save(dtos: [MovieItemDTO], translation: MovieTranslation, page: Int) -> AnyPublisher<[MovieMO], NSError> {
    backgroundContext.perform { [weak self] in
      guard let self = self else { return }
      
      let movies = translation.createMovies(from: dtos, page: page, with: self.backgroundContext)
      movies.forEach { self.backgroundContext.insert($0) }
      try! self.backgroundContext.save()
    }
    return FetchedResultsPublisher(request: fetchRequest, context: mainContext).eraseToAnyPublisher()
  }
  
  func reset() -> AnyPublisher<[MovieMO], NSError> {
    clearAllResults()
    return FetchedResultsPublisher(request: fetchRequest, context: mainContext).eraseToAnyPublisher()
  }
  
  func fetchAllMovies() -> [MovieMO] {
    try! mainContext.fetch(fetchRequest)
  }
}

private extension MovieDatabaseImpl {
  var mainContext: NSManagedObjectContext {
    persistentContainer.viewContext
  }
  
  func clearAllResults() {
    backgroundContext.perform { [weak self] in
      let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MovieMO.fetchRequest()
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
      try! self?.backgroundContext.execute(deleteRequest)
      try! self?.backgroundContext.save()
    }
  }
  
  var fetchRequest: NSFetchRequest<MovieMO> {
    let sortOnId = NSSortDescriptor(key: "id", ascending: true)
    let sortOnPage = NSSortDescriptor(key: "page", ascending: true)

    let fetchRequest = MovieMO.fetchRequest()
    fetchRequest.sortDescriptors = [sortOnPage, sortOnId]
    
    return fetchRequest
  }
}
