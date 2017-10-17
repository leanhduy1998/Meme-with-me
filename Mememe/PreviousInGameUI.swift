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
    func getUserIconView(game: Game, frame: CGRect, playerCard: CardNormal,completeHandler: @escaping (_ IV: UIImageView)-> Void){
        let players = game.players?.allObjects as? [Player]
        
        var player: Player!
        
        for p in players! {
            if(p.playerId == playerCard.playerId){
                player = p
                break
            }
        }
        
        let imageview = UIImageView()
        imageview.frame = CGRect(x: frame.maxX - self.cardHeight/20, y: frame.minY, width: self.cardHeight/10, height: self.cardHeight/10)
        
        
        if(player.userImageData == nil){
            let helper = UserFilesHelper()
            helper.loadUserProfilePicture(userId: player.playerId!, completeHandler: { (userImageData) in
                imageview.image = UIImage(data: userImageData as! Data)
                completeHandler(imageview)
            })
        }
        else{
            imageview.image = UIImage(data: player.userImageData as! Data)
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
        let memeImageView = UIImageView(image: CircleImageCutter.getRoundEdgeImage(image: image, radius: 5))
        memeImageView.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
        return memeImageView
    }
    func getHeartView(frame: CGRect, playerCard: CardNormal) -> HeartView{
        let heartView = HeartView()
        heartView.cardNormal = playerCard
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
        crownIV.frame = CGRect(x: -5, y: -5, width: iconSize+10, height: iconSize+10)
        return crownIV
    }
}
