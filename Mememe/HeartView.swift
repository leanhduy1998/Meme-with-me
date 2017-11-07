//
//  HeartView.swift
//  Mememe
//
//  Created by Duy Le on 8/14/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

class HeartView: UIView {
    var cardNormal: CardNormal!
    var cardNormalJSON: CardNormalJSONModel!
    var liked = false
    
    func get(heartWidth: CGFloat, heartHeight: CGFloat,x: CGFloat, y: CGFloat) -> UIImageView{
        let heartImageView = UIImageView(image: #imageLiteral(resourceName: "heart"))
        
        heartImageView.frame = CGRect(x: x, y: y, width: heartWidth, height: heartHeight)
        heartImageView.clipsToBounds = true
        
        return heartImageView
    }
}
