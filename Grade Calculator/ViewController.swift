//
//  ViewController.swift
//  ListWithPopupApp
//
//  Created by Jonathan Hovich on 7/17/18.
//  Copyright © 2018 Jonathan Hovich. All rights reserved.
//

import UIKit

var selectedRowIndex: Int = Int()

struct Grade {
    var name: String
    var weight: Double
    var grade: Double
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var avgLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var noGradesLabel: UILabel!
    @IBOutlet weak var navBar: UINavigationItem!
    
    var editGrade = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navBar.title = classes[selectedClassRowIndex].name
        updateAvg()
    
        // labels are hidden when no grades entered
        if (classes[selectedClassRowIndex].grades.count == 0) {
            descLabel.isHidden = true
            avgLabel.isHidden = true
            noGradesLabel.isHidden = false
            noGradesLabel.text = "Click the \"+\" to add a grade."
        }
        else {
            descLabel.isHidden = false
            avgLabel.isHidden = false
            noGradesLabel.isHidden = true
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes[selectedClassRowIndex].grades.count
    }
    
    // new cell created when new grade is added
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ViewControllerTableViewCell
        let newGrade = classes[selectedClassRowIndex].grades[indexPath.row]
        
        cell.accessoryType = .none
        cell.noGrades.isHidden = true
        
        cell.gradeWeight.text = "\(newGrade.weight.fractionDigits(min: 0, max: 2, roundingMode: .up))%"
        cell.gradeValue.text = "\(newGrade.grade.fractionDigits(min: 0, max: 2, roundingMode: .up))"
        cell.gradeName.text = newGrade.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            classes[selectedClassRowIndex].grades.remove(at: index.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [index], with: .automatic)
            tableView.endUpdates()
            
            self.updateAvg()
            
            if (classes[selectedClassRowIndex].grades.count == 0) {
                self.descLabel.isHidden = true
                self.avgLabel.isHidden = true
                self.noGradesLabel.isHidden = false
                self.noGradesLabel.text = "Click the \"+\" to add a grade."
            }
            else {
                self.descLabel.isHidden = false
                self.avgLabel.isHidden = false
                self.noGradesLabel.isHidden = true
            }
        }
        delete.backgroundColor = .red
        
        let edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            self.editGrade = true
            selectedRowIndex = index.row
            self.performSegue(withIdentifier: "toAddWeightedGradePopup", sender: nil)
        }
        edit.backgroundColor = .orange
        
        return [delete, edit]
    }
    
    // determines which cell is to be edited
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRowIndex = indexPath.row
    }
    
    // editing popup appears prepopulated with grade data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let popup = segue.destination as! WeightedGradePopupViewController
        popup.onSave = onSave
        
        if segue.identifier == "toAddWeightedGradePopup" {
            if (editGrade == false) {
                popup.editGrade = editGrade
            }
            else {
                popup.editGrade = editGrade
                popup.tempGradeWeight = "\(classes[selectedClassRowIndex].grades[selectedRowIndex].weight)"
                popup.tempGradeVal = "\(classes[selectedClassRowIndex].grades[selectedRowIndex].grade)"
                popup.tempGradeName = "\(classes[selectedClassRowIndex].grades[selectedRowIndex].name)"
                editGrade = false
            }
        }
    }
    
    // TODO:
    //   - Save to persistant storage
    func onSave(grade: Grade, editingState: Bool) {
        if editingState {
            let indexPath = IndexPath(row: selectedRowIndex, section: 0)
            classes[selectedClassRowIndex].grades[selectedRowIndex].weight = grade.weight
            classes[selectedClassRowIndex].grades[selectedRowIndex].name = grade.name
            classes[selectedClassRowIndex].grades[selectedRowIndex].grade = grade.grade
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
        else {
            classes[selectedClassRowIndex].grades.append(grade)
            let indexPath = IndexPath(row: classes[selectedClassRowIndex].grades.count - 1, section: 0)
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        
        // update average and display it
        updateAvg()
        descLabel.isHidden = false
        avgLabel.isHidden = false
        noGradesLabel.isHidden = true
        
    }
    
    // helper to compute weighted average
    func updateAvg() {
        var weightedAvg : Double = 0
        var totWeight : Double = 0
        let currGrade: Double

        for element in classes[selectedClassRowIndex].grades {
            weightedAvg = weightedAvg + (element.weight * element.grade)
            totWeight = totWeight + element.weight
        }

        currGrade = weightedAvg / totWeight
        avgLabel.text = "\(currGrade.fractionDigits(min: 0, max: 2, roundingMode: .up))%"
        
        classes[selectedClassRowIndex].currentGrade = currGrade
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
