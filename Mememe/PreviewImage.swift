//
//  PreviewImage.swift
//  Mememe
//
//  Created by Duy Le on 11/7/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

class PreviewImage{
    var image: UIImage!
    var playerId: String!
    var imageEmpty = false
    
    init(playerId: String){
        self.playerId = playerId
    }
}
