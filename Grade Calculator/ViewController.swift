//
//  ViewController.swift
//  ListWithPopupApp
//
//  Created by Jonathan Hovich on 7/17/18.
//  Copyright © 2018 Jonathan Hovich. All rights reserved.
//

import UIKit
import CoreData

var selectedRowIndex: Int = Int()

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avgLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var noGradesLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationItem!

    var editGrade = false
    var selectedCourse: Course?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navBar.title = classes[selectedClassRowIndex].name
        updateAvg()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes[selectedClassRowIndex].rawGrades?.array.count ?? 0
    }

    // new cell created when new grade is added
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ViewControllerTableViewCell
        let newGrade = classes[selectedClassRowIndex].rawGrades?.array[indexPath.row] as! Grade
        
        cell.accessoryType = .none // cell cannot be "stepped into", UI reflects this
        cell.noGrades.isHidden = true
        
        cell.gradeWeight.text = "\(newGrade.weight.fractionDigits(min: 0, max: 2, roundingMode: .up))%"
        cell.gradeValue.text = "\(newGrade.value.fractionDigits(min: 0, max: 2, roundingMode: .up))"
        cell.gradeName.text = newGrade.name
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        //Cell editing option: Delete
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            selectedRowIndex = index.row
            self.deleteGrade()
            fetchClasses()
            
            //update table & average
            tableView.beginUpdates()
            tableView.deleteRows(at: [index], with: .automatic)
            tableView.endUpdates()
            self.updateAvg()
        }
        delete.backgroundColor = .red

        //Cell editing option: Edit
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.editGrade = true
            selectedRowIndex = index.row
            
            // opens edit dialogue
            self.performSegue(withIdentifier: "toAddWeightedGradePopup", sender: nil)
        }
        edit.backgroundColor = .orange

        return [delete, edit]
    }

    // determines which cell is to be edited
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRowIndex = indexPath.row
    }
    
    // editing popup appears
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let popup = segue.destination as! WeightedGradePopupViewController
        popup.onSave = onSave

        if segue.identifier == "toAddWeightedGradePopup" {
            if (editGrade == false) {
                popup.editGrade = editGrade
            }
            // pre-populates edit dialogue with values
            else {
                let tempGrade = classes[selectedClassRowIndex].rawGrades?.array[selectedRowIndex] as! Grade
                popup.editGrade = editGrade
                popup.tempGradeWeight = "\(tempGrade.weight)"
                popup.tempGradeVal = "\(tempGrade.value)"
                popup.tempGradeName = "\(tempGrade.name!)"
                editGrade = false
            }
        }
    }

    // helper to save new/edited data to persistant storage
    func onSave (name: String, weight: Double, value: Double, editingState: Bool) {
        
        // saves edited data, updates tableview
        if editingState {
            let temp = classes[selectedClassRowIndex].rawGrades?.array[selectedRowIndex] as! Grade
           
            temp.setValue(name, forKey: "name")
            temp.setValue(weight, forKey: "weight")
            temp.setValue(value, forKey: "value")
            
            let indexPath = IndexPath(row: selectedRowIndex, section: 0)
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
        
        // saves new data, updates tableview
        else {
            if let grade = Grade(name: name, value: value, weight: weight) {
                classes[selectedClassRowIndex].addToRawGrades(grade)
            
                do {
                    try grade.managedObjectContext?.save()
                } catch {
                    print("couldn't save grade")
                }
            }
            
            fetchClasses()
            let indexPath = IndexPath(row: classes[selectedClassRowIndex].rawGrades!.count - 1, section: 0)
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }

        // update average and display it
        updateAvg()
    }

    // helper to compute weighted average for a class
    func updateAvg() {
        let temp = classes[selectedClassRowIndex]
        
        // if no grades exist, update UI (nothing comuputed)
        if (classes[selectedClassRowIndex].rawGrades?.count == 0) {
            temp.setValue(-1, forKey: "value") // hacky fix for no existing average
            
            descLabel.isHidden = true
            avgLabel.isHidden = true
            noGradesLabel.isHidden = false
            noGradesLabel.text = "Click the \"+\" to add a grade."
            return
        }
        
        var weightedAvg : Double = 0
        var totWeight : Double = 0
        let currGrade: Double
        var gradesExist = false

        // compute weighted average
        for element in classes[selectedClassRowIndex].rawGrades!.array {
            let curr = element as! Grade
            
            weightedAvg = weightedAvg + (curr.weight * curr.value)
            totWeight = totWeight + curr.weight
            gradesExist = true
        }
        currGrade = weightedAvg / totWeight
    
        // update UI, display average
        if (gradesExist) {
            descLabel.isHidden = false
            avgLabel.isHidden = false
            noGradesLabel.isHidden = true
            avgLabel.text = "\(currGrade.fractionDigits(min: 0, max: 2, roundingMode: .up))%"
            temp.setValue(Double(currGrade.fractionDigits(min: 0, max: 2, roundingMode: .up)), forKey: "value")
        }
    }
    
    // helper to delete a grade from persistant storage
    func deleteGrade() {
        let temp = classes[selectedClassRowIndex].rawGrades?.array[selectedRowIndex] as! Grade
        guard let managedContext = temp.managedObjectContext else {
            return
        }
        managedContext.delete(temp)
        
        do {
            try managedContext.save()
        } catch {
            print("could not save")
        }
    }
}

extension Formatter {
    static let number = NumberFormatter()
}

extension FloatingPoint {
    func fractionDigits(min: Int, max: Int, roundingMode: NumberFormatter.RoundingMode) -> String {
        Formatter.number.minimumFractionDigits = min
        Formatter.number.maximumFractionDigits = max
        Formatter.number.roundingMode = roundingMode
        Formatter.number.numberStyle = .decimal
        return Formatter.number.string(for: self) ?? ""
    }
}
