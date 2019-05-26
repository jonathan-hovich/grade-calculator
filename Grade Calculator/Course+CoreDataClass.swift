//
//  Course+CoreDataClass.swift
//  Grade Calculator
//
//  Created by Jonathan Hovich on 5/18/19.
//  Copyright © 2019 Jonathan Hovich. All rights reserved.
//
//

import UIKit
import CoreData

@objc(Course)
public class Course: NSManagedObject {
    
    // initializer for Course object
    convenience init?(name: String, weight: Double, value: Double) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        guard let context = appDelegate?.persistentContainer.viewContext else {
            return nil
        }
        
        self.init(entity: Course.entity(), insertInto: context)
        self.name = name
        self.weight = weight
        self.value = value
    }
    
}
