//
//  Story.swift
//  BreakingNewsValdez
//
//  Created by Scott Biddle on 6/24/15.
//  Copyright (c) 2015 Sbunticot Enterprises. All rights reserved.
//

import Foundation
import CoreData

class Story: NSManagedObject {

    @NSManaged var eventBody: String
    @NSManaged var eventType: String
    @NSManaged var id: NSNumber
    @NSManaged var importDate: NSNumber
    @NSManaged var isBroadcast: NSNumber
    @NSManaged var isFavorite: NSNumber

}
