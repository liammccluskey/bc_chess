//
//  PuzzleReference+CoreDataProperties.swift
//  BCPtest
//
//  Created by Liam Mccluskey on 8/15/20.
//  Copyright © 2020 Marty McCluskey. All rights reserved.
//
//

import Foundation
import CoreData


extension PuzzleReference {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PuzzleReference> {
        return NSFetchRequest<PuzzleReference>(entityName: "PuzzleReference")
    }

    @NSManaged public var eloBlindfold: Int32
    @NSManaged public var eloRegular: Int32
    @NSManaged public var puzzleIndex: Int32
    @NSManaged public var puzzleType: Int32

}
