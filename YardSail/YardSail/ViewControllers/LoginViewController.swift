//
//  LoginViewController.swift
//  YardSail
//
//  Created by Matthew Piasecki on 3/14/19.
//  Copyright © 2019 Matthew Piasecki. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    // MARK: Constants
    let loginToList = "LoginToList"
    
    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: UIViewController Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener() { auth, user in
            if user != nil {
                self.performSegue(withIdentifier: self.loginToList, sender: nil)
                self.textFieldLoginEmail.text = nil
                self.textFieldLoginPassword.text = nil
            }
        }
    }
    
    // MARK: Actions
    @IBAction func loginPressed(_ sender: UIButton) {
        guard
            let email = textFieldLoginEmail.text,
            let password = textFieldLoginPassword.text,
            email.count > 0,
            password.count > 0
            else {
                return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { user, error in
            if let error = error, user == nil {
                let alert = UIAlertController(title: "Sign In Failed",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                
                self.present(alert, animated: true, completion: nil)
            }
        }
    }

    
//    @IBAction func RegisterPressed(_ sender: UIButton) {
//        let alert = UIAlertController(title: "Register",
//                                      message: "Register",
//                                      preferredStyle: .alert)
//        
//        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
//            
//            let emailField = alert.textFields![0]
//            let passwordField = alert.textFields![1]
//            
//            Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { user, error in
//                if error == nil {
//                    Auth.auth().signIn(withEmail: self.textFieldLoginEmail.text!,
//                                       password: self.textFieldLoginPassword.text!)
//                }
//            }
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel",
//                                         style: .cancel)
//        
//        alert.addTextField { textEmail in
//            textEmail.placeholder = "Enter your email"
//        }
//        
//        alert.addTextField { textPassword in
//            textPassword.isSecureTextEntry = true
//            textPassword.placeholder = "Enter your password"
//        }
//        
//        alert.addAction(saveAction)
//        alert.addAction(cancelAction)
//        
//        present(alert, animated: true, completion: nil)
//    }
    
    @IBAction func unwindToLogin(sender: UIStoryboardSegue){
        print("Unwind to LoginVC")
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldLoginEmail {
            textFieldLoginPassword.becomeFirstResponder()
        }
        if textField == textFieldLoginPassword {
            textField.resignFirstResponder()
        }
        return true
    }
}
