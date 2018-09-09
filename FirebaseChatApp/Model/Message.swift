//
//  Message.swift
//  FirebaseChatApp
//
//  Created by Brandon Hostetter on 9/9/18.
//  Copyright © 2018 Brandon Hostetter. All rights reserved.
//

import UIKit

class Message {
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    init(_ doc: [String: Any]) {
        guard let fromId = doc["fromId"] as? String,
            let text = doc["text"] as? String,
            let timestamp = doc["timestamp"] as? NSNumber,
            let toId = doc["toId"] as? String
        else {
            return
        }
        
        self.fromId = fromId
        self.text = text
        self.timestamp = timestamp
        self.toId = toId
    }
}
