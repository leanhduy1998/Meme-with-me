//
//  File.swift
//  Mememe
//
//  Created by Duy Le on 10/10/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension InGameTutController{
    func reloadCurrentPlayersIcon(){
        
        for v in currentPlayersScrollView.subviews {
            v.removeFromSuperview()
        }
        borderForUserIconIV.removeFromSuperview()
        
        var contentWidth = CGFloat(0)
        // never use currentPlayersScrollView.frame.height, because it uses the height of its storyboard
        iconSize = currentPlayerScrollHeight - space/2
        
        var counter = 0
        for player in playersInGame{
            let newX = (self.space * CGFloat(counter+1))  + CGFloat(counter) * self.iconSize
            
            var userIconIV = UIImageView(frame: CGRect(x: newX, y: self.space/4, width: self.iconSize, height: self.iconSize))
            
            contentWidth += self.space + self.iconSize
            
            counter = counter + 1
            
            if(player.userId == MyPlayerData.id){
                let image = userImages[player.userId]
                userIconIV.image = image
                userIconIV = CircleImageCutter.roundImageView(imageview: userIconIV, radius: 15)
                
                self.currentPlayersScrollView.addSubview(userIconIV)
                self.currentPlayersScrollView.sendSubview(toBack: userIconIV)
            }
            else {
                userIconIV = CircleImageCutter.roundImageView(imageview: userIconIV, radius: 15)
                userIconIV.image = #imageLiteral(resourceName: "ichooseyou")
                self.currentPlayersScrollView.addSubview(userIconIV)
                self.currentPlayersScrollView.sendSubview(toBack: userIconIV)
            }
            
            if player.userId == self.userWhoWon {
                self.borderForUserIconIV = self.getBorderIVForIcon(iconSize: self.iconSize)
                userIconIV.addSubview(self.borderForUserIconIV)
                userIconIV.bringSubview(toFront: self.borderForUserIconIV)
            }
            currentPlayersScrollView.bringSubview(toFront: borderForUserIconIV)
        }
        currentPlayersScrollView.contentSize = CGSize(width: contentWidth, height: iconSize)
 
 
        /*
        var userIconIV = UIImageView(frame: CGRect(x: 0, y: self.space/4, width: 50, height: currentPlayerScrollHeight))
        userIconIV.image = #imageLiteral(resourceName: "ichooseyou")
        self.currentPlayersScrollView.addSubview(userIconIV)
        currentPlayersScrollView.contentSize = CGSize(width: 100, height: currentPlayerScrollHeight)*/
    }
    
    func clearPreviewCardsData(){
        for v in previewScrollView.subviews {
            v.removeFromSuperview()
        }
    }
    
    func reloadPreviewCards(){
        var contentWidth = 0 + space
        
        let latestRound = GetGameCoreDataData.getLatestRound(game: game)
        
        if(latestRound == nil){
            return
        }
        
        var currentPlayersCards = latestRound.cardnormal?.allObjects as? [CardNormal]
        
        let haveWinner = checkIfWinnerExist(cards: (latestRound.cardnormal?.allObjects as? [CardNormal])!)
        let myCardExist = checkIfMyCardExist(cards: (latestRound.cardnormal?.allObjects as? [CardNormal])!)
        let ceasarCard = latestRound.cardceasar
        
        playerJudging = GetGameCoreDataData.getLatestRound(game: game).cardceasar?.playerId
        
        if !haveWinner {
            if myCardExist {
                var counter = 0
                for card in currentPlayersCards! {
                    if card.playerId == MyPlayerData.id {
                        currentPlayersCards?.insert((currentPlayersCards?.remove(at: counter))!, at: 0)
                        break
                    }
                    counter = counter + 1
                }
            }
            
            setAddEditJudgeMemeBtnUI(ceasarId: (ceasarCard?.playerId)!, haveWinner: haveWinner)
            
            if (currentPlayersCards?.count)! == 0 {
                var iv = UIImageView(image: thisRoundImage)
                iv.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
                iv = CircleImageCutter.roundImageView(imageview: iv, radius: 15)
                
                // -40 is for animation
                let emptyCardUIView = CardView(frame: CGRect(x: space, y: space/2 - cardInitialYBeforeAnimation, width: cardWidth, height: cardHeight))
                emptyCardUIView.backgroundColor = UIColor.gray
                
                emptyCardUIView.addSubview(iv)
                emptyCardUIView.sendSubview(toBack: iv)
                
                previewScrollView.addSubview(emptyCardUIView)
                
                emptyCardUIView.alpha = 0.5
                UIView.animate(withDuration: 1, animations: {
                    emptyCardUIView.frame = CGRect(x: emptyCardUIView.frame.origin.x, y: emptyCardUIView.frame.origin.y + self.cardInitialYBeforeAnimation, width: self.cardWidth, height: self.cardHeight)
                    emptyCardUIView.alpha = 1
                })
                
                return
            }
            for x in 0...(((currentPlayersCards?.count)! - 1)) {
                contentWidth += space + cardWidth
                let newX = getNewXForPreviewScroll(x: x, haveWinner: haveWinner)
                
                let upLabel = getTopLabel(text: (currentPlayersCards?[x].topText)!)
                let downLabel = getBottomLabel(text: (currentPlayersCards?[x].bottomText)!)
                
                // -40 is for animation
                let cardUIView = CardView(frame: CGRect(x: newX, y: 10, width: cardWidth, height: cardHeight))
    
                cardUIView.addSubview(upLabel)
                cardUIView.bringSubview(toFront: upLabel)
                cardUIView.addSubview(downLabel)
                cardUIView.bringSubview(toFront: downLabel)
                
                var iv = UIImageView(image: thisRoundImage)
                iv.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
                iv = CircleImageCutter.roundImageView(imageview: iv, radius: 15)
                
                cardUIView.addSubview(iv)
                cardUIView.sendSubview(toBack: iv)
                
                if currentPlayersCards?[x].playerId != MyPlayerData.id {
                    let heartView = getHeartView(frame: CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight), playerCard: (currentPlayersCards?[x])!)
                    cardUIView.addSubview(heartView)
                    cardUIView.bringSubview(toFront: heartView)
                }
                
                cardUIView.backgroundColor = UIColor.gray
                
                previewScrollView.addSubview(cardUIView)
                previewScrollView.bringSubview(toFront: cardUIView)
            }
        }
        else {
            clearPreviewCardsData()
            
            contentWidth = screenWidth
            let newX = getNewXForPreviewScroll(x: 0, haveWinner: haveWinner)

            for card in currentPlayersCards! {
                if !card.didWin {
                    continue
                }
                let cardUIView = CardView(frame: CGRect(x: newX, y: space/2 - cardInitialYBeforeAnimation, width:cardWidth, height: cardHeight))
                let upLabel = getTopLabel(text: card.topText!)
                let downLabel = getBottomLabel(text: card.bottomText!)
                
                cardUIView.addSubview(upLabel)
                cardUIView.bringSubview(toFront: upLabel)
                cardUIView.addSubview(downLabel)
                cardUIView.bringSubview(toFront: downLabel)
                
                var iv = UIImageView(image: thisRoundImage)
                iv.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
                iv = CircleImageCutter.roundImageView(imageview: iv, radius: 15)
                
                cardUIView.addSubview(iv)
                cardUIView.sendSubview(toBack: iv)
                
                cardUIView.backgroundColor = UIColor.gray
                
                let borderIV = getBorderForWinningCard()
                cardUIView.addSubview(borderIV)
                
                getUserIconView(frame: cardUIView.frame, playerCard: card,completeHandler: { (IV) in
                    cardUIView.addSubview(IV)
                    cardUIView.bringSubview(toFront: IV)
                })
                
                previewScrollView.addSubview(cardUIView)
                
                cardUIView.alpha = 0.5
                
                UIView.animate(withDuration: 1, animations: {
                    cardUIView.frame = CGRect(x: cardUIView.frame.origin.x, y: cardUIView.frame.origin.y + self.cardInitialYBeforeAnimation, width: self.cardWidth, height: self.cardHeight)
                    cardUIView.alpha = 1
                })
                
                break
            }
        }
        previewScrollView.contentSize = CGSize(width: contentWidth, height: cardHeight)
        
    }
    func checkIfWinnerExist(cards: [CardNormal]) -> Bool{
        var haveWinner = false
        for card in cards {
            if card.didWin {
                haveWinner = true
                break
            }
        }
        return haveWinner
    }
    func checkIfMyCardExist(cards: [CardNormal]) -> Bool{
        var myCardExist = false
        for card in cards {
            if card.playerId == MyPlayerData.id {
                myCardExist = true
                break
            }
        }
        return myCardExist
    }
    
    
    
}
