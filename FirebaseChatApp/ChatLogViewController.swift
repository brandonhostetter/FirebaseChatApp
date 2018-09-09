//
//  ChatLogViewController.swift
//  FirebaseChatApp
//
//  Created by Brandon Hostetter on 9/9/18.
//  Copyright © 2018 Brandon Hostetter. All rights reserved.
//

import UIKit
import Firebase

class ChatLogViewController: UIViewController {
    var db: Firestore!

    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Util.shared.db
        
        navigationItem.title = "Chat log controller"
    }
    
    private func sendMessage() {
        guard let msgText = inputTextField.text else { return }
        let msg = ["text": msgText]
        self.db.collection(kMessagesKey).addDocument(data: msg) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Message successfully added to database!")
            }
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        sendMessage()
    }
}

extension ChatLogViewController: UICollectionViewDelegate {
    
}

extension ChatLogViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "asdf", for: indexPath)
        return cell
    }
}

extension ChatLogViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}
