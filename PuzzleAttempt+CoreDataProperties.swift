//
//  PuzzleAttempt+CoreDataProperties.swift
//  BCPtest
//
//  Created by Guest on 8/7/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//
//

import Foundation
import CoreData


extension PuzzleAttempt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PuzzleAttempt> {
        return NSFetchRequest<PuzzleAttempt>(entityName: "PuzzleAttempt")
    }

    @NSManaged public var newRating: Int32
    @NSManaged public var piecesHidden: Bool
    @NSManaged public var puzzleIndex: Int32
    @NSManaged public var puzzleType: Int32
    @NSManaged public var ratingDelta: Int32
    @NSManaged public var timestamp: Date?
    @NSManaged public var wasCorrect: Bool

}
