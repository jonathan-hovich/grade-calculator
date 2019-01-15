//
//  WeightedGradeViewController.swift
//  ListWithPopupApp
//
//  Created by Jonathan Hovich on 7/17/18.
//  Copyright © 2018 Jonathan Hovich. All rights reserved.
//

import UIKit

class WeightedGradePopupViewController: UIViewController, UITextFieldDelegate {
    // outlets
    @IBOutlet weak var popup: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var gradeTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var weightErrorMsgLabel: UILabel!
    @IBOutlet weak var gradeErrorMsgLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    var editGrade: Bool = false;
    var noChanges: Bool = false;
    var onSave: ((_ weight: Double, _ grade: Double, _ name: String, _ editingState: Bool) -> ())?
    
    var tempGradeVal: String = ""
    var tempGradeWeight: String = ""
    var tempGradeName: String = ""
    
    var activeTextField : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // actions for input fields
        weightTextField.addTarget(self, action: #selector(WeightedGradePopupViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        nameTextField.addTarget(self, action: #selector(WeightedGradePopupViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        gradeTextField.addTarget(self, action: #selector(WeightedGradePopupViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        // defualt element attributes
        gradeTextField.layer.borderColor = UIColor.lightGray.cgColor
        gradeTextField.layer.borderWidth = 1.0
        gradeTextField.layer.cornerRadius = 5.0
        nameTextField.layer.borderColor = UIColor.lightGray.cgColor
        nameTextField.layer.borderWidth = 1.0
        nameTextField.layer.cornerRadius = 5.0
        weightTextField.layer.borderColor = UIColor.lightGray.cgColor
        weightTextField.layer.borderWidth = 1.0
        weightTextField.layer.cornerRadius = 5.0
        
        // listen to keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        // changes action button title based on state
        if !editGrade {
            addButton.setTitle("Add", for: .normal)
            titleLabel.text = "New Grade"
        }
        else {
            addButton.setTitle("Done", for: .normal)
            titleLabel.text = "Edit Grade"
            weightTextField.text = tempGradeWeight
            gradeTextField.text = tempGradeVal
            nameTextField.text = tempGradeName
        }
        
        weightErrorMsgLabel.text = ""
        gradeErrorMsgLabel.text = ""
    }
    
    deinit {
        // stop listening for keyboard hide/show event
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
    }
    
    // popover is pushed higher when keyboard appears
    @objc func keyboardWillChange (notification: Notification) {
        guard let keyboardRect = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        if notification.name == Notification.Name.UIKeyboardWillShow || notification.name == Notification.Name.UIKeyboardWillChangeFrame {
            view.frame.origin.y = -(keyboardRect.height/2)
        }
    }
    
    
    
    @objc func textFieldDidChange(_ textField: UITextField){
        if (editGrade) {
            if (tempGradeVal == gradeTextField.text && tempGradeWeight == weightTextField.text && tempGradeName == nameTextField.text) {
                addButton.setTitle("Done", for: .normal)
                noChanges = true
            }
            else {
                addButton.setTitle("Save Edit", for: .normal)
                noChanges = false
            }
        }
    }
    
    @IBAction func cancelButton_TouchUpInside(_ sender: Any) {
        dismiss(animated: true)
    }
    

    @IBAction func addButton_TouchUpInside(_ sender: UIButton) {
        var valid : Bool = true
        var tempWeight : Double? = weightTextField.text?.doubleValue
        var tempGrade : Double? = gradeTextField.text?.doubleValue
        
        if noChanges {
            dismiss(animated: true)
            return
        }
        
        if (!nameTextField.hasText) {
            nameTextField.layer.borderColor = UIColor.red.cgColor
            valid = false
        }
        else {
            nameTextField.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        
        if (!weightTextField.hasText) {
            weightTextField.layer.borderColor = UIColor.red.cgColor
            valid = false
        }
        else if (tempWeight == nil) {
            weightErrorMsgLabel.text = "Numeric values only"
            weightTextField.layer.borderColor = UIColor.red.cgColor
            valid = false
        }
        else {
            weightTextField.layer.borderColor = UIColor.lightGray.cgColor
            weightErrorMsgLabel.text = ""
        }
        
        if (!gradeTextField.hasText) {
            gradeTextField.layer.borderColor = UIColor.red.cgColor
            valid = false
        }
        else if (tempGrade == nil) {
            gradeErrorMsgLabel.text = "Numeric values only"
            gradeTextField.layer.borderColor = UIColor.red.cgColor
            valid = false
        }
        else {
            gradeTextField.layer.borderColor = UIColor.lightGray.cgColor
            gradeErrorMsgLabel.text = ""
        }
        
        if valid {
            onSave?(tempWeight!, tempGrade!, nameTextField.text!, editGrade)
            dismiss(animated: true)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeTextField = textField
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension String {
    struct NumFormatter {
        static let instance = NumberFormatter()
    }
    
    var doubleValue: Double? {
        return NumFormatter.instance.number(from: self)?.doubleValue
    }
    
    var integerValue: Int? {
        return NumFormatter.instance.number(from: self)?.intValue
    }
}
