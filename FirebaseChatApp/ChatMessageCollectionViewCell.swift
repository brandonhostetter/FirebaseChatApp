//
//  ChatMessageCollectionViewCell.swift
//  FirebaseChatApp
//
//  Created by Brandon Hostetter on 9/9/18.
//  Copyright © 2018 Brandon Hostetter. All rights reserved.
//

import UIKit

class ChatMessageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var bubbleView: UIView!
    
    @IBOutlet weak var bubbleViewWidthConstraint: NSLayoutConstraint!
    
    func configure(message: String?) {
        bubbleView.layer.cornerRadius = 5.0
        bubbleView.layer.masksToBounds = true
        bubbleView.backgroundColor = UIColor(r: 0, g: 137, b: 240)

        messageLabel.text = message
        messageLabel.textColor = .white
    }
}
