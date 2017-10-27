//
//  CardView.swift
//  Mememe
//
//  Created by Duy Le on 8/16/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class CardView: UIView {
    var playerId: String!
    var topText: String!
    var bottomText: String!
    var topLabel: UILabel!
    var bottomLabel: UILabel!
    var memeIV: UIImageView!
    var haveHeartView: Bool!
    
    func initCardView(topLabel: UILabel, bottomLabel:UILabel, playerId: String, memeIV: UIImageView){
        topText = topLabel.text
        bottomText = bottomLabel.text
        self.playerId = playerId
        self.memeIV = memeIV
        self.topLabel = topLabel
        self.bottomLabel = bottomLabel
        self.haveHeartView = false
        
        
        self.addSubview(topLabel)
        self.bringSubview(toFront: topLabel)
        self.addSubview(bottomLabel)
        self.bringSubview(toFront: bottomLabel)
        
        self.addSubview(self.memeIV)
        self.sendSubview(toBack: self.memeIV)
    }
}
