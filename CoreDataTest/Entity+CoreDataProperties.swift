//
//  Entity+CoreDataProperties.swift
//  CoreDataTest
//
//  Created by Pavel Minárik on 25/11/15.
//  Copyright © 2015 Pavel Minárik. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Entity {

    @NSManaged var id: String?
    @NSManaged var name: String?
    @NSManaged var value: NSNumber?

}
