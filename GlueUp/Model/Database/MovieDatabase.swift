//
//  MovieDatabase.swift
//  GlueUp
//
//  Created by Oleksandr Koval on 15.09.2022.
//

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
  private var backgroundContext: NSManagedObjectContext!
  private let subject = PassthroughSubject<[MovieMO], NSError>()
  private var bindings = Set<AnyCancellable>()

  init() {
    persistentContainer = NSPersistentContainer(name: "GlueUp")
    setupStore()
    setupBindings()
  }
}

extension MovieDatabaseImpl: MovieDatabase {
  
  var publisher: AnyPublisher<[MovieMO], NSError> {
    subject.eraseToAnyPublisher()
  }
  
  func save(dtos: [MovieItemDTO], translation: MovieTranslation, page: Int) {
    backgroundContext.perform { [weak self] in
      guard let self = self else { return }
      
      let movies = translation.createMovies(from: dtos, page: page, with: self.backgroundContext)
      movies.forEach { self.backgroundContext.insert($0) }
      do { try self.backgroundContext.save() }
      catch {
        self.subject.send(completion: .failure(error as NSError))
      }
    }
  }
  
  func reset() {
    backgroundContext.perform { [weak self] in
      guard let self = self else { return }
      
      let moviesToRemove = try! self.backgroundContext.fetch(self.fetchRequest)
      moviesToRemove.forEach { self.backgroundContext.delete($0) }
      
      do { try self.backgroundContext.save() }
      catch {
        self.subject.send(completion: .failure(error as NSError))
      }
    }
  }
  
  func fetchAllMovies() -> [MovieMO] {
    let movies: [MovieMO]
    do { movies = try mainContext.fetch(fetchRequest) }
    catch {
      movies = [MovieMO]()
      subject.send(completion: .failure(error as NSError))
    }
    return movies
  }
}

private extension MovieDatabaseImpl {
  var mainContext: NSManagedObjectContext {
    persistentContainer.viewContext
  }
    
    func setupStore() {
        persistentContainer.loadPersistentStores(completionHandler: { [weak self] storeDescription, error in
          if let error = error as NSError? {
            self?.subject.send(completion: .failure(error))
          }
        })
      backgroundContext = persistentContainer.newBackgroundContext()
      persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
    }
  
  func setupBindings() {
    FetchedResultsPublisher(request: fetchRequest, context: mainContext)
      .sink { [weak self] in self?.subject.send(completion: $0) }
      receiveValue: { [weak self] in self?.subject.send($0) }
      .store(in: &bindings)
  }
  
  var fetchRequest: NSFetchRequest<MovieMO> {
    let sortOnId = NSSortDescriptor(key: "id", ascending: true)
    let sortOnPage = NSSortDescriptor(key: "page", ascending: true)
    
    let fetchRequest = MovieMO.fetchRequest()
    fetchRequest.sortDescriptors = [sortOnPage, sortOnId]
    
    return fetchRequest
  }
}
