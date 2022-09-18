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
  func save(dtos: [MovieItemDTO], translation: MovieTranslation) -> AnyPublisher<[MovieMO], NSError>
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
  
  func save(dtos: [MovieItemDTO], translation: MovieTranslation) -> AnyPublisher<[MovieMO], NSError> {
    _ = translation.createMovies(from: dtos, with: backgroundContext)
    try! backgroundContext.save()
    
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
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = MovieMO.fetchRequest()
    let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
    
    try! persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: backgroundContext)
    backgroundContext.reset()
  }
  
  var fetchRequest: NSFetchRequest<MovieMO> {
    let sortOn = NSSortDescriptor(key: "id", ascending: true)
    
    let fetchRequest = MovieMO.fetchRequest()
    fetchRequest.sortDescriptors = [sortOn]
    
    return fetchRequest
  }
}
