//
//  MemeHelper.swift
//  Mememe
//
//  Created by Duy Le on 10/27/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import Firebase

class MemeHelper {
    private static var memes = [String]()
    static func get7Memes()->[String]{
        if memes.count == 0 {
            return []
        }
        
        var picked = [Int:Int]()
        while(picked.count < 7){
            let random = Int(arc4random_uniform(UInt32(memes.count)))
            picked[random] = random
        }
        var returnMeme = [String]()
        for(num,_) in picked {
            returnMeme.append(memes[num])
        }
        return returnMeme
    }
    static func getAllMemes(){
        Database.database().reference().child("meme").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            memes = (snapshot.value as? [String])!
        })
    }
}
