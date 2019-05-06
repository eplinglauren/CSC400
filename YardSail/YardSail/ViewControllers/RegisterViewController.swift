//
//  RegisterViewController.swift
//  YardSail
//
//  Created by Matthew Piasecki on 3/25/19.
//  Copyright © 2019 Matthew Piasecki. All rights reserved.
//

import UIKit
import Firebase
import SwiftValidator

class RegisterViewController: UIViewController, ValidationDelegate {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var passwordConfirm: UITextField!
    let validator = Validator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Validation Rules are evaluated from left to right.
//        validator.registerField(fullNameTextField, rules: [RequiredRule(), FullNameRule()])
        validator.registerField(email, rules: [RequiredRule()])
        validator.registerField(password, rules: [RequiredRule()])
        validator.registerField(passwordConfirm, rules: [RequiredRule()])
        // You can pass in error labels with your rules
        // You can pass in custom error messages to regex rules (such as ZipCodeRule and EmailRule)
//        validator.registerField(email, errorLabel: emailErrorLabel, rules: [RequiredRule(), EmailRule(message: "Invalid email")])
//        // You can validate against other fields using ConfirmRule
//        validator.registerField(emailConfirmTextField, errorLabel: emailConfirmErrorLabel, rules: [ConfirmationRule(confirmField: emailTextField)])
    }
    
    // ValidationDelegate methods
    
    func validationSuccessful() {
        // submit the form
    }
    
    func validationFailed(_ errors:[(Validatable ,ValidationError)]) {
        // turn the fields to red
        for (field, error) in errors {
            if let field = field as? UITextField {
                field.layer.borderColor = UIColor.red.cgColor
                field.layer.borderWidth = 1.0
            }
            error.errorLabel?.text = error.errorMessage // works if you added labels
            error.errorLabel?.isHidden = false
        }
    }

    
    @IBAction func registerPressed(_ sender: UIButton) {
        validator.validate(self)
        if password.text != passwordConfirm.text {
            let alertController = UIAlertController(title: "Password Incorrect", message: "Please re-type password", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else {
            Auth.auth().createUser(withEmail: email.text!, password: password.text!){ (user, error) in
                if error == nil {
                    self.performSegue(withIdentifier: "RegisterToList", sender: self)
                }
                else{
                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}
