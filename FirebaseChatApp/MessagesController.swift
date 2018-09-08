//
//  MessagesController.swift
//  FirebaseChatApp
//
//  Created by Brandon Hostetter on 9/8/18.
//  Copyright © 2018 Brandon Hostetter. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class MessagesController: UIViewController {
    var db: Firestore!

    override func viewDidLoad() {
        super.viewDidLoad()
        db = Util.shared.db

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(logout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "new_message_icon"), style: .plain, target: self, action: #selector(createNewMessage))
        
        checkIfUserLoggedIn()
    }
    
    func fetchUserAndSetupNavBarTitle() {
        guard let uid = Auth.auth().currentUser?.uid else {
            assertionFailure()
            return
        }
        
        let userRef = db.collection(kUsersKey).document(uid)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists {
                let data: [String: Any] = document.data() ?? [:]
                if let name = data[kUserNameKey] as? String {
                    self.navigationItem.title = name
                }
                print("Document data: \(data)")
            } else {
                print("Document does not exist")
            }
        }
    }
    
    private func checkIfUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            // Go to login page
            perform(#selector(logout), with: nil, afterDelay: 0)
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    @objc private func createNewMessage() {
        let newMessageViewController = NewMessageViewController(nibName: kNewMessageView, bundle: nil)
        let navigationController = UINavigationController(rootViewController: newMessageViewController)
        present(navigationController, animated: true, completion: nil)
    }

    @objc private func logout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginRegisterViewController = LoginViewController(nibName: kLoginRegisterView, bundle: nil)
        loginRegisterViewController.messagesController = self
        present(loginRegisterViewController, animated: true, completion: nil)
    }
}

