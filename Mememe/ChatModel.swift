//
//  ChatModel.swift
//  Mememe
//
//  Created by Duy Le on 9/29/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

class ChatModel{
    var senderId:String!
    var senderName: String!
    var text: String!
    
    init(senderId: String, senderName: String, text: String){
        self.senderId = senderId
        self.senderName = senderName
        self.text = text
    }
    init(){
        
    }
}
