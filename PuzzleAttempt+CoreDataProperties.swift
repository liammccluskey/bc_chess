//
//  PuzzleAttempt+CoreDataProperties.swift
//  
//
//  Created by Guest on 8/5/20.
//
//

import Foundation
import CoreData


extension PuzzleAttempt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PuzzleAttempt> {
        return NSFetchRequest<PuzzleAttempt>(entityName: "PuzzleAttempt")
    }

    @NSManaged public var wasCorrect: Bool
    @NSManaged public var newRating: Int32
    @NSManaged public var puzzleIndex: Int32
    @NSManaged public var puzzleType: Int32
    @NSManaged public var timestamp: Date?
    @NSManaged public var ratingDelta: Int32
    @NSManaged public var piecesHidden: Bool

}
