//
//  PrivateRoomChat.swift
//  Mememe
//
//  Created by Duy Le on 9/29/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import Firebase
import AVFoundation

class ChatHelper {
    private let chatRef = Database.database().reference().child("chat")
    var id: String?
    var messages = [ChatModel]()
    
    var chatObservers = [UInt]()

    init(id:String) {
        self.id = id
    }
    init() {
    }
    func insertMessage(text:String){
        let message = ["senderId":MyPlayerData.id,"senderName":MyPlayerData.name,"text":text]
        chatRef.child(id!).childByAutoId().setValue(message)
    }
    func removeChatObserver(){
        for o in chatObservers{
            chatRef.removeObserver(withHandle: o)
        }
    }
    func initializeChatObserver(controller: PrivateRoomViewController){
        let chatRef = Database.database().reference().child("chat")
        let observer = chatRef.child(id!).observe(DataEventType.childAdded, with: { (snapshot) in
            DispatchQueue.main.async {
                let messageDict = snapshot.value as? [String:String]
                let message = ChatModel()
                for(key,value) in messageDict! {
                    if(key == "senderId"){
                        message.senderId = value
                    }
                    else if(key == "senderName"){
                        message.senderName = value
                    }
                    else{
                        message.text = value
                    }
                }
                self.messages.append(message)
                controller.chatTableView.reloadData()
                
                if let c = controller as? PrivateRoomViewController {
                    c.chatSoundPlayer.play()
                }
                if let c = controller as? InGameViewController {
                    c.playMessageReceivedSound()
                }

                DispatchQueue.main.async {
                    if(controller.chatHelper.messages.count > 0){
                        let indexPath = IndexPath(row: controller.chatHelper.messages.count-1, section: 0)
                        controller.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
        })
        chatObservers.append(observer)
    }
    func initializeChatObserver(controller: InGameViewController){
        let chatRef = Database.database().reference().child("chat")
        let observer = chatRef.child(id!).observe(DataEventType.childAdded, with: { (snapshot) in
            DispatchQueue.main.async {
                let messageDict = snapshot.value as? [String:String]
                let message = ChatModel()
                for(key,value) in messageDict! {
                    if(key == "senderId"){
                        message.senderId = value
                    }
                    else if(key == "senderName"){
                        message.senderName = value
                    }
                    else{
                        message.text = value
                    }
                }
                self.messages.append(message)
                controller.chatTableView.reloadData()
                DispatchQueue.main.async {
                    if(controller.chatHelper.messages.count > 0){
                        let indexPath = IndexPath(row: controller.chatHelper.messages.count-1, section: 0)
                        controller.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
        })
        chatObservers.append(observer)
    }
    func removeChatRoom(id: String){
        chatRef.child(id).removeValue()
    }
}
