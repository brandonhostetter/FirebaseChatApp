//
//  User.swift
//  FirebaseChatApp
//
//  Created by Brandon Hostetter on 9/8/18.
//  Copyright © 2018 Brandon Hostetter. All rights reserved.
//

import UIKit

class User {
    var id: String  = ""
    var name: String = ""
    var email: String = ""
    var profileImageUrl: String?
    
    init(_ doc: [String: Any], id: String) {
        guard let name = doc["name"], let email = doc["email"] else {
            return
        }
        self.name = name as? String ?? ""
        self.email = email as? String ?? ""
        self.id = id
        
        if let url = doc["profileImageUrl"] as? String {
            self.profileImageUrl = url
        }
    }
}
