//
//  Rush3Attempt+CoreDataProperties.swift
//  
//
//  Created by Guest on 8/5/20.
//
//

import Foundation
import CoreData


extension Rush3Attempt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rush3Attempt> {
        return NSFetchRequest<Rush3Attempt>(entityName: "Rush3Attempt")
    }

    @NSManaged public var didTimeout: Bool
    @NSManaged public var didStrikeout: Bool
    @NSManaged public var numCorrect: Int32
    @NSManaged public var timestamp: Date?
    @NSManaged public var piecesHidden: Bool

}
