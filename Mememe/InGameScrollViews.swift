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
        
        var counter = 0
        for player in playersInGame{
            var userCoreData = Player()
            
            for pCore in (game.players?.allObjects as? [Player])! {
                if(pCore.playerId == player.userId){
                    userCoreData = pCore
                    break
                }
            }
            
            let newX = (self.space * CGFloat(counter+1))  + CGFloat(counter) * self.iconSize
            let userIconIV = UIImageView()
            userIconIV.frame = CGRect(x: newX, y: self.space/4, width: self.iconSize, height: self.iconSize)
            contentWidth += self.space + self.iconSize
    
            counter = counter + 1
            
            let redDotSize = iconSize/4
            let redDotIV = UIImageView(image: #imageLiteral(resourceName: "redCircle"))
            redDotIV.frame = CGRect(x: iconSize/2 - (redDotSize)/2, y: -5, width: redDotSize, height: redDotSize)
            let whiteLabel = UILabel()
            
            var timesWon: Int!
            
            for c in (game.wincounter?.allObjects as? [WinCounter])!{
                if(c.playerId == player.userId){
                    timesWon = Int(c.won)
                    break
                }
            }
            
            whiteLabel.text = "\(timesWon!)"
            whiteLabel.frame = CGRect(x: 0, y: 0, width: redDotSize, height: redDotSize)
            whiteLabel.textAlignment = .center
            whiteLabel.textColor = UIColor.white
            redDotIV.addSubview(whiteLabel)
            
            userIconIV.addSubview(redDotIV)
            userIconIV.bringSubview(toFront: redDotIV)
            
                
            let helper = UserFilesHelper()
            helper.loadUserProfilePicture(userId: player.userId, completeHandler: { (imageData) in
                DispatchQueue.main.async {
                    let image = UIImage(data: imageData)!
                    userIconIV.image = CircleImageCutter.getRoundEdgeImage(image: image, radius: Float(self.iconSize))
                        
                    self.currentPlayersScrollView.addSubview(userIconIV)
                    self.currentPlayersScrollView.sendSubview(toBack: userIconIV)
                        
                    userCoreData.userImageData = imageData as NSData
                    
                    if userCoreData.playerId == self.userWhoWon {
                        self.borderForUserIconIV = self.getBorderIVForIcon(iconSize: self.iconSize)
                        userIconIV.addSubview(self.borderForUserIconIV)
                        userIconIV.bringSubview(toFront: self.borderForUserIconIV)
                    }
                }
            })
            
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
        var contentWidth = 0 + space
        
        let latestRound = GetGameCoreDataData.getLatestRound(game: game)
        
        if(latestRound == nil){
            return
        }
        
        var currentPlayersCards = latestRound.cardnormal?.allObjects as? [CardNormal]
            
        let haveWinner = checkIfWinnerExist(cards: (latestRound.cardnormal?.allObjects as? [CardNormal])!)
        let myCardExist = checkIfMyCardExist(cards: (latestRound.cardnormal?.allObjects as? [CardNormal])!)
        
        let image = UIImage(data: latestRound.cardceasar?.cardPic! as! Data)
            thisRoundImage = image
            
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
                // -40 is for animation
                let emptyCardUIView = CardView(frame: CGRect(x: space, y: space/2 - cardInitialYBeforeAnimation, width: cardWidth, height: cardHeight))
                let emptyIV = UIImageView(frame: CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight))
                emptyIV.image = image
                emptyCardUIView.addSubview(emptyIV)
                emptyCardUIView.sendSubview(toBack: emptyIV)
                
                previewScrollView.addSubview(emptyCardUIView)
                
                emptyCardUIView.alpha = 0.5
                UIView.animate(withDuration: 1, animations: {
                    emptyCardUIView.frame = CGRect(x: emptyCardUIView.frame.origin.x, y: emptyCardUIView.frame.origin.y + self.cardInitialYBeforeAnimation, width: self.cardWidth, height: self.cardHeight)
                    emptyCardUIView.alpha = 1
                })
                
                return
            }
            else if (currentPlayersCards?.count)! == 1 {
                clearPreviewCardsData()
            }
            for x in 0...(((currentPlayersCards?.count)! - 1)) {
                contentWidth += space + cardWidth
                let newX = getNewXForPreviewScroll(x: x, haveWinner: haveWinner)
                        
                let upLabel = getTopLabel(text: (currentPlayersCards?[x].topText)!)
                let downLabel = getBottomLabel(text: (currentPlayersCards?[x].bottomText)!)
                
                // -40 is for animation
                let cardUIView = CardView(frame: CGRect(x: newX, y: space/2-cardInitialYBeforeAnimation, width: cardWidth, height: cardHeight))
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
                    
                    cardUIView.alpha = 0.5
                    
                    UIView.animate(withDuration: 1, animations: {
                        cardUIView.frame = CGRect(x: cardUIView.frame.origin.x, y: cardUIView.frame.origin.y + self.cardInitialYBeforeAnimation, width: self.cardWidth, height: self.cardHeight)
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
                let cardUIView = CardView(frame: CGRect(x: newX, y: space/2 - cardInitialYBeforeAnimation, width:cardWidth, height: cardHeight))
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
}
