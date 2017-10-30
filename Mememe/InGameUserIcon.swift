//
//  InGameUserIcon.swift
//  Mememe
//
//  Created by Duy Le on 10/6/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension InGameViewController{
    func getBorderIVForIcon(iconSize: CGFloat) -> UIImageView{
        let crownImage = #imageLiteral(resourceName: "border")
        let crownIV = UIImageView(image: crownImage)
        crownIV.frame = CGRect(x: 0, y: 0, width: iconSize, height: iconSize)
        return crownIV
    }
    
}
