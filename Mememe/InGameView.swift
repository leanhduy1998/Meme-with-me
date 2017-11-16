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
        setFloorBackground()
        
        chatTableView.backgroundColor = UIColor.clear
        
        emptyMessageLabel.layer.masksToBounds = true
        emptyMessageLabel.layer.cornerRadius = 5
        emptyMessageLabel.backgroundColor = UIColor.white
        
        chatTableView.allowsSelection = false
        chatSendBtn.layer.cornerRadius = 5
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
    
    func setAddEditJudgeMemeBtnUI(ceasarId: String, haveWinner: Bool) {
        if haveWinner {
            AddEditJudgeMemeBtn.isEnabled = false
        }
        else {
            checkIfYourAreJudge()
        }
    }
}
