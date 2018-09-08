//
//  LoginViewController.swift
//  FirebaseChatApp
//
//  Created by Brandon Hostetter on 9/8/18.
//  Copyright © 2018 Brandon Hostetter. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {
    var db: Firestore!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var loginRegisterSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    
    @IBOutlet weak var inputContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameTextFieldHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        inputContainerView.layer.cornerRadius = 5
        inputContainerView.layer.masksToBounds = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private func setupSegmentedControl() {
        
    }
    
    private func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }

        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error ?? "Error")
                return
            }
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func handleRegister() {
        guard let name = nameTextField.text, let email = emailTextField.text, let password = passwordTextField.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if error != nil {
                print(error ?? "Error")
                return
            }
            
            guard let uid = result?.user.uid else {
                return
            }
            
            // Add a new document with a generated ID
            let user: [String: String] = [
                "name": name,
                "email": email
            ]
            self.db.collection("users").document("\(uid)").setData(user) { err in
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    print("User successfully added to database!")
                    
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    @IBAction func loginRegisterSegmentedControlChanged(_ sender: Any) {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            // Login
            registerButton.setTitle("Login", for: .normal)
            inputContainerHeightConstraint.constant = 100
            nameTextFieldHeightConstraint.constant = 0
        } else {
            // Register
            registerButton.setTitle("Register", for: .normal)
            inputContainerHeightConstraint.constant = 150
            nameTextFieldHeightConstraint.constant = 50
        }
    }
}

