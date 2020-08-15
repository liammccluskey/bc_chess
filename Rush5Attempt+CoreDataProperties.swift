//
//  Rush5Attempt+CoreDataProperties.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 8/15/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//
//

import Foundation
import CoreData


extension Rush5Attempt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rush5Attempt> {
        return NSFetchRequest<Rush5Attempt>(entityName: "Rush5Attempt")
    }

    @NSManaged public var didStrikeout: Bool
    @NSManaged public var didTimeout: Bool
    @NSManaged public var numCorrect: Int32
    @NSManaged public var piecesHidden: Bool
    @NSManaged public var timestamp: Date?
    @NSManaged public var puzzledUser: PuzzledUser?

}
