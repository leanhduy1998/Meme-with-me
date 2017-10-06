//
//  SoundPlayer.swift
//  Mememe
//
//  Created by Duy Le on 10/5/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class SoundPlayer: NSObject{
    var audioPlayer:AVAudioPlayer!
    
    static let sharedInstance = SoundPlayer()
    
    private func play(songName:String, loop: Bool){
        let audioFilePath = Bundle.main.path(forResource: songName, ofType: "mp3")
        
        if audioFilePath != nil {
            
            let audioFileUrl = NSURL.fileURL(withPath: audioFilePath!)
            
            do{
                try audioPlayer = AVAudioPlayer(contentsOf: audioFileUrl)
                if(loop == true){
                    audioPlayer.numberOfLoops = -1
                }
                else{
                    audioPlayer.numberOfLoops = 1
                }
                audioPlayer.play()
            }
            catch {
                print("???")
            }
            
            
        } else {
            print("audio file is not found")
        }
    }
    
    func playStartMusic(){
        play(songName: "startMusic", loop: true)
    }
    func playAvailableRoomMusic(){
        play(songName: "availableRoomMusic", loop: true)
    }
    func playPrivateRoomMusic(){
        let random = Int(arc4random_uniform(2))
        if(random == 0){
            play(songName: "privateRoomMusic", loop: true)
        }
        else{
            play(songName: "privateRoomMusic2", loop: true)
        }
    }
    func playMessageReceivedSound(){
        play(songName: "messagereceived", loop: false)
    }
}
