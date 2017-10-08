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
        chatRef.removeAllObservers()
    }
    func initializeChatObserver(controller: PrivateRoomViewController){
        let chatRef = Database.database().reference().child("chat")
        chatRef.child(id!).observe(DataEventType.childAdded, with: { (snapshot) in
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
                
                let audioFilePath = Bundle.main.path(forResource: "messagereceived", ofType: "mp3")
                if audioFilePath != nil {
                    let audioFileUrl = NSURL.fileURL(withPath: audioFilePath!)
                    var effectPlayer: AVAudioPlayer!
                    do{
                        try effectPlayer = AVAudioPlayer(contentsOf: audioFileUrl)
                        effectPlayer.play()
                    }
                    catch {
                        print("???")
                    }
                } else {
                    print("audio file is not found")
                }

                DispatchQueue.main.async {
                    if(controller.chatHelper.messages.count > 0){
                        let indexPath = IndexPath(row: controller.chatHelper.messages.count-1, section: 0)
                        controller.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
        })
    }
    func initializeChatObserver(controller: InGameViewController){
        let chatRef = Database.database().reference().child("chat")
        chatRef.child(id!).observe(DataEventType.childAdded, with: { (snapshot) in
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
    }
    func removeChatRoom(id: String){
        chatRef.child(id).removeValue()
    }
}
