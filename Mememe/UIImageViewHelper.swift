//
//  UIImageViewHelper.swift
//  Mememe
//
//  Created by Duy Le on 8/4/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

class UIImageViewHelper {
    static func roundImageView(imageview: UIImageView, radius: Float) -> UIImageView {
        imageview.layer.masksToBounds = true
        imageview.layer.cornerRadius = CGFloat(radius)
        return imageview
    }
   
}
