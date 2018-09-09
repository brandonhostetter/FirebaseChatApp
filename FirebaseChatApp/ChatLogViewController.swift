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
    var messages = [Message]()
    var messagesDict = [String: Message]()

    @IBOutlet weak var inputContainerView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Util.shared.db
        collectionView.register(UINib(nibName: kChatMessageCollectionViewCell, bundle: nil), forCellWithReuseIdentifier: kChatMessageCollectionViewCellReuseId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeMessages()
    }
    
    private func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection(kUserMessagesKey).document(uid).collection(kMessagesKey).addSnapshotListener { (querySnapshot, err) in
            guard let documents = querySnapshot?.documents else { return }
            for doc in documents {
                self.db.collection(kMessagesKey).document("\(doc.documentID)").getDocument(completion: { (documentSnapshot, err) in
                    guard let doc = documentSnapshot, let data = doc.data() else { return }
                    let msg = Message(data)
                    
                    if msg.chatPartnerId() == self.user?.id {
                        self.messages.append(msg)
                        self.collectionView.reloadData()
                    }
                })
            }
        }
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
                self.db.collection(kUserMessagesKey).document(fromId).collection(kMessagesKey).document(newMsgRef.documentID).setData(["1": 1], completion: { (err) in
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
        return messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kChatMessageCollectionViewCellReuseId, for: indexPath) as! ChatMessageCollectionViewCell
        cell.messageLabel.text = messages[indexPath.row].text
        return cell
    }
}

extension ChatLogViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage()
        return true
    }
}

extension ChatLogViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 80)
    }
}
