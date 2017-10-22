//
//  CircleImageCutter.swift
//  Mememe
//
//  Created by Duy Le on 8/4/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

class CircleImageCutter {
    static func roundImageView(imageview: UIImageView, radius: Float) -> UIImageView {
        imageview.layer.masksToBounds = true
        imageview.layer.cornerRadius = CGFloat(radius)
        return imageview
    }
    static func getCircleImageView(imageview: UIImageView) -> UIImageView{
        imageview.layer.cornerRadius = imageview.frame.size.width / 2;
        imageview.clipsToBounds = true
        return imageview
    }
}
