//
//  UserTableViewCell.swift
//  FirebaseChatApp
//
//  Created by Brandon Hostetter on 9/8/18.
//  Copyright © 2018 Brandon Hostetter. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class UserTableViewCell: UITableViewCell {
    var db: Firestore!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    func configure(_ user: User) {
        nameLabel.text = user.name
        emailLabel.text = user.email
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.clipsToBounds = true
        
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
        }
    }
    
    func configureAsFriend(_ message: Message) {
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        db = Util.shared.db
        let userRef = db.collection(kUsersKey).document(chatPartnerId)
        userRef.getDocument { (document, error) in
            if let document = document, document.exists, let data: [String: Any] = document.data() {
                let user = User(data, id: chatPartnerId)
                self.nameLabel.text = user.name
                self.emailLabel.text = message.text
                self.profileImageView.layer.cornerRadius = self.profileImageView.frame.width / 2
                self.profileImageView.clipsToBounds = true
                
                if let seconds = message.timestamp?.doubleValue {
                    let timestampDate = Date(timeIntervalSince1970: seconds)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "h:mm a"
                    self.timeLabel.text = dateFormatter.string(from: timestampDate)
                }
                
                if let profileImageUrl = user.profileImageUrl {
                    self.profileImageView.loadImageUsingCacheWith(urlString: profileImageUrl)
                }
            } else {
                print("Document does not exist")
            }
        }
    }
}
