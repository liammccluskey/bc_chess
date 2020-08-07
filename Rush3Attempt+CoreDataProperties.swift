//
//  Rush3Attempt+CoreDataProperties.swift
//  BCPtest
//
//  Created by Guest on 8/6/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//
//

import Foundation
import CoreData


extension Rush3Attempt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rush3Attempt> {
        return NSFetchRequest<Rush3Attempt>(entityName: "Rush3Attempt")
    }

    @NSManaged public var didStrikeout: Bool
    @NSManaged public var didTimeout: Bool
    @NSManaged public var numCorrect: Int32
    @NSManaged public var piecesHidden: Bool
    @NSManaged public var timestamp: Date?

}
