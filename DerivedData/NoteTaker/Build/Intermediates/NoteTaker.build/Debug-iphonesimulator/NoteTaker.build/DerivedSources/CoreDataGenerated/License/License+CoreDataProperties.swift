//
//  License+CoreDataProperties.swift
//  
//
//  Created by Daniel Bessonov on 6/28/17.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension License {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<License> {
        return NSFetchRequest<License>(entityName: "License")
    }

    @NSManaged public var key: NSData?
    @NSManaged public var name: String?

}
