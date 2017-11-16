//
//  InGameView.swift
//  Mememe
//
//  Created by Duy Le on 7/31/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension InGameTutController {
    func setupUI() {
        setupDimensions()
        setupPreviewScrollViewConstraints()
        setupChatViewConstraints()
        setupCurrentPlayersScrollViewConstraints()
        chatTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        setupNavigationBar()
        previewScrollView.alwaysBounceHorizontal = true
        currentPlayersScrollView.alwaysBounceHorizontal = true
        setFloorBackground()
        
        chatSendBtn.layer.cornerRadius = 5
        chatTableView.backgroundColor = UIColor.clear
        
        emptyMessageLabel.layer.masksToBounds = true
        emptyMessageLabel.layer.cornerRadius = 5
        emptyMessageLabel.backgroundColor = UIColor.white
        
        chatTableView.allowsSelection = false
    }
    
    func setFloorBackground(){
        var random = Int(arc4random_uniform(UInt32(10)))
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
        // for some reason, the ratio of navigation bar has to be 6/5 for it to not be shorten
        screenHeight = view.frame.size.height - navigationBar.frame.height*6/5
        
        space = screenWidth/24
        
        cardHeight = screenHeight/2 - space
        cardWidth = cardHeight*9/16
        
        previewScrollHeight = cardHeight + space
        chatViewHeight = (screenHeight/2)*3/4
        currentPlayerScrollHeight = (screenHeight/2)/4
        
        cardInitialYBeforeAnimation = cardHeight/2
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    func setupNavigationBar(){
        navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "tempUserIcon"), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.view.backgroundColor = .clear
    }
    
    
    private func setupPreviewScrollViewConstraints(){
        previewScrollView.translatesAutoresizingMaskIntoConstraints = false
        var previewScrollViewConstraintArr = [NSLayoutConstraint]()
        previewScrollViewConstraintArr.append(NSLayoutConstraint(item: previewScrollView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: screenWidth))
        previewScrollViewConstraintArr.append(NSLayoutConstraint(item: previewScrollView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: previewScrollHeight))
        NSLayoutConstraint.activate(previewScrollViewConstraintArr)
    }
    
    
    private func setupChatViewConstraints(){
        chatView.translatesAutoresizingMaskIntoConstraints = false
        
        var chatViewConstraintArr = [NSLayoutConstraint]()
        chatViewConstraintArr.append(NSLayoutConstraint(item: chatView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: screenWidth))
        chatViewConstraintArr.append(NSLayoutConstraint(item: chatView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: chatViewHeight))
        
        NSLayoutConstraint.activate(chatViewConstraintArr)
    }
    
    private func setupCurrentPlayersScrollViewConstraints(){
        currentPlayersScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        var currentPlayersScrollViewConstraintArr = [NSLayoutConstraint]()
        currentPlayersScrollViewConstraintArr.append(NSLayoutConstraint(item: currentPlayersScrollView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: screenWidth))
        currentPlayersScrollViewConstraintArr.append(NSLayoutConstraint(item: currentPlayersScrollView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: currentPlayerScrollHeight))
        
        NSLayoutConstraint.activate(currentPlayersScrollViewConstraintArr)
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
    
    func getNewXForPreviewScroll(x: Int, haveWinner: Bool) -> CGFloat{
        var newX = CGFloat(0)
        if haveWinner {
            newX = screenWidth/2 - cardWidth/2
        }
        else {
            newX =  (space * CGFloat(x+1))  + CGFloat(x) * cardWidth
        }
        return newX
    }
    func getBorderIVForIcon(iconSize: CGFloat) -> UIImageView{
        let crownImage = #imageLiteral(resourceName: "border")
        let crownIV = UIImageView(image: crownImage)
        crownIV.frame = CGRect(x: -5, y: -5, width: iconSize+10, height: iconSize+10)
        return crownIV
    }
    
    func getHeartView(frame: CGRect, playerCard: CardNormal) -> HeartView{
        let heartView = HeartView()
        heartView.cardNormal = playerCard
        heartView.frame = frame
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.loveMemeDoubleTap(sender:)))
        
        tap.numberOfTapsRequired = 2
        tap.delegate = self
        
        heartView.addGestureRecognizer(tap)
        
        return heartView
    }
    
    func loveMemeDoubleTap(sender: UITapGestureRecognizer) {
        if(!step6Finished){
            step7()
            step6Finished = true
        }
        
        let heartView = sender.view as? HeartView
        var loved = false
        
        let cards = GetGameCoreDataData.getLatestRound(game: game).cardnormal?.allObjects as? [CardNormal]
        for card in cards!{
            if(heartView?.cardNormal.playerId == card.playerId){
                let playerloves = card.playerlove?.allObjects as? [PlayerLove]
                for love in playerloves! {
                    if(love.playerId == MyPlayerData.id){
                        loved = true
                        break
                    }
                }
                break
            }
        }
        
        if(!loved){
            let heartWidth = self.cardHeight/5
            let heartHeight = self.cardHeight*2/5
            
            let heartImageView = heartView?.get(heartWidth: heartWidth, heartHeight: heartHeight, x: (heartView?.frame.width)!/2 - heartWidth/2, y: (heartView?.frame.height)!/2 - heartHeight/2)
            heartImageView?.alpha = 0
            UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat], animations: {
                heartImageView?.alpha = 1
                heartImageView?.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
            }, completion: nil)
            self.playHeartSound()
            
            heartView?.liked = true
            heartView?.addSubview(heartImageView!)
            
            let cardNormal = heartView?.cardNormal
            cardNormal?.addToPlayerlove(PlayerLove(playerId: MyPlayerData.id, context: GameStack.sharedInstance.stack.context))
        }
        else{
            if((heartView?.subviews.count)! == 0){
                return
            }
            
            heartView?.subviews[0].removeFromSuperview()
            let cardNormal = heartView?.cardNormal
            
            for pl in (cardNormal?.playerlove?.allObjects)! {
                let playerLove = pl as? PlayerLove
                if playerLove?.playerId == MyPlayerData.id {
                    cardNormal?.removeFromPlayerlove(playerLove!)
                }
            }
        }
    }
    
    func getMemeIV(image:UIImage) -> UIImageView {
        var memeImageView = UIImageView(image:  image)
        memeImageView.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
        memeImageView = UIImageViewHelper.roundImageView(imageview: memeImageView, radius: 5)
        return memeImageView
    }
    func getBorderForWinningCard() -> UIImageView{
        let borderImage = #imageLiteral(resourceName: "border")
        let borderIV = UIImageView(image: borderImage)
        borderIV.frame = CGRect(x:-5, y: -5, width: cardWidth+10, height: cardHeight+10)
        return borderIV
    }
    func getUserIconView(frame: CGRect, playerCard: CardNormal,completeHandler: @escaping (_ IV: UIImageView)-> Void){
        if(playerCard.playerId == MyPlayerData.id){
            s3Helper.loadUserProfilePicture(userId: playerCard.playerId!) { (imageData) in
                DispatchQueue.main.async {
                    let imageview = UIImageView(image: UIImage(data: imageData))
                    imageview.frame = CGRect(x: frame.maxX - self.cardHeight/20, y: frame.minY, width: self.cardHeight/10, height: self.cardHeight/10)
                    completeHandler(imageview)
                }
            }
        }
        else{
            let imageview = UIImageView(image: #imageLiteral(resourceName: "ichooseyou"))
            imageview.frame = CGRect(x: frame.maxX - self.cardHeight/20, y: frame.minY, width: self.cardHeight/10, height: self.cardHeight/10)
            completeHandler(imageview)
        }
        
    }
}

