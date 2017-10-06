//
//  InGameExtensionUI.swift
//  Mememe
//
//  Created by Duy Le on 9/21/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension InGameViewController {
    func reloadCurrentPlayersIcon(){
        for v in currentPlayersScrollView.subviews {
            v.removeFromSuperview()
        }
        borderForUserIconIV.removeFromSuperview()
        
        var contentWidth = CGFloat(0)
        // never use currentPlayersScrollView.frame.height, because it uses the height of its storyboard
        iconSize = currentPlayerScrollHeight - space/2
        
        let players = game.players?.allObjects as? [Player]
        
        let lastRound = GetGameCoreDataData.getLatestRound(game: game)
        
        var counter = 0
        for x in players!{
            let newX = (self.space * CGFloat(counter+1))  + CGFloat(counter) * self.iconSize
            let userIconIV = UIImageView()
            userIconIV.frame = CGRect(x: newX, y: self.space/4, width: self.iconSize, height: self.iconSize)
            contentWidth += self.space + self.iconSize
            
            if x.userImageData == nil {
                counter = counter + 1
                
                let helper = UserFilesHelper()
                helper.loadUserProfilePicture(userId: x.playerId!, completeHandler: { (imageData) in
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)!
                        userIconIV.image = CircleImageCutter.getCircleImage(image: image, radius: Float(self.iconSize))
                        
                        self.currentPlayersScrollView.addSubview(userIconIV)
                        self.currentPlayersScrollView.sendSubview(toBack: userIconIV)
                        
                        x.userImageData = imageData as NSData
                        
                        if x.playerId == self.userWhoWon {
                            self.borderForUserIconIV = self.getBorderIVForIcon(iconSize: self.iconSize)
                            userIconIV.addSubview(self.borderForUserIconIV)
                            userIconIV.bringSubview(toFront: self.borderForUserIconIV)
                        }
                    }
                    
                })
            }
                
            else {
                let image =  UIImage(data: (x.userImageData as Data?)!)!
                userIconIV.image = CircleImageCutter.getCircleImage(image: image, radius: Float(iconSize))
                
                currentPlayersScrollView.addSubview(userIconIV)
                currentPlayersScrollView.sendSubview(toBack: userIconIV)
                
                counter = counter + 1
                
                if x.playerId == userWhoWon {
                    borderForUserIconIV = getBorderIVForIcon(iconSize: iconSize)
                    userIconIV.addSubview(borderForUserIconIV)
                    userIconIV.bringSubview(toFront: borderForUserIconIV)
                }
            }
        
            currentPlayersScrollView.bringSubview(toFront: borderForUserIconIV)
        }
        currentPlayersScrollView.contentSize = CGSize(width: contentWidth, height: iconSize)
    }

    func clearPreviewCardsData(){
        for v in previewScrollView.subviews {
            v.removeFromSuperview()
        }
    }
    
    func reloadPreviewCards(){
        var contentWidth = space + cardWidth
        
        let latestRound = GetGameCoreDataData.getLatestRound(game: game)
        
        if(latestRound == nil){
            return
        }
        
        var currentPlayersCards = latestRound.cardnormal?.allObjects as? [CardNormal]
            
        let haveWinner = checkIfWinnerExist(cards: (latestRound.cardnormal?.allObjects as? [CardNormal])!)
        let myCardExist = checkIfMyCardExist(cards: (latestRound.cardnormal?.allObjects as? [CardNormal])!)
        
            
        let image = UIImage(data: latestRound.cardceasar?.cardPic! as! Data)
            thisRoundImage = image
            
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

            let memeImageView = getMemeIV(image: image!)
            
            let ceasarCard = latestRound.cardceasar
            setAddEditJudgeMemeBtnUI(ceasarId: (ceasarCard?.playerId)!, haveWinner: haveWinner)
                
            if (currentPlayersCards?.count)! == 0 {
                let emptyCardUIView = CardView(frame: CGRect(x: space/2, y: space/2, width: cardWidth, height: cardHeight))
                let emptyIV = UIImageView(frame: CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight))
                emptyIV.image = image
                emptyCardUIView.addSubview(emptyIV)
                emptyCardUIView.sendSubview(toBack: emptyIV)
                
                previewScrollView.addSubview(emptyCardUIView)
                return
            }
            for x in 0...(((currentPlayersCards?.count)! - 1)) {
                contentWidth += space + cardWidth
                let newX = getNewXForPreviewScroll(x: x, haveWinner: haveWinner)
                        
                let upLabel = getTopLabel(text: (currentPlayersCards?[x].topText)!)
                let downLabel = getBottomLabel(text: (currentPlayersCards?[x].bottomText)!)
                        
                let cardUIView = CardView(frame: CGRect(x: newX, y: space/2, width: cardWidth, height: cardHeight))
                cardUIView.initCardView(topLabel: upLabel, bottomLabel: downLabel, playerId: (currentPlayersCards?[x].playerId)!, memeIV: memeImageView)
                        
                        
                if currentPlayersCards?[x].playerId != MyPlayerData.id {
                    let heartView = getHeartView(frame: memeImageView.frame, playerCard: (currentPlayersCards?[x])!)
                    cardUIView.addSubview(heartView)
                    cardUIView.bringSubview(toFront: heartView)
                }
                        
                var found = false
                var changed = false
                        
                for v in previewScrollView.subviews{
                    guard let vi = v as? CardView else{
                        continue
                    }
               
                    if(vi.playerId != nil){
                        if vi.playerId == cardUIView.playerId {
                            found = true
                        }
                        if vi.bottomText != cardUIView.bottomText {
                            changed = true
                            break
                        }
                        if vi.topText != cardUIView.topText {
                            changed = true
                            break
                        }
                    }
                }
                    
                if !found || changed{
                    previewScrollView.addSubview(cardUIView)
                    previewScrollView.bringSubview(toFront: cardUIView)
                    
                    cardUIView.alpha = 0
                    UIView.animate(withDuration: 0.5, animations: {
                        cardUIView.alpha = 1
                    })
                }
            }
        }
        else {
            clearPreviewCardsData()
            
            contentWidth = screenWidth
            let newX = getNewXForPreviewScroll(x: 0, haveWinner: haveWinner)
            let memeImageView = getMemeIV(image: image!)
            for card in currentPlayersCards! {
                if !card.didWin {
                    continue
                }
                let cardUIView = CardView(frame: CGRect(x: newX, y: space/2, width:cardWidth, height: cardHeight))
                let upLabel = getTopLabel(text: card.topText!)
                let downLabel = getBottomLabel(text: card.bottomText!)
                cardUIView.initCardView(topLabel: upLabel, bottomLabel: downLabel,playerId: card.playerId!, memeIV: memeImageView)
                    
                let borderIV = getBorderForWinningCard()
                cardUIView.addSubview(borderIV)
                    
                getUserIconView(frame: memeImageView.frame, playerCard: card,completeHandler: { (IV) in
                    cardUIView.addSubview(IV)
                    cardUIView.bringSubview(toFront: IV)
                })
                    
                previewScrollView.addSubview(cardUIView)
                break
        }
    }
        previewScrollView.contentSize = CGSize(width: contentWidth, height: cardHeight)
        
    }
}
