//
//  PreviousInGameUI.swift
//  Mememe
//
//  Created by Duy Le on 10/13/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension PreviewInGameViewController{
    func getUserIconView(round: Round, frame: CGRect, playerCard: CardNormal,completeHandler: @escaping (_ IV: UIImageView)-> Void){
        var players = round.players?.allObjects as? [Player]
        
        let game = self.game as? Game
        
        if players?.count == 0 {
            players = game?.players?.allObjects as? [Player]
        }

        var player: Player!
        
        for p in players! {
            if(p.playerId == playerCard.playerId){
                player = p
                break
            }
        }
        
        let imageview = UIImageView()
        imageview.frame = CGRect(x: frame.maxX - self.cardHeight/20, y: frame.minY, width: self.cardHeight/10, height: self.cardHeight/10)
        
        let image = FileManagerHelper.getImageFromMemory(imagePath: player.imageStorageLocation!)
        if image == #imageLiteral(resourceName: "ichooseyou") {
            helper.loadUserProfilePicture(userId: player.playerId!, completeHandler: { (imageData) in
                DispatchQueue.main.async {
                    let image = UIImage(data: (UIImage(data: imageData)?.jpeg(UIImage.JPEGQuality.lowest))!)
                    imageview.image = image
                    completeHandler(imageview)
                }
            })
        }
        else{
            imageview.image = image
            completeHandler(imageview)
        }
    }
    
    func getUserIconView(round: RoundJSONModel, frame: CGRect, playerCard: CardNormalJSONModel,completeHandler: @escaping (_ IV: UIImageView)-> Void){
        var players = round.players
        
        let game = self.game as? GameJSONModel
        
        if players.count == 0 {
            players = (game?.player)!
        }
        
        var player: PlayerJSONModel!
        
        for p in players {
            if(p.playerId == playerCard.playerId){
                player = p
                break
            }
        }
        
        let imageview = UIImageView()
        imageview.frame = CGRect(x: frame.maxX - self.cardHeight/20, y: frame.minY, width: self.cardHeight/10, height: self.cardHeight/10)
        
        let image = FileManagerHelper.getImageFromMemory(imagePath: player.userImageLocation)
        if image == #imageLiteral(resourceName: "ichooseyou") {
            helper.loadUserProfilePicture(userId: player.playerId!, completeHandler: { (imageData) in
                DispatchQueue.main.async {
                    let image = UIImage(data: (UIImage(data: imageData)?.jpeg(UIImage.JPEGQuality.lowest))!)
                    imageview.image = image
                    completeHandler(imageview)
                }
            })
        }
        else{
            imageview.image = image
            completeHandler(imageview)
        }
    }
    
    
    func getBorderForWinningCard() -> UIImageView{
        let borderImage = #imageLiteral(resourceName: "border")
        let borderIV = UIImageView(image: borderImage)
        borderIV.frame = CGRect(x:-5, y: -5, width: cardWidth+10, height: cardHeight+10)
        return borderIV
    }
    func getMemeIV(image:UIImage) -> UIImageView {
        var memeImageView = UIImageView(image: image)
        
        memeImageView.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
        memeImageView = UIImageViewHelper.roundImageView(imageview: memeImageView, radius: 5)
        return memeImageView
    }
    func getHeartView(frame: CGRect, playerCard: CardNormal) -> HeartView{
        let heartView = HeartView()
        heartView.cardNormal = playerCard
        heartView.frame = frame
        
        return heartView
    }
    func getHeartView(frame: CGRect, playerCard: CardNormalJSONModel) -> HeartView{
        let heartView = HeartView()
        heartView.cardNormalJSON = playerCard
        heartView.frame = frame
        
        return heartView
    }
    
    func getTopLabel(text: String) -> UILabel {
        let upLabel = UILabel(frame: CGRect(x: space, y: 0, width: cardWidth - space*2, height: cardHeight/4))
        MemeLabelConfigurer.configureMemeLabel(upLabel, defaultText: text)
        return upLabel
    }
    func getBottomLabel(text: String) -> UILabel {
        let downLabel = UILabel(frame: CGRect(x: space, y: cardHeight*3/4, width: cardWidth - space*2, height: cardHeight/4))
        MemeLabelConfigurer.configureMemeLabel(downLabel, defaultText: text)
        return downLabel
    }
    
    func getNewXForPreviewScroll(x: Int) -> CGFloat{
        return (space*2 * CGFloat(x+1))  + CGFloat(x) * cardWidth
    }
    func setFloorBackground(){
        var random = Int(arc4random_uniform(UInt32(11)))
        random += 1
        let floorImageName = "floor\(random)"
        floorBackground.image = UIImage(named: floorImageName)
        
        random = Int(arc4random_uniform(UInt32(5)))
        random += 1
        let userFloorImageName = "userFloor\(random)"
        currentPlayersScrollView.backgroundColor = UIColor(patternImage: UIImage(named:userFloorImageName)!)
    }
    func setupDimensions(){
        screenWidth = view.frame.size.width
        space = screenWidth/24
        
        // 44*2 is the size of two navigation bars
        cardHeight = previewScrollView.frame.height - 44*2
        cardWidth = cardHeight*9/16
        
        cardInitialYBeforeAnimation = cardHeight/2
    }
    func getBorderIVForIcon(iconSize: CGFloat) -> UIImageView{
        let crownImage = #imageLiteral(resourceName: "border")
        let crownIV = UIImageView(image: crownImage)
        crownIV.frame = CGRect(x: 0, y: 0, width: iconSize, height: iconSize)
        return crownIV
    }
}
