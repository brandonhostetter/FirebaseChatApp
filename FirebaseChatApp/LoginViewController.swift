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
import FirebaseStorage

class LoginViewController: UIViewController {
    var db: Firestore!
    var messagesController: MessagesController?
    
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
        
        
        let profileImageViewTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(profileImageViewTapped))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(profileImageViewTapGestureRecognizer)
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
            
            self.messagesController?.fetchUserAndSetupNavBarTitle()
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
            
            if let image = self.profileImageView.image, image != #imageLiteral(resourceName: "gameofthrones_splash"), let imageData = UIImagePNGRepresentation(image) {
                let storage = Storage.storage()
                let storageRef = storage.reference()
                let profileRef = storageRef.child("\(kProfileImagesKey)/\(uid).png")

                let uploadTask = profileRef.putData(imageData, metadata: nil) { (metadata, error) in
                    if error != nil || metadata == nil {
                        print(error ?? "Error")
                        return
                    }
                    
                    profileRef.downloadURL { (url, error) in
                        guard let downloadURL = url else {
                            // Uh-oh, an error occurred!
                            return
                        }
                        
                        let user: [String: Any] = [
                            "name": name,
                            "email": email,
                            "profileImageUrl": downloadURL.absoluteString
                        ]
                        self.addUserToDatabase(uid, user)
                    }
                }
            }
        }
    }
    
    private func addUserToDatabase(_ uid: String, _ user: [String: Any]) {
        self.db.collection(kUsersKey).document("\(uid)").setData(user) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("User successfully added to database!")
                
                self.messagesController?.navigationItem.title = user["name"] as? String ?? ""
                self.dismiss(animated: true, completion: nil)
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
    
    @objc private func profileImageViewTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
}

extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImage: UIImage?
        
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImage = originalImage
        }
        
        if let selectedImage = selectedImage {
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
}
