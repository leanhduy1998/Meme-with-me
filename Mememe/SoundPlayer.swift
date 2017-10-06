//
//  SoundPlayer.swift
//  Mememe
//
//  Created by Duy Le on 10/5/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import AVFoundation

class SoundPlayer{
    static var audioPlayer:AVAudioPlayer!
    
    private static func play(songName:String){
        let audioFilePath = Bundle.main.path(forResource: songName, ofType: "mp3")
        
        if audioFilePath != nil {
            
            let audioFileUrl = NSURL.fileURL(withPath: audioFilePath!)
            
            do{
                try audioPlayer = AVAudioPlayer(contentsOf: audioFileUrl)
                audioPlayer.numberOfLoops = -1
                audioPlayer.play()
            }
            catch {
                print("???")
            }
            
            
        } else {
            print("audio file is not found")
        }
    }
    
    static func playStartMusic(){
        play(songName: "startMusic")
    }
    static func playAvailableRoomMusic(){
        play(songName: "availableRoomMusic")
    }
    static func playInGameMusic(){
        let random = Int(arc4random_uniform(2))
        if(random == 0){
            play(songName: "inGame")
        }
        else{
            play(songName: "inGame2")
        }
    }
    static func playMessageReceivedSound(){
        play(songName: "availableRoomMusic")
    }
}
