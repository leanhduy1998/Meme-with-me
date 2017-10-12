//
//  PrivateViewSound.swift
//  Mememe
//
//  Created by Duy Le on 10/11/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation

extension PrivateRoomViewController{
    func playBackground(){
        let random = Int(arc4random_uniform(2))
        if(random == 0){
            backgroundPlayer = SoundPlayerHelper.getAudioPlayer(songName: "privateRoomMusic", loop: true)
        }
        else{
            backgroundPlayer = SoundPlayerHelper.getAudioPlayer(songName: "privateRoomMusic2", loop: true)
        }
        chatSoundPlayer = SoundPlayerHelper.getAudioPlayer(songName: "messagereceived", loop: false)
    }
}
