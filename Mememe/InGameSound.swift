//
//  InGameSound.swift
//  Mememe
//
//  Created by Duy Le on 10/6/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import AVFoundation

extension InGameViewController{
    func playHeartSound(){
        playEffect(songName: "heartbeat", loop: 2, volume: 3, reduceBackgroundVolume: true)
    }
    func playEndRoundSound(){
        playEffect(songName: "endRound", loop: 0, volume: 1, reduceBackgroundVolume: true)
    }
    func playWinningSound(){
        playEffect(songName: "winning", loop: 0, volume: 1, reduceBackgroundVolume: true)
    }
    func playMessageReceivedSound(){
        playEffect(songName: "messagereceived", loop: 0, volume: 1, reduceBackgroundVolume: false)
    }
    func playCardPlacedDown(){
        playEffect(songName: "cardPlacedDown", loop: 0, volume: 1, reduceBackgroundVolume: false)
    }
    
    func playBackground(){
        if(backgroundPlayer != nil && backgroundPlayer.isPlaying){
            return
        }
        
        let random = Int(arc4random_uniform(2))
        var songName:String!
        if(random == 0){
            songName = "inGame"
        }
        else{
            songName = "inGame2"
        }
        
        let audioFilePath = Bundle.main.path(forResource: songName, ofType: "mp3")
        
        if audioFilePath != nil {
            
            let audioFileUrl = NSURL.fileURL(withPath: audioFilePath!)
            
            do{
                try backgroundPlayer = AVAudioPlayer(contentsOf: audioFileUrl)
                backgroundPlayer.delegate = self
                backgroundPlayer.numberOfLoops = -1
                backgroundPlayer.play()
            }
            catch {
                print("???")
            }
        } else {
            print("audio file is not found")
        }
    }
    
    private func playEffect(songName: String, loop: Int, volume: Float, reduceBackgroundVolume: Bool){
        let audioFilePath = Bundle.main.path(forResource: songName, ofType: "mp3")
        if audioFilePath != nil {
            let audioFileUrl = NSURL.fileURL(withPath: audioFilePath!)
            
            do{
                try effectPlayer = AVAudioPlayer(contentsOf: audioFileUrl)
                effectPlayer.delegate = self
                
                if(reduceBackgroundVolume){
                    backgroundPlayer.volume = 0.3
                }
                
                effectPlayer.numberOfLoops = loop
                effectPlayer.volume = volume
                effectPlayer.play()
            }
            catch {
                print("???")
            }
        } else {
            print("audio file is not found")
        }
    }
    
    
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if(player == effectPlayer){
            backgroundPlayer.volume = 1
        }
        else{
            playBackground()
        }
    }
}
