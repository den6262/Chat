//
//  Message.swift
//  Chat
//
//  Created by Deniro21 on 7/31/19.
//  Copyright © 2019 Dennis Grishin. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

class Message: NSObject {
    
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    
    var videoUrl: String?
    
    var imageUrl: String?
    var imageWidth: Float?
    var imageHeight: Float?
    
    init(dictionary: [String: AnyObject]) {
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.toId = dictionary["toId"] as? String
        self.imageUrl = dictionary["imageUrl"] as? String
        self.imageWidth = dictionary["imageWidth"] as? Float
        self.imageHeight = dictionary["imageHeight"] as? Float
        self.videoUrl = dictionary["videoUrl"] as? String
    }
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
}
