//
//  UIColor.swift
//  Chat
//
//  Created by Deniro21 on 7/18/19.
//  Copyright © 2019 Dennis Grishin. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat ) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
}
