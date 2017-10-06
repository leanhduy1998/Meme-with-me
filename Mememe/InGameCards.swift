//
//  InGameCards.swift
//  Mememe
//
//  Created by Duy Le on 10/5/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension InGameViewController{
    func getCrownIVForCard() -> UIImageView{
        let crownImage = #imageLiteral(resourceName: "ceasarCrown")
        let crownIV = UIImageView(image: crownImage)
        crownIV.frame = CGRect(x: cardWidth - cardHeight/6, y: cardHeight - cardHeight/6, width: cardHeight/6, height: cardHeight/6)
        return crownIV
    }
    func getCrownIVForWinningCard(newX: CGFloat) -> UIImageView{
        let crownImage = #imageLiteral(resourceName: "ceasarCrown")
        let crownIV = UIImageView(image: crownImage)
        crownIV.frame = CGRect(x: newX  + cardHeight/9, y: cardHeight - cardHeight/6, width: cardHeight/6, height: cardHeight/6)
        return crownIV
    }
}
