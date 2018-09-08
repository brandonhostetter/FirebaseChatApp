//
//  NewMessageViewController.swift
//  FirebaseChatApp
//
//  Created by Brandon Hostetter on 9/8/18.
//  Copyright © 2018 Brandon Hostetter. All rights reserved.
//

import UIKit
import Firebase

class NewMessageViewController: UIViewController {
    var db: Firestore!
    var users = [User]()

    @IBOutlet weak var usersTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        db = Util.shared.db

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        
        usersTableView.register(UINib(nibName: kUserTableViewCell, bundle: nil), forCellReuseIdentifier: kUserTableViewCellReuseId)
        
        fetchUser()
    }
    
    private func fetchUser() {
        db.collection(kUsersKey)
        db.collection(kUsersKey).addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
            }
            
            self.users.removeAll()
            for doc in document.documents {
                let user = User(doc.data())
                self.users.append(user)
            }
            
            self.usersTableView.reloadData()
        }
    }
    
    @objc private func cancel() {
        dismiss(animated: true, completion: nil)
    }
}

extension NewMessageViewController: UITableViewDelegate {
    
}

extension NewMessageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
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
        
        let user = users[indexPath.row]
        cell.configure(user)        
        return cell
    }
}
