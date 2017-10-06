//
//  InGameAddMeme.swift
//  Mememe
//
//  Created by Duy Le on 10/6/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension InGameViewController{
    func getLabelNumberOfLines(label: UILabel) -> Int{
        let textSize = CGSize(width: CGFloat(label.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(label.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(label.font.pointSize))
        let lines = rHeight / charSize
        return lines
    }
}
