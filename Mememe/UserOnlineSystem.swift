//
//  UserOnlineSystem.swift
//  Mememe
//
//  Created by Duy Le on 9/15/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import FirebaseDatabase

class UserOnlineSystem {
    private static var timer = Timer()
    private static let userOnlineStatusRef = Database.database().reference().child("userOnlineStatus")
    static func updateUserOnlineStatus(){
        GetGameData.getCurrentTimeInt { (timeInt) in
            DispatchQueue.main.async {
                userOnlineStatusRef.child(MyPlayerData.id).child("lastActive").setValue(timeInt)
                timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(updateUserTime), userInfo: nil, repeats: true)
                timer.fire()
            }
        }
    }
    @objc private static func updateUserTime(){
        GetGameData.getCurrentTimeInt { (timeInt) in
            let childUpdates = ["\(MyPlayerData.id!)/lastActive": timeInt]
            userOnlineStatusRef.updateChildValues(childUpdates)
        }
    }
    
    static func getUserOnlineStatus(userId: String, completionHandler: @escaping (_ isUserOnline: Bool) -> Void){
        let userOnlineRef = userOnlineStatusRef.child(userId)
        
        userOnlineRef.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let postDict = snapshot.value as? [String : AnyObject] ?? [:]
            for (key,value) in postDict {
                if key == "lastActive" {
                    GetGameData.getCurrentTimeInt(completionHandler: { (timeInt) in
                        if Int(value as! NSNumber) < timeInt - 10 {
                            userOnlineRef.removeValue()
                            completionHandler(false)
                        }
                        else {
                            completionHandler(true)
                        }
                    })
                }
            }
        })
    }
    static func goOffline(){
        if(MyPlayerData.id != nil){
            userOnlineStatusRef.child(MyPlayerData.id).removeValue()
        }
        timer.invalidate()
    }
}
