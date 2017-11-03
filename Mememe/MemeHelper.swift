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
    private static var topMemes = [String]()
    private static var bottomMemes = [String]()
    private static var fullMemes = [String]()
    
    private static let topAmount = 3
    private static let bottomAmount = 3
    private static let fullAmount = 3
    
    
    static func getAllMemes(completeHandler: @escaping ()-> Void){
        Database.database().reference().child("meme").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let postDic = snapshot.value as? [String:[String]]
            
            for (memePos,memes) in postDic! {
                if memePos == "topMemes" {
                    topMemes = memes
                }
                else if memePos == "bottomMemes" {
                    bottomMemes = memes
                }
                else {
                    fullMemes = memes
                }
            }
            completeHandler()
        })
    }
    
    static func get9Memes()->MemeModel{
        return refillCards(model: MemeModel())
    }
    static func refillCards(model: MemeModel) -> MemeModel{
        model.topMemes = refillPos(temp: model.topMemes, pos: "top")
        model.bottomMemes = refillPos(temp: model.bottomMemes, pos: "bot")
        model.fullMemes = refillPos(temp: model.fullMemes, pos: "full")
        return model
    }
    
    
    private static func refillPos(temp: [String], pos: String) -> [String]{
        var memes = temp
                
        var picked = [Int:Int]()
                
        if pos == "top" {
            if temp.count >= topAmount {
                return temp
            }
            
            while(picked.count < (topAmount-memes.count)){
                let random = Int(arc4random_uniform(UInt32(topMemes.count)))
                picked[random] = random
            }
            
            for(num,_) in picked {
                memes.append(topMemes[num])
            }
            let temp = picked.keys.sorted().reversed()
            for n in temp {
                topMemes.remove(at: n)
            }
            
        }
        else if pos == "bot" {
            if temp.count >= bottomAmount {
                return temp
            }
            
            while(picked.count < (bottomAmount-memes.count)){
                let random = Int(arc4random_uniform(UInt32(bottomMemes.count)))
                picked[random] = random
            }
            
            for(num,_) in picked {
                memes.append(bottomMemes[num])
            }
            
            let temp = picked.keys.sorted().reversed()
            for n in temp {
                bottomMemes.remove(at: n)
            }
        }
        else if pos == "full" {
            if temp.count >= fullAmount {
                return temp
            }
            
            while(picked.count < (fullAmount-memes.count)){
                let random = Int(arc4random_uniform(UInt32(fullMemes.count)))
                picked[random] = random
            }
            for(num,_) in picked {
                memes.append(fullMemes[num])
            }
            let temp = picked.keys.sorted().reversed()
            for n in temp {
                fullMemes.remove(at: n)
            }
        }
        return memes
    }
}
