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
        crownUserIconIV.removeFromSuperview()
        
        var contentWidth = CGFloat(0)
        // never use currentPlayersScrollView.frame.height, because it uses the height of its storyboard
        iconSize = currentPlayerScrollHeight - space/2
        
        let players = game.players?.allObjects as? [Player]
        
        let lastRound = GetGameCoreDataData.getLatestRound(game: game)
        let ceasarCard = lastRound.cardceasar as? CardCeasar
        
        var counter = 0
        for x in players!{
            if x.userImageData == nil {
                let helper = UserFilesHelper()
                helper.loadUserProfilePicture(userId: x.playerId!, completeHandler: { (imageData) in
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)!
                        
                        let imageView = UIImageView(image: CircleImageCutter.getCircleImage(image: image, radius: Float(self.iconSize)))
                        
                        let newX = (self.space * CGFloat(counter+1))  + CGFloat(counter) * self.iconSize
                        self.currentPlayersScrollView.addSubview(imageView)
                        self.currentPlayersScrollView.sendSubview(toBack: imageView)
                        
                        imageView.frame = CGRect(x: newX, y: self.space/4, width: self.iconSize, height: self.iconSize)
                        contentWidth += self.space + self.iconSize
                        counter = counter + 1
                        
                        x.userImageData = imageData as NSData
                        
                        if x.playerId == ceasarCard?.playerId {
                            self.crownUserIconIV = self.getCrownIVForIcon(newX: newX)
                            self.currentPlayersScrollView.addSubview(self.crownUserIconIV)
                            self.currentPlayersScrollView.bringSubview(toFront: self.crownUserIconIV)
                        }
                    }
                    
                })
            }
                
            else {
                let image =  UIImage(data: (x.userImageData as Data?)!)!
                let imageView = UIImageView(image: CircleImageCutter.getCircleImage(image: image, radius: Float(iconSize)))
                
                let newX = (space * CGFloat(counter+1))  + CGFloat(counter) * iconSize
                currentPlayersScrollView.addSubview(imageView)
                currentPlayersScrollView.sendSubview(toBack: imageView)
                
                imageView.frame = CGRect(x: newX, y: space/2, width: iconSize, height: iconSize)
                contentWidth += space + iconSize
                counter = counter + 1
                
                if x.playerId == ceasarCard?.playerId {
                    crownUserIconIV = getCrownIVForIcon(newX: newX)
                    currentPlayersScrollView.addSubview(crownUserIconIV)
                    self.currentPlayersScrollView.bringSubview(toFront: crownUserIconIV)
                }
            }
        
            currentPlayersScrollView.bringSubview(toFront: crownUserIconIV)
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
        
        if latestRound != nil {
            var currentPlayersCards = latestRound.cardnormal?.allObjects as? [CardNormal]
            
            let haveWinner = checkIfWinnerExist(cards: (latestRound.cardnormal?.allObjects as? [CardNormal])!)
            let myCardExist = checkIfMyCardExist(cards: (latestRound.cardnormal?.allObjects as? [CardNormal])!)
            
            
            
            let image = UIImage(data: latestRound.cardceasar?.cardPic! as! Data)
            thisRoundImage = image
            
            playerJudging = GetGameCoreDataData.getLatestRound(game: game).cardceasar?.playerId
            
            
            if !haveWinner {
                let ceasarCardUIView = CardView(frame: CGRect(x: space/2, y: space/2, width: cardWidth, height: cardHeight))
                let crownIV = getCrownIVForCard()
                ceasarCardUIView.addSubview(crownIV)
                ceasarCardUIView.bringSubview(toFront: crownIV)
                
                let ceasarIV = UIImageView(frame: CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight))
                ceasarIV.image = image
                ceasarCardUIView.addSubview(ceasarIV)
                ceasarCardUIView.sendSubview(toBack: ceasarIV)
                
                if myCardExist {
                    var counter = 0
                    for card in currentPlayersCards! {
                        if card.playerId == MyPlayerData.id {
                            currentPlayersCards?.insert((currentPlayersCards?.remove(at: counter))!, at: 0)
                            break
                        }
                        counter = counter + 1
                    }
                    AddEditJudgeMemeBtn.title = "Edit Your Meme"
                }
                

                previewScrollView.addSubview(ceasarCardUIView)
                
                let memeImageView = getMemeIV(image: image!)
                
                if (currentPlayersCards?.count)! > 0 {
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
                            if let vi = v as? CardView {
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
                        }
                        
                        if !found{
                            previewScrollView.addSubview(cardUIView)
                            cardUIView.alpha = 0
                            UIView.animate(withDuration: 0.5, animations: {
                                cardUIView.alpha = 1
                            })
                        }
                        else if(changed){
                            previewScrollView.addSubview(cardUIView)
                            cardUIView.alpha = 0
                            UIView.animate(withDuration: 0.5, animations: {
                                cardUIView.alpha = 1
                            })
                        }
                    }
                }
            
                let ceasarCard = latestRound.cardceasar
                setAddEditJudgeMemeBtnUI(ceasarId: (ceasarCard?.playerId)!, haveWinner: haveWinner)
            }
            
            else {
                clearPreviewCardsData()
                
                contentWidth = screenWidth
                let newX = getNewXForPreviewScroll(x: 0, haveWinner: haveWinner)
                
                let memeImageView = getMemeIV(image: image!)
                
                for card in currentPlayersCards! {
                    if card.didWin {
                        let cardUIView = CardView(frame: CGRect(x: newX, y: space/2, width: cardWidth, height: cardHeight))
                        let upLabel = getTopLabel(text: card.topText!)
                        let downLabel = getBottomLabel(text: card.bottomText!)
                        cardUIView.initCardView(topLabel: upLabel, bottomLabel: downLabel, playerId: card.playerId!, memeIV: memeImageView)
                        
                        let crownIV = getCrownIVForWinningCard(newX: newX)
                        cardUIView.addSubview(crownIV)
                        
                        getUserIconView(frame: memeImageView.frame, playerCard: card, completeHandler: { (IV) in
                            cardUIView.addSubview(IV)
                            cardUIView.bringSubview(toFront: IV)
                        })
                        
                        previewScrollView.addSubview(cardUIView)
                        break
                    }
                }
            }
        }
        
        previewScrollView.contentSize = CGSize(width: contentWidth, height: cardHeight)
        
    }
}
