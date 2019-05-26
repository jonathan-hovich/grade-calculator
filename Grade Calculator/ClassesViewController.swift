//
//  ClassesViewController.swift
//  Grade Calculator
//
//  Created by Jonathan Hovich on 3/11/19.
//  Copyright © 2019 Jonathan Hovich. All rights reserved.
//

import UIKit
import CoreData

var selectedClassRowIndex: Int = Int()
var classes: [Course] = [] // used to load data into memory

class ClassesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avgLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var noGradesLabel: UILabel!
    var editClass = false
    
    override func viewDidLoad() {
        fetchClasses()
        super.viewDidLoad()
        updateAvg()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchClasses()
        tableView.reloadData()
        updateAvg()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }
    
    // new cell created when new class is added
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ViewControllerTableViewCell
        cell.gradeWeight.text = "\(classes[indexPath.row].weight) credits"
        print(classes[indexPath.row])
        
        // hacky fix for no course average
        if (classes[indexPath.row].value == -1) {
            cell.noGrades.isHidden = false
            cell.gradeValue.isHidden = true
            cell.gradePercent.isHidden = true
        }
        else {
            cell.noGrades.isHidden = true
            cell.gradeValue.isHidden = false
            cell.gradePercent.isHidden = false
            cell.gradeValue.text = "\(classes[indexPath.row].value)"
        }

        cell.gradeName.text = classes[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        //Cell editing option: Delete
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let alert = UIAlertController(title: "Delete \"\(classes[selectedClassRowIndex].name!)\"?", message: "Deleting a class will delete all corresponding grades.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in }))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                self.deleteClass()
                fetchClasses()
                
                tableView.beginUpdates()
                tableView.deleteRows(at: [index], with: .automatic)
                tableView.endUpdates()
                self.updateAvg()
            }))
            self.present(alert, animated: true, completion: nil)
        }
        delete.backgroundColor = .red
        
        //Cell editing option: Edit
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.editClass = true
            selectedClassRowIndex = index.row
            self.performSegue(withIdentifier: "toAddWeightedClassPopup", sender: nil)
        }
        edit.backgroundColor = .orange
        
        return [delete, edit]
    }
    
    // determines which cell is to be edited
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedClassRowIndex = indexPath.row
    }
    
    // editing popup appears
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAddWeightedClassPopup" {
            let popup = segue.destination as! WeightedClassPopupViewController
            popup.onSave = onSave
            popup.editClass = editClass
            
            // pre-populates edit dialogue with values
            if (editClass == true) {
                popup.editClass = editClass
                popup.tempClassCredit = "\(classes[selectedClassRowIndex].weight)"
                popup.tempClassName = "\(classes[selectedClassRowIndex].name!)"
                editClass = false
            }
        }
    }
    
    // helper to save new/edited data to persistant storage
    func onSave(name: String, weight: Double, editingState: Bool) {
        
         // saves edited data, updates tableview
        if editingState {
            classes[selectedClassRowIndex].setValue(name, forKey: "name")
            classes[selectedClassRowIndex].setValue(weight, forKey: "weight")
            
            do {
                try classes[selectedClassRowIndex].managedObjectContext?.save()
            } catch {
                print("couldn't save course")
            }
            
            let indexPath = IndexPath(row: selectedClassRowIndex, section: 0)
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
        
        // saves new data, updates tableview
        else {
            do {
                let course = Course(name: name, weight: weight, value: -1)
                try course?.managedObjectContext?.save()
            } catch {
                print("couldn't save course")
            }

            fetchClasses()
            let indexPath = IndexPath(row: classes.count - 1, section: 0)
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }

        // update average and display it
        updateAvg()
    }
    
    // helper to compute weighted average
    func updateAvg() {
        
        // if no grades exist, update UI (nothing comuputed)
        if (classes.count == 0) {
            descLabel.isHidden = true
            avgLabel.isHidden = true
            noGradesLabel.isHidden = false
            noGradesLabel.text = "Click the \"+\" to add a class."
            return
        }
        
        var weightedAvg : Double = 0
        var totWeight : Double = 0
        let currClassAvg: Double
        var gradesExist = false
        
        // compute weighted average
        for element in classes {
            let curr = element
            
            //skips classes with no grades
            if (curr.value != -1) {
                weightedAvg = weightedAvg + (curr.weight * curr.value)
                totWeight = totWeight + curr.weight
                gradesExist = true
            }
        }
        currClassAvg = weightedAvg / totWeight
        
        // update UI, display average
        if (gradesExist) {
            descLabel.isHidden = false
            avgLabel.isHidden = false
            noGradesLabel.isHidden = true
            avgLabel.text = "\(currClassAvg.fractionDigits(min: 0, max: 2, roundingMode: .up))%"
        }
        else {
            descLabel.isHidden = true
            avgLabel.isHidden = true
            noGradesLabel.isHidden = false
            noGradesLabel.text = "Select a class and add a grade to it."
        }
    }
    
    // helper to delete a class from persistant storage
    func deleteClass() {
        guard let managedContext = classes[selectedClassRowIndex].managedObjectContext else {
            return
        }
        
        managedContext.delete(classes[selectedClassRowIndex])
        
        do {
            try managedContext.save()
        } catch {
            print("could not save")
        }
    }
}

// helper to get all data from persistent storage
func fetchClasses() {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
    }
    let managedContext = appDelegate.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<Course> = Course.fetchRequest()
    
    do {
        classes = try managedContext.fetch(fetchRequest)
    } catch {
        print("can't fetch courses")
    }
}
