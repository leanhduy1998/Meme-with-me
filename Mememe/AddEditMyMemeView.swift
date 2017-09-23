//
//  AddEditMyMemeView.swift
//  Mememe
//
//  Created by Duy Le on 8/14/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension AddEditMyMemeViewController {
    func setupUI(){
        imageviewHeight = (self.view.frame.height-navigationBar.frame.height)*3/5
        
        setupImageView()
        imageview.image = memeImage
        
        
        // for width, change the constraint in storyboard instead for labels
        topLabel.frame = CGRect(x: 10, y: 10, width: imageview.frame.width, height: imageviewHeight/8)
        bottomLabel.frame = CGRect(x: 10, y: 10 + imageviewHeight * 2/3, width: imageview.frame.width, height: imageviewHeight/8)
        
        // for some reason, the text need to have a space in it to make the animation works
        MemeLabelConfigurer.configureMemeLabel(topLabel, defaultText: " ")
        MemeLabelConfigurer.configureMemeLabel(bottomLabel, defaultText: " ")
        
        let latestRound = GetGameCoreDataData.getLatestRound(game: game)
        
        let cardNormals = latestRound.cardnormal?.allObjects as? [CardNormal]
        
        for card in cardNormals! {
            if card.playerId == myPlayerId {
                MemeLabelConfigurer.configureMemeLabel(topLabel, defaultText: card.topText!)
                MemeLabelConfigurer.configureMemeLabel(bottomLabel, defaultText: card.bottomText!)
            }
        }
        
        //topLabel.backgroundColor = UIColor.blue
        //bottomLabel.backgroundColor = UIColor.green
        
        setupTwoHalfImageUIView()
        
        view.bringSubview(toFront: topLabel)
        view.bringSubview(toFront: bottomLabel)
    }
    private func setupImageView(){
        imageview.translatesAutoresizingMaskIntoConstraints = false

        var imageviewConstraintArr = [NSLayoutConstraint]()
        imageviewConstraintArr.append(NSLayoutConstraint(item: imageview, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: imageviewHeight))
        NSLayoutConstraint.activate(imageviewConstraintArr)
    }
    private func setupTwoHalfImageUIView() {
        let imageviewHeight = (self.view.frame.height-self.navigationBar.frame.height)*2/3
        topUIView = UIView(frame: CGRect(x: 10, y: 10 + navigationBar.frame.height, width: view.frame.width - 20, height: imageviewHeight/2))
        view.addSubview(topUIView)
        view.bringSubview(toFront: topUIView)
        
        bottomUIView = UIView(frame: CGRect(x: 10, y: 10 + imageviewHeight/2 + navigationBar.frame.height, width: view.frame.width - 20, height: imageviewHeight/2))
        view.addSubview(bottomUIView)
        view.bringSubview(toFront: bottomUIView)
    }
}
