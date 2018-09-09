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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    private func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection(kUserMessagesKey).document(uid).collection(kMessagesKey).addSnapshotListener { (querySnapshot, err) in
            guard let documents = querySnapshot?.documents else { return }
            self.messages.removeAll()
            for doc in documents {
                self.db.collection(kMessagesKey).document("\(doc.documentID)").getDocument(completion: { (documentSnapshot, err) in
                    guard let doc = documentSnapshot, let data = doc.data() else { return }
                    let msg = Message(data)
                    
                    if msg.chatPartnerId() == self.user?.id {
                        self.messages.append(msg)
                        self.messages = self.messages.sorted(by: { $0.timestamp?.intValue ?? 0 < $1.timestamp?.intValue ?? 0 })
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
                
                self.inputTextField.text = nil
                
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
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 10000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [kCTFontAttributeName as NSAttributedStringKey: UIFont.systemFont(ofSize: 16)], context: nil)
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
        
        let text = messages[indexPath.row].text
        cell.bubbleViewWidthConstraint.constant = estimateFrameForText(text: text!).width + 18
        cell.configure(message: text)
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
        var height: CGFloat = 80.0
        
        if let text = messages[indexPath.row].text {
            height = estimateFrameForText(text: text).height + 16
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
}
