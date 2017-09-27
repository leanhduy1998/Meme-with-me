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
        chatTextView.layer.cornerRadius = space
        setupNavigationBar()
    }
    
    
    func setupDimensions(){
        screenWidth = view.frame.size.width
        screenHeight = view.frame.size.height - navigationBar.frame.height

        cardWidth = (screenWidth / 2) - (space * 2)
        cardHeight = screenHeight/2 - space
        
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
    
    func getCrownIVForCard() -> UIImageView{
        let crownImage = #imageLiteral(resourceName: "ceasarCrown")
        let crownIV = UIImageView(image: crownImage)
        crownIV.frame = CGRect(x: -space, y: cardHeight*4/5, width: cardWidth + space*2, height: cardHeight/4)
        return crownIV
    }
    func getCrownIVForIcon(newX: CGFloat) -> UIImageView{
        let crownImage = #imageLiteral(resourceName: "ceasarCrown")
        let crownIV = UIImageView(image: crownImage)
        crownIV.frame = CGRect(x: newX, y: iconSize*4/5, width: iconSize + space*2, height: iconSize/4)
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
        
        if heartView?.subviews.count == 0 {
            let heartWidth = cardHeight/5
            let heartHeight = cardHeight*2/5
            
            let heartImageView = heartView?.get(heartWidth: heartWidth, heartHeight: heartHeight, x: (heartView?.frame.width)!/2 - heartWidth/2, y: (heartView?.frame.height)!/2 - heartHeight/2)
            
            heartView?.addSubview(heartImageView!)
            
            let cardNormal = heartView?.cardNormal
            cardNormal?.addToPlayerlove(PlayerLove(playerId: MyPlayerData.id, context: GameStack.sharedInstance.stack.context))
            GameStack.sharedInstance.saveContext(completeHandler: {})
        }
        else {
            heartView?.subviews[0].removeFromSuperview()
            let cardNormal = heartView?.cardNormal
            for pl in (cardNormal?.playerlove?.allObjects)! {
                let playerLove = pl as? PlayerLove
                if playerLove?.playerId == MyPlayerData.id {
                    cardNormal?.removeFromPlayerlove(playerLove!)
                    GameStack.sharedInstance.saveContext(completeHandler: {})
                }
            }
        }
    }
    
    func getNewXForPreviewScroll(x: Int, haveWinner: Bool) -> CGFloat{
        var newX = CGFloat(0)
        if haveWinner {
            newX = (space * CGFloat(x+1))  + CGFloat(x) * cardWidth
        }
        else {
            newX = space + cardWidth + (space * CGFloat(x+1))  + CGFloat(x) * cardWidth
        }
        return newX
    }
    
    func setAddEditJudgeMemeBtnUI(ceasarId: String, haveWinner: Bool) {
        if haveWinner {
            AddEditJudgeMemeBtn.isEnabled = false
        }
        else {
            AddEditJudgeMemeBtn.isEnabled = true
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
