//
//  Grade+CoreDataProperties.swift
//  Grade Calculator
//
//  Created by Jonathan Hovich on 5/18/19.
//  Copyright © 2019 Jonathan Hovich. All rights reserved.
//
//

import Foundation
import CoreData


extension Grade {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Grade> {
        return NSFetchRequest<Grade>(entityName: "Grade")
    }

    @NSManaged public var name: String?
    @NSManaged public var value: Double
    @NSManaged public var weight: Double
    @NSManaged public var course: Course?

}
