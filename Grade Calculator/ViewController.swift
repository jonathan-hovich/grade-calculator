//
//  ViewController.swift
//  ListWithPopupApp
//
//  Created by Jonathan Hovich on 7/17/18.
//  Copyright © 2018 Jonathan Hovich. All rights reserved.
//

import UIKit

var selectedRowIndex: Int = Int()

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // outlets
    @IBOutlet weak var tableView: UITableView!
    var gradeNames = Array<String>()
    var gradeWeights = Array<Double>()
    var gradeValues = Array<Double>()
    
    @IBOutlet weak var avgLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var noGradesLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // labels are hidden when no grades entered
        if (gradeWeights.count == 0) {
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
        return gradeWeights.count
    }
    
    // new cell created when new grade is added
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ViewControllerTableViewCell
        cell.gradeWeight.text = "\(gradeWeights[indexPath.row].fractionDigits(min: 0, max: 2, roundingMode: .up))%"
        cell.gradeValue.text = "\(gradeValues[indexPath.row].fractionDigits(min: 0, max: 2, roundingMode: .up))"
        cell.gradeName.text = gradeNames[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
       
        // removes cell when it is swiped
        if editingStyle == .delete {
            gradeWeights.remove(at: indexPath.row)
            gradeValues.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            updateAvg()
            
            if (gradeWeights.count == 0) {
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
            popup.editGrade = false
        }
        else {
            popup.editGrade = true
            selectedRowIndex = tableView.indexPathForSelectedRow!.row
            print("selectedRowIndex = \(selectedRowIndex)")
            popup.tempGradeWeight = "\(gradeWeights[selectedRowIndex])"
            popup.tempGradeVal = "\(gradeValues[selectedRowIndex])"
            popup.tempGradeName = "\(gradeNames[selectedRowIndex])"
        }
    }
    
    // TODO:
    //   - Save to persistant storage
    func onSave(weight: Double, grade: Double, name: String, editingState: Bool) {
        if editingState {
            let indexPath = IndexPath(row: selectedRowIndex, section: 0)
            gradeNames[indexPath.row] = name
            gradeWeights[indexPath.row] = weight
            gradeValues[indexPath.row] = grade
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        }
        else {
            gradeWeights.append(weight)
            gradeValues.append(grade)
            gradeNames.append(name)
            
            let indexPath = IndexPath(row: gradeWeights.count - 1, section: 0)
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
        
        for (index, element) in gradeWeights.enumerated() {
            weightedAvg = weightedAvg + (gradeWeights[index] * gradeValues[index])
            totWeight = totWeight + element
        }
        
        avgLabel.text = "\((weightedAvg/totWeight).fractionDigits(min: 0, max: 2, roundingMode: .up))%"
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
