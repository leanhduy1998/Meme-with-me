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

class SoundPlayerHelper: NSObject{
    
    static func getAudioPlayer(songName:String, loop: Bool) -> AVAudioPlayer{
        var audioPlayer:AVAudioPlayer!
        let audioFilePath = Bundle.main.path(forResource: songName, ofType: "mp3")
        
        if audioFilePath != nil {
            
            
            let audioFileUrl = NSURL.fileURL(withPath: audioFilePath!)
            
            do{
                try audioPlayer = AVAudioPlayer(contentsOf: audioFileUrl)
                if(loop == true){
                    audioPlayer.numberOfLoops = -1
                }
                else{
                    audioPlayer.numberOfLoops = 0
                }
            }
            catch {
                print("???")
            }
            
            
        } else {
            print("audio file is not found")
        }
        return audioPlayer
    }
}
