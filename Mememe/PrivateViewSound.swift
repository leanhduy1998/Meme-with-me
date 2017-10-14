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
        backgroundPlayer = SoundPlayerHelper.getAudioPlayer(songName: "privateRoomMusic", loop: true)
        chatSoundPlayer = SoundPlayerHelper.getAudioPlayer(songName: "messagereceived", loop: false)
    }
}
