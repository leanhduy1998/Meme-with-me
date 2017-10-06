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
        crownIV.frame = CGRect(x: -5, y: -5, width: iconSize+10, height: iconSize+10)
        return crownIV
    }
    
}
