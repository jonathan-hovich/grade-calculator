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
    var currentGrade: Double?
}

var classes: [Course] = []

class ClassesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // outlets
    @IBOutlet weak var tableView: UITableView!
//    var classesNames = Array<String>()
//    var classesWeights = Array<Double>()
//    var classesValues = Array<Double>()
    
//    var classesWeights: [Double] = [0.75]
//    var classesValues: [Double] = [78.00]
//    var classesNames: [String] = ["MGMT 3040"]
    
    
    @IBOutlet weak var avgLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var noGradesLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }
    
    // new cell created when new grade is added
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ViewControllerTableViewCell
        cell.gradeWeight.text = "\(classes[indexPath.row].creditWeight.fractionDigits(min: 0, max: 2, roundingMode: .up))"
//        cell.gradeValue.text = "\(classesValues[indexPath.row].fractionDigits(min: 0, max: 2, roundingMode: .up))"
        cell.gradeName.text = classes[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        print(indexPath.row)
        
        // removes cell when it is swiped
        if editingStyle == .delete {
            classes.remove(at: indexPath.row)
            
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
//            updateAvg()
            
            if (classes.count == 0) {
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
        selectedClassRowIndex = indexPath.row
    }
    
    
    // editing popup appears prepopulated with grade data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toAddWeightedClassPopup" {
            let popup = segue.destination as! WeightedClassPopupViewController
            popup.onSave = onSave
            popup.editClass = false
        }
//        else {
//            popup.editClass = true
//            selectedRowIndex = tableView.indexPathForSelectedRow!.row
//            print("selectedRowIndex = \(selectedRowIndex)")
//            popup.tempClassCredit = "\(classesWeights[selectedRowIndex])"
//            popup.tempClassName = "\(classesNames[selectedRowIndex])"
//        }
    }
    
    
    // TODO:
    //   - Save to persistant storage
//    func onSave(weight: Double, name: String, editingState: Bool) {
//        print("weight = \(weight)")
//        print("name = \(name)")
//
//        if editingState {
//            let indexPath = IndexPath(row: selectedRowIndex, section: 0)
//            classesNames[indexPath.row] = name
//            classesWeights[indexPath.row] = weight
//            tableView.beginUpdates()
//            tableView.reloadRows(at: [indexPath], with: .fade)
//            tableView.endUpdates()
//        }
//        else {
//            classesWeights.append(weight)
//            classesNames.append(name)
//
//            let indexPath = IndexPath(row: classesWeights.count - 1, section: 0)
//            tableView.beginUpdates()
//            tableView.insertRows(at: [indexPath], with: .automatic)
//            tableView.endUpdates()
//        }
//
//        // update average and display it
////        updateAvg()
//        descLabel.isHidden = false
//        avgLabel.isHidden = false
//        noGradesLabel.isHidden = true
//
//    }

    func onSave(course: Course, editingState: Bool) {
        print("courseCredit = \(course.creditWeight)")
        print("courseName = \(course.name)")
        
        if editingState {
//            let indexPath = IndexPath(row: selectedRowIndex, section: 0)
//            classesNames[indexPath.row] = name
//            classesWeights[indexPath.row] = weight
//            tableView.beginUpdates()
//            tableView.reloadRows(at: [indexPath], with: .fade)
//            tableView.endUpdates()
        }
        else {
            classes.append(course)

            let indexPath = IndexPath(row: classes.count - 1, section: 0)
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
        
        // update average and display it
        //        updateAvg()
        descLabel.isHidden = false
        avgLabel.isHidden = false
        noGradesLabel.isHidden = true
        
    }
    
    
    // helper to compute weighted average
//    func updateAvg() {
//        var weightedAvg : Double = 0
//        var totWeight : Double = 0
//
//        for (index, element) in classesWeights.enumerated() {
//            weightedAvg = weightedAvg + (classesWeights[index] * classesValues[index])
//            totWeight = totWeight + element
//        }
//
//        avgLabel.text = "\((weightedAvg/totWeight).fractionDigits(min: 0, max: 2, roundingMode: .up))%"
//    }

}
