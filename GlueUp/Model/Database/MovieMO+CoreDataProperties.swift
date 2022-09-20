//
//  MovieMO+CoreDataProperties.swift
//  
//
//  Created by Oleksandr Koval on 15.09.2022.
//
//

import CoreData

extension MovieMO {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieMO> {
    NSFetchRequest<MovieMO>(entityName: "MovieMO")
  }
  
  @NSManaged public var id: Int64
  @NSManaged public var title: String
  @NSManaged public var releaseDate: Date
  @NSManaged public var voteCount: Int32
  @NSManaged public var overview: String
  @NSManaged public var page: Int16
  @NSManaged public var posterPath: String
  
}
