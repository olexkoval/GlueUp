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
  func save(dtos: [MovieItemDTO], translation: MovieTranslation, page: Int)
  func reset()
  func fetchAllMovies() -> [MovieMO]
  
  var publisher: AnyPublisher<[MovieMO], NSError> { get }
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
  
  var publisher: AnyPublisher<[MovieMO], NSError> {
    FetchedResultsPublisher(request: fetchRequest, context: mainContext).eraseToAnyPublisher()
  }
  
  func save(dtos: [MovieItemDTO], translation: MovieTranslation, page: Int) {
    backgroundContext.perform { [weak self] in
      guard let self = self else { return }
      
      let movies = translation.createMovies(from: dtos, page: page, with: self.backgroundContext)
      movies.forEach { self.backgroundContext.insert($0) }
      try! self.backgroundContext.save()
    }
  }
  
  func reset() {
    backgroundContext.perform { [weak self] in
      guard let self = self else { return }
      
      let moviesToRemove = try! self.backgroundContext.fetch(self.fetchRequest)
      moviesToRemove.forEach { self.backgroundContext.delete($0) }
      try! self.backgroundContext.save()
    }
  }
  
  func fetchAllMovies() -> [MovieMO] {
    try! mainContext.fetch(fetchRequest)
  }
}

private extension MovieDatabaseImpl {
  var mainContext: NSManagedObjectContext {
    persistentContainer.viewContext
  }
  
  var fetchRequest: NSFetchRequest<MovieMO> {
    let sortOnId = NSSortDescriptor(key: "id", ascending: true)
    let sortOnPage = NSSortDescriptor(key: "page", ascending: true)
    
    let fetchRequest = MovieMO.fetchRequest()
    fetchRequest.sortDescriptors = [sortOnPage, sortOnId]
    
    return fetchRequest
  }
}
