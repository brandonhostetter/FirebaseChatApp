//
//  ViewController.swift
//  FirebaseChatApp
//
//  Created by Brandon Hostetter on 9/8/18.
//  Copyright © 2018 Brandon Hostetter. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logout))
        
        if Auth.auth().currentUser?.uid == nil {
            perform(#selector(logout), with: nil, afterDelay: 0)
        }
    }

    @objc private func logout() {
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: kLoginViewControllerId)
        self.present(controller, animated: true, completion: nil)
    }
}

