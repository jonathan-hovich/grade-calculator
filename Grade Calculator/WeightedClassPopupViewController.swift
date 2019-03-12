//
//  WeightedGradeViewController.swift
//  ListWithPopupApp
//
//  Created by Jonathan Hovich on 7/17/18.
//  Copyright © 2018 Jonathan Hovich. All rights reserved.
//

import UIKit

class WeightedClassPopupViewController: UIViewController, UITextFieldDelegate {
    // outlets
    @IBOutlet weak var popup: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var creditTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var creditErrorMsgLabel: UILabel!
    
    var editClass: Bool = false;
    
    var noChanges: Bool = false;
    var onSave: ((_ course: Course, _ editingState: Bool) -> ())?
    
    var tempClassCredit: String = ""
    var tempClassName: String = ""
    
    var activeTextField : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // actions for input fields
        creditTextField.addTarget(self, action: #selector(WeightedClassPopupViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        nameTextField.addTarget(self, action: #selector(WeightedClassPopupViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        
        // defualt element attributes
        nameTextField.layer.borderColor = UIColor.lightGray.cgColor
        nameTextField.layer.borderWidth = 1.0
        nameTextField.layer.cornerRadius = 5.0
        creditTextField.layer.borderColor = UIColor.lightGray.cgColor
        creditTextField.layer.borderWidth = 1.0
        creditTextField.layer.cornerRadius = 5.0
        
        // listen to keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        
        // changes action button title based on state
        if !editClass {
            addButton.setTitle("Add", for: .normal)
            titleLabel.text = "New Grade"
        }
        else {
            addButton.setTitle("Done", for: .normal)
            titleLabel.text = "Edit Grade"
            creditTextField.text = tempClassCredit
            nameTextField.text = tempClassName
        }
        
        creditErrorMsgLabel.text = ""
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
        if (editClass) {
            if (tempClassCredit == creditTextField.text && tempClassName == nameTextField.text) {
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
        
        
        if (!creditTextField.hasText) {
            creditTextField.layer.borderColor = UIColor.red.cgColor
            valid = false
        }
        else if (creditTextField.text?.doubleValue == nil) {
            creditErrorMsgLabel.text = "Numeric values only"
            creditTextField.layer.borderColor = UIColor.red.cgColor
            valid = false
        }
        else {
            creditTextField.layer.borderColor = UIColor.lightGray.cgColor
            creditErrorMsgLabel.text = ""
        }
        
        if valid {
            var newClass = Course(name: nameTextField.text!, creditWeight: (creditTextField.text?.doubleValue)!, currentGrade: nil)
            
            onSave?(newClass, editClass)
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
