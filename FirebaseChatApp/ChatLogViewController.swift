//
//  ChatLogViewController.swift
//  FirebaseChatApp
//
//  Created by Brandon Hostetter on 9/9/18.
//  Copyright © 2018 Brandon Hostetter. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ChatLogViewController: UIViewController {
    var db: Firestore!
    var user: User? {
        didSet {
            navigationItem.title = user?.name
        }
    }

    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db = Util.shared.db
    }
    
    private func sendMessage() {
        guard let msgText = inputTextField.text,
            let toId = user?.id,
            let fromId = Auth.auth().currentUser?.uid
            else { return }
        
        let timestamp = NSDate().timeIntervalSince1970
        let msg: [String: Any] = ["text": msgText, "toId": toId, "fromId": fromId, "timestamp": timestamp]
        
        // Save message to "messages" collection
        let newMsgRef = db.collection(kMessagesKey).document()
        newMsgRef.setData(msg) { (err) in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Message successfully added to database!")
                
                // Save to sender's messages
                self.db.collection(kUserMessagesKey).document("\(fromId)").collection(kMessagesKey).document(newMsgRef.documentID).setData(["1": 1], completion: { (err) in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Message successfully fanned out!")
                    }
                })
                
                // Save to recipient's messages
                self.db.collection(kUserMessagesKey).document("\(toId)").collection(kMessagesKey).document(newMsgRef.documentID).setData(["1": 1], completion: { (err) in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Message successfully fanned out!")
                    }
                })
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
