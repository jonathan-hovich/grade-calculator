//
//  Course+CoreDataProperties.swift
//  Grade Calculator
//
//  Created by Jonathan Hovich on 5/18/19.
//  Copyright © 2019 Jonathan Hovich. All rights reserved.
//
//

import Foundation
import CoreData


extension Course {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Course> {
        return NSFetchRequest<Course>(entityName: "Course")
    }

    @NSManaged public var name: String?
    @NSManaged public var weight: Double
    @NSManaged public var value: Double
    @NSManaged public var rawGrades: NSOrderedSet?

}

// MARK: Generated accessors for rawGrades
extension Course {

    @objc(insertObject:inRawGradesAtIndex:)
    @NSManaged public func insertIntoRawGrades(_ value: Grade, at idx: Int)

    @objc(removeObjectFromRawGradesAtIndex:)
    @NSManaged public func removeFromRawGrades(at idx: Int)

    @objc(insertRawGrades:atIndexes:)
    @NSManaged public func insertIntoRawGrades(_ values: [Grade], at indexes: NSIndexSet)

    @objc(removeRawGradesAtIndexes:)
    @NSManaged public func removeFromRawGrades(at indexes: NSIndexSet)

    @objc(replaceObjectInRawGradesAtIndex:withObject:)
    @NSManaged public func replaceRawGrades(at idx: Int, with value: Grade)

    @objc(replaceRawGradesAtIndexes:withRawGrades:)
    @NSManaged public func replaceRawGrades(at indexes: NSIndexSet, with values: [Grade])

    @objc(addRawGradesObject:)
    @NSManaged public func addToRawGrades(_ value: Grade)

    @objc(removeRawGradesObject:)
    @NSManaged public func removeFromRawGrades(_ value: Grade)

    @objc(addRawGrades:)
    @NSManaged public func addToRawGrades(_ values: NSOrderedSet)

    @objc(removeRawGrades:)
    @NSManaged public func removeFromRawGrades(_ values: NSOrderedSet)

}
