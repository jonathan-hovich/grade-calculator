//
//  ClassesViewController.swift
//  Grade Calculator
//
//  Created by Jonathan Hovich on 3/11/19.
//  Copyright © 2019 Jonathan Hovich. All rights reserved.
//

import UIKit

var selectedClassRowIndex: Int = Int()

struct Course {
    var name: String
    var creditWeight: Double
    var currentGrade: Double? = nil
    var grades: [Grade] = []
}

var classes: [Course] = []

class ClassesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avgLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var noGradesLabel: UILabel!
    
    var editClass = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        classes = UserDefaults.standard.object(forKey: "data") as? [Course] ?? [Course]()
        
        descLabel.isHidden = true
        avgLabel.isHidden = true
        noGradesLabel.isHidden = false
        noGradesLabel.text = "Click the \"+\" to add a class."
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        updateAvg()
        
        for element in classes {
            if let currentGrade = element.currentGrade {
                if (currentGrade.isNaN) {
                    descLabel.isHidden = true
                    avgLabel.isHidden = true
                    noGradesLabel.isHidden = false
                    noGradesLabel.text = "Select a class and add a grade to it."
                }
                else {
                    descLabel.isHidden = false
                    avgLabel.isHidden = false
                    noGradesLabel.isHidden = true
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }
    
    // new cell created when new grade is added
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ViewControllerTableViewCell
        cell.gradeWeight.text = "\(classes[indexPath.row].creditWeight.fractionDigits(min: 0, max: 2, roundingMode: .up)) credits"
        print(classes[indexPath.row])
        
        // hacky fix for NaN optional var value
        if let currentGrade = classes[indexPath.row].currentGrade {
            if (currentGrade.isNaN) {
                cell.noGrades.isHidden = false
                cell.gradeValue.isHidden = true
                cell.gradePercent.isHidden = true
            }
            else {
                cell.noGrades.isHidden = true
                cell.gradeValue.isHidden = false
                cell.gradePercent.isHidden = false
                cell.gradeValue.text = "\(classes[indexPath.row].currentGrade!.fractionDigits(min: 0, max: 2, roundingMode: .up))"
            }
        } else {
            cell.noGrades.isHidden = false
            cell.gradeValue.isHidden = true
            cell.gradePercent.isHidden = true

        }
       
        cell.gradeName.text = classes[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        print(indexPath.row)
//
//        // removes cell when it is swiped
//        if editingStyle == .delete {
//            classes.remove(at: indexPath.row)
//
//            tableView.beginUpdates()
//            tableView.deleteRows(at: [indexPath], with: .automatic)
//            tableView.endUpdates()
//
//            if (classes.count == 0) {
//                descLabel.isHidden = true
//                avgLabel.isHidden = true
//                noGradesLabel.isHidden = false
//                noGradesLabel.text = "Click the \"+\" to add a class."
//            }
//            else {
//                for element in classes {
//                    if (element.grades.count > 0) {
//                        updateAvg()
//                        descLabel.isHidden = false
//                        avgLabel.isHidden = false
//                        noGradesLabel.isHidden = true
//                    }
//                    else {
//                        descLabel.isHidden = true
//                        avgLabel.isHidden = true
//                        noGradesLabel.isHidden = false
//                        noGradesLabel.text = "Select a class and add a grade to it."
//                    }
//                }
//            }
//
//
//
//        }
//    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            let alert = UIAlertController(title: "Delete \"\(classes[selectedClassRowIndex].name)\"?", message: "Deleting a class will delete all corresponding grades.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in }))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            classes.remove(at: index.row)

            tableView.beginUpdates()
            tableView.deleteRows(at: [index], with: .automatic)
            tableView.endUpdates()

            if (classes.count == 0) {
                self.descLabel.isHidden = true
                self.avgLabel.isHidden = true
                self.noGradesLabel.isHidden = false
                self.noGradesLabel.text = "Click the \"+\" to add a class."
            }
            else {
                for element in classes {
                    if (element.grades.count > 0) {
                        self.updateAvg()
                        self.descLabel.isHidden = false
                        self.avgLabel.isHidden = false
                        self.noGradesLabel.isHidden = true
                    }
                    else {
                        self.descLabel.isHidden = true
                        self.avgLabel.isHidden = true
                        self.noGradesLabel.isHidden = false
                        self.noGradesLabel.text = "Select a class and add a grade to it."
                    }
                }
            }
            }))
            self.present(alert, animated: true, completion: nil)
        }
        delete.backgroundColor = .red
        
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
        print("selectedClassRowIndex \(selectedClassRowIndex)")
        
    }
    
    
    // editing popup appears prepopulated with grade data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAddWeightedClassPopup" {
            let popup = segue.destination as! WeightedClassPopupViewController
            popup.onSave = onSave
            popup.editClass = editClass
            
            if (editClass == true) {
                popup.editClass = editClass
                
                print(selectedClassRowIndex)
                print(classes[selectedClassRowIndex].creditWeight)
                
                popup.tempClassCredit = "\(classes[selectedClassRowIndex].creditWeight)"
                popup.tempClassName = "\(classes[selectedClassRowIndex].name)"
                editClass = false
            }
            
        }
    }
    

    func onSave(course: Course, editingState: Bool) {
        print("courseCredit = \(course.creditWeight)")
        print("courseName = \(course.name)")
        
        if editingState {
            let indexPath = IndexPath(row: selectedClassRowIndex, section: 0)
            classes[selectedClassRowIndex].name = course.name
            classes[selectedClassRowIndex].creditWeight = course.creditWeight
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
        else {
            classes.append(course)

            let indexPath = IndexPath(row: classes.count - 1, section: 0)
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        
        // update average and display it

        if (avgLabel.isHidden == true) {
            noGradesLabel.text = "Select a class and add a grade to it."
        }
        
        UserDefaults.standard.set(classes, forKey: "data")
    }
    
    
    // helper to compute weighted average
    func updateAvg() {
        var weightedAvg : Double = 0
        var totWeight : Double = 0
        let currGrade: Double
        
        for element in classes {
            if let currentGrade = element.currentGrade {
                if (!currentGrade.isNaN) {
                    weightedAvg = weightedAvg + (element.creditWeight * element.currentGrade!)
                    totWeight = totWeight + element.creditWeight
                }
            }
        }
        
        currGrade = weightedAvg / totWeight
        avgLabel.text = "\(currGrade.fractionDigits(min: 0, max: 2, roundingMode: .up))%"
    }
}
