//
//  PuzzledUser+CoreDataProperties.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 8/15/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//
//

import Foundation
import CoreData


extension PuzzledUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PuzzledUser> {
        return NSFetchRequest<PuzzledUser>(entityName: "PuzzledUser")
    }

    @NSManaged public var numPuzzleAttempts: Double
    @NSManaged public var numPuzzleBAttempts: Double
    @NSManaged public var puzzle_Elo: Int32
    @NSManaged public var puzzleB_Elo: Int32
    @NSManaged public var registerTimestamp: Date?
    @NSManaged public var rush3_HS: Int32
    @NSManaged public var rush3B_HS: Int32
    @NSManaged public var rush5_HS: Int32
    @NSManaged public var rush5B_HS: Int32
    @NSManaged public var uid: String?
    @NSManaged public var rush3Attempts: NSSet?
    @NSManaged public var rush5Attempts: NSSet?
    @NSManaged public var puzzleAttempts: NSSet?

}

// MARK: Generated accessors for rush3Attempts
extension PuzzledUser {

    @objc(addRush3AttemptsObject:)
    @NSManaged public func addToRush3Attempts(_ value: Rush3Attempt)

    @objc(removeRush3AttemptsObject:)
    @NSManaged public func removeFromRush3Attempts(_ value: Rush3Attempt)

    @objc(addRush3Attempts:)
    @NSManaged public func addToRush3Attempts(_ values: NSSet)

    @objc(removeRush3Attempts:)
    @NSManaged public func removeFromRush3Attempts(_ values: NSSet)

}

// MARK: Generated accessors for rush5Attempts
extension PuzzledUser {

    @objc(addRush5AttemptsObject:)
    @NSManaged public func addToRush5Attempts(_ value: Rush5Attempt)

    @objc(removeRush5AttemptsObject:)
    @NSManaged public func removeFromRush5Attempts(_ value: Rush5Attempt)

    @objc(addRush5Attempts:)
    @NSManaged public func addToRush5Attempts(_ values: NSSet)

    @objc(removeRush5Attempts:)
    @NSManaged public func removeFromRush5Attempts(_ values: NSSet)

}

// MARK: Generated accessors for puzzleAttempts
extension PuzzledUser {

    @objc(addPuzzleAttemptsObject:)
    @NSManaged public func addToPuzzleAttempts(_ value: PuzzleAttempt)

    @objc(removePuzzleAttemptsObject:)
    @NSManaged public func removeFromPuzzleAttempts(_ value: PuzzleAttempt)

    @objc(addPuzzleAttempts:)
    @NSManaged public func addToPuzzleAttempts(_ values: NSSet)

    @objc(removePuzzleAttempts:)
    @NSManaged public func removeFromPuzzleAttempts(_ values: NSSet)

}
