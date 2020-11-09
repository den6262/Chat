//
//  User.swift
//  Chat
//
//  Created by Deniro21 on 7/19/19.
//  Copyright © 2019 Dennis Grishin. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var id: String?
    var email: String?
    var name: String?
    var profileImageUrl: String?
    
    init(dictionary: [String: AnyObject]) {
        self.id = dictionary["id"] as? String
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
    }
    
}
