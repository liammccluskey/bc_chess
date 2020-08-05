//
//  PuzzledUser+CoreDataProperties.swift
//  
//
//  Created by Guest on 8/5/20.
//
//

import Foundation
import CoreData


extension PuzzledUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PuzzledUser> {
        return NSFetchRequest<PuzzledUser>(entityName: "PuzzledUser")
    }

    @NSManaged public var puzzle_Elo: Int32
    @NSManaged public var rush3B_HS: Int32
    @NSManaged public var puzzleB_Elo: Int32
    @NSManaged public var rush3_HS: Int32
    @NSManaged public var rush5_HS: Int32
    @NSManaged public var rush5B_HS: Int32

}
