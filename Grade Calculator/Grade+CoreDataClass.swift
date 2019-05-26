//
//  Grade+CoreDataClass.swift
//  Grade Calculator
//
//  Created by Jonathan Hovich on 5/18/19.
//  Copyright © 2019 Jonathan Hovich. All rights reserved.
//
//

import UIKit
import CoreData

@objc(Grade)
public class Grade: NSManagedObject {
    
    // initializer for Grade object
    convenience init?(name: String, value: Double, weight: Double) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        guard let context = appDelegate?.persistentContainer.viewContext else {
            return nil
        }
        
        self.init(entity: Grade.entity(), insertInto: context)
        self.name = name
        self.value = value
        self.weight = weight
    }
}
