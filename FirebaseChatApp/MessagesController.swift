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
    var messages = [Message]()
    var messagesDict = [String: Message]()

    @IBOutlet weak var usersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Util.shared.db

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Sign out", style: .plain, target: self, action: #selector(logout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "new_message_icon"), style: .plain, target: self, action: #selector(createNewMessage))
        
        usersTableView.register(UINib(nibName: kUserTableViewCell, bundle: nil), forCellReuseIdentifier: kUserTableViewCellReuseId)

        checkIfUserLoggedIn()
    }
    
    func showChatController(for user: User) {
        let chatLogViewController = ChatLogViewController(nibName: kChatLogView, bundle: nil)
        chatLogViewController.user = user
        navigationController?.pushViewController(chatLogViewController, animated: true)
    }
    
    func fetchUserAndSetupNavBarTitle() {
        self.messages.removeAll()
        self.messagesDict.removeAll()
        self.usersTableView.reloadData()
        observeMessages()

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
    
    private func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        db.collection(kUserMessagesKey).document("\(uid)").collection(kMessagesKey).addSnapshotListener({ (querySnapshot, err) in
            guard let documents = querySnapshot?.documents else { return }
            
            for doc in documents {
                self.db.collection(kMessagesKey).document("\(doc.documentID)").getDocument(completion: { (documentSnapshot, err) in
                    guard let doc = documentSnapshot, let data = doc.data() else { return }
                    self.messages.removeAll()
                    
                    let msg = Message(data)
                    
                    if let chatPartnerId = msg.chatPartnerId() {
                        self.messagesDict[chatPartnerId] = msg
                    }
                    
                    self.messages = Array(self.messagesDict.values)
                    self.messages = self.messages.sorted(by: { $0.timestamp?.intValue ?? 0 > $1.timestamp?.intValue ?? 0 })
                    
                    self.usersTableView.reloadData()
                })
            }
        })
    }
    
    @objc private func createNewMessage() {
        let newMessageViewController = NewMessageViewController(nibName: kNewMessageView, bundle: nil)
        let navigationController = UINavigationController(rootViewController: newMessageViewController)
        newMessageViewController.messagesController = self
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

extension MessagesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        guard let chatPartnerId = message.chatPartnerId() else { return }
        
        db.collection(kUsersKey).document(chatPartnerId).getDocument { (documentSnapshot, err) in
            guard let data = documentSnapshot?.data() else { return }
            let user = User(data, id: chatPartnerId)
            self.showChatController(for: user)
        }
    }
}

extension MessagesController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UserTableViewCell!
        cell = tableView.dequeueReusableCell(withIdentifier: kUserTableViewCellReuseId, for: indexPath) as? UserTableViewCell
        
        if cell == nil {
            cell = UserTableViewCell(style: .default, reuseIdentifier: kUserTableViewCellReuseId)
        }

        cell.configureAsFriend(self.messages[indexPath.row])
        return cell
    }
}
