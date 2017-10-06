//
//  InGameView.swift
//  Mememe
//
//  Created by Duy Le on 7/31/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension InGameViewController {
    func setupUI() {
        setupDimensions()
        setupPreviewScrollViewConstraints()
        setupChatViewConstraints()
        setupCurrentPlayersScrollViewConstraints()
        chatTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        setupNavigationBar()
        previewScrollView.alwaysBounceHorizontal = true
        currentPlayersScrollView.alwaysBounceHorizontal = true
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
    
    
    func getCrownIVForIcon(newX: CGFloat) -> UIImageView{
        let crownImage = #imageLiteral(resourceName: "ceasarCrown")
        let crownIV = UIImageView(image: crownImage)
        crownIV.frame = CGRect(x: newX + iconSize/2 - iconSize/4, y: 0, width: iconSize/2, height: iconSize/2)
        return crownIV
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
    func getMemeIV(image:UIImage) -> UIImageView {
        let memeImageView = UIImageView(image: CircleImageCutter.getCircleImage(image: image, radius: 5))
        memeImageView.frame = CGRect(x: 0, y: 0, width: cardWidth, height: cardHeight)
        return memeImageView
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
        let heartView = sender.view as? HeartView
        
        InGameHelper.checkIfYouLikedSomeonesCard(gameId: game.gameId!, cardId: (heartView?.cardNormal.playerId)!) { (youLiked) in
            DispatchQueue.main.async {
                if !youLiked {
                    let heartWidth = self.cardHeight/5
                    let heartHeight = self.cardHeight*2/5
                    
                    let heartImageView = heartView?.get(heartWidth: heartWidth, heartHeight: heartHeight, x: (heartView?.frame.width)!/2 - heartWidth/2, y: (heartView?.frame.height)!/2 - heartHeight/2)
                    heartImageView?.alpha = 0
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse, .repeat], animations: {
                        heartImageView?.alpha = 1
                        heartImageView?.transform = CGAffineTransform(scaleX: 0.80, y: 0.80)
                    }, completion: nil)
                    
                    heartView?.liked = true
                    heartView?.addSubview(heartImageView!)
                    
                    let cardNormal = heartView?.cardNormal
                    cardNormal?.addToPlayerlove(PlayerLove(playerId: MyPlayerData.id, context: GameStack.sharedInstance.stack.context))
                    
                    GameStack.sharedInstance.saveContext(completeHandler: {
                        DispatchQueue.main.async {
                            InGameHelper.likeSomeoOneCard(gameId: self.game.gameId!, cardId: (cardNormal?.playerId)!)
                        }
                    })
                }
                else {
                    if((heartView?.subviews.count)! == 0){
                        return
                    }
                
                    heartView?.subviews[0].removeFromSuperview()
                    let cardNormal = heartView?.cardNormal
                        
                    InGameHelper.unlikeSomeoOneCard(gameId: self.game.gameId!, cardId: (cardNormal?.playerId)!)
                        
                    for pl in (cardNormal?.playerlove?.allObjects)! {
                        let playerLove = pl as? PlayerLove
                        if playerLove?.playerId == MyPlayerData.id {
                            cardNormal?.removeFromPlayerlove(playerLove!)
                                
                            GameStack.sharedInstance.saveContext(completeHandler: {
                                DispatchQueue.main.async {
                                }
                            })
                        }
                    }
                }
            }
        }
    }
    
    func getUserIconView(frame: CGRect, playerCard: CardNormal,completeHandler: @escaping (_ IV: UIImageView)-> Void){
        s3Helper.loadUserProfilePicture(userId: playerCard.playerId!) { (imageData) in
            DispatchQueue.main.async {
                let imageview = UIImageView(image: UIImage(data: imageData))
                imageview.frame = CGRect(x: frame.maxX - self.cardHeight/20, y: frame.minY, width: self.cardHeight/10, height: self.cardHeight/10)
                imageview.alpha = 0.75
                completeHandler(imageview)
            }
        }
    }
    
    func getNewXForPreviewScroll(x: Int, haveWinner: Bool) -> CGFloat{
        var newX = CGFloat(0)
        if haveWinner {
            newX = screenWidth/2 - cardWidth/2
        }
        else {
            newX =  (space/2 * CGFloat(x+1))  + CGFloat(x) * cardWidth
        }
        return newX
    }
    
    func setAddEditJudgeMemeBtnUI(ceasarId: String, haveWinner: Bool) {
        if haveWinner {
            AddEditJudgeMemeBtn.isEnabled = false
        }
        else {
            checkIfYourAreJudge()
        }
    }
    
    func getLabelNumberOfLines(label: UILabel) -> Int{
        let textSize = CGSize(width: CGFloat(label.frame.size.width), height: CGFloat(MAXFLOAT))
        let rHeight: Int = lroundf(Float(label.sizeThatFits(textSize).height))
        let charSize: Int = lroundf(Float(label.font.pointSize))
        let lines = rHeight / charSize
        return lines
    }
}
