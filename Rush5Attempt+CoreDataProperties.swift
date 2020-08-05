//
//  Rush5Attempt+CoreDataProperties.swift
//  
//
//  Created by Guest on 8/5/20.
//
//

import Foundation
import CoreData


extension Rush5Attempt {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Rush5Attempt> {
        return NSFetchRequest<Rush5Attempt>(entityName: "Rush5Attempt")
    }

    @NSManaged public var numCorrect: Int32
    @NSManaged public var timestamp: Date?
    @NSManaged public var didTimeout: Bool
    @NSManaged public var didStrikeout: Bool
    @NSManaged public var piecesHidden: Bool

}
