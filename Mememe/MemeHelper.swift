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
    
    
    static func get9Memes()->MemeModel{
        if topMemes.count == 0 || bottomMemes.count == 0 || fullMemes.count == 0 {
            return MemeModel()
        }
        var picked = [Int:Int]()
        var top = [String]()
        var bot = [String]()
        var full = [String]()
        
        let memeModel = MemeModel()
        var temp = [Int]()
        
        while(picked.count < topAmount){
            let random = Int(arc4random_uniform(UInt32(topMemes.count)))
            picked[random] = random
        }
        
        for(num,_) in picked {
            top.append(topMemes[num])
            temp.append(num)
        }
        for x in (0...(temp.count-1)).reversed() {
            topMemes.remove(at: x)
        }
        temp.removeAll()
        picked.removeAll()
        
        while(picked.count < bottomAmount){
            let random = Int(arc4random_uniform(UInt32(bottomMemes.count)))
            picked[random] = random
        }
        for(num,_) in picked {
            bot.append(bottomMemes[num])
            temp.append(num)
        }
        for x in (0...(temp.count-1)).reversed() {
            bottomMemes.remove(at: x)
        }
        
        
        temp.removeAll()
        picked.removeAll()
        
        while(picked.count < fullAmount){
            let random = Int(arc4random_uniform(UInt32(fullMemes.count)))
            picked[random] = random
        }
        for(num,_) in picked {
            full.append(fullMemes[num])
            temp.append(num)
        }
        for x in (0...(temp.count-1)).reversed() {
            fullMemes.remove(at: x)
        }
        
        memeModel.topMemes = top
        memeModel.bottomMemes = bot
        memeModel.fullMemes = full
        
        return memeModel
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
                topMemes.remove(at: num)
            }
        }
        if pos == "bot" {
            if temp.count >= bottomAmount {
                return temp
            }
            
            while(picked.count < (bottomAmount-memes.count)){
                let random = Int(arc4random_uniform(UInt32(bottomMemes.count)))
                picked[random] = random
            }
            for(num,_) in picked {
                memes.append(bottomMemes[num])
                bottomMemes.remove(at: num)
            }
        }
        if pos == "full" {
            if temp.count >= fullAmount {
                return temp
            }
            
            while(picked.count < (fullAmount-memes.count)){
                let random = Int(arc4random_uniform(UInt32(fullMemes.count)))
                picked[random] = random
            }
            for(num,_) in picked {
                memes.append(fullMemes[num])
                fullMemes.remove(at: num)
            }
        }
        return memes
    }
    
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
}
