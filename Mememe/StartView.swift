//
//  StarView.swift
//  Mememe
//
//  Created by Duy Le on 7/27/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

extension StartViewController {
    
    func setupUI(){
        setupDimensions()
        setupUserIcon()
        setupCeasarIcon()
        setupLaughingIcon()
        setupLeftRedNotificationView()
        setupRightRedNotificationView()
        setupTouchToStartLabel()
        setupMememeLabel()
    }
    
    private func setupDimensions(){
        screenWidth = view.frame.size.width
        screenHeight = view.frame.size.height
        iconWidth = screenWidth/3 - (margin * 2) - space*2
    }
    
    private func setupUserIcon(){
        userIcon.translatesAutoresizingMaskIntoConstraints = false
        
        let userIconSize = iconWidth+40
        
        var userIconConstraintArr = [NSLayoutConstraint]()
        userIconConstraintArr.append(NSLayoutConstraint(item: userIcon, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: userIconSize))
        userIconConstraintArr.append(NSLayoutConstraint(item: userIcon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: userIconSize))
        NSLayoutConstraint.activate(userIconConstraintArr)
    }
    
    private func setupCeasarIcon(){
        ceasarIcon.translatesAutoresizingMaskIntoConstraints = false
        
        var ceasarIconConstraintArr = [NSLayoutConstraint]()
        ceasarIconConstraintArr.append(NSLayoutConstraint(item: ceasarIcon, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: iconWidth))
        ceasarIconConstraintArr.append(NSLayoutConstraint(item: ceasarIcon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: iconWidth))
        NSLayoutConstraint.activate(ceasarIconConstraintArr)
    }
    
    private func setupLaughingIcon(){
        laughingIcon.translatesAutoresizingMaskIntoConstraints = false
        
        var laughingIconConstraintArr = [NSLayoutConstraint]()        
        laughingIconConstraintArr.append(NSLayoutConstraint(item: laughingIcon, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: iconWidth))
        laughingIconConstraintArr.append(NSLayoutConstraint(item: laughingIcon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: iconWidth))
        
        NSLayoutConstraint.activate(laughingIconConstraintArr)
    }
    
    private func setupLeftRedNotificationView(){
        leftRedNotificationView.translatesAutoresizingMaskIntoConstraints = false
        
        var leftRedNotificationViewConstraintArr = [NSLayoutConstraint]()
        leftRedNotificationViewConstraintArr.append(NSLayoutConstraint(item: leftRedNotificationView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: (-iconWidth/2)))
        
        leftRedNotificationViewConstraintArr.append(NSLayoutConstraint(item: leftRedNotificationView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: iconWidth - margin
        ))
        leftRedNotificationViewConstraintArr.append(NSLayoutConstraint(item: leftRedNotificationView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: redCircleSize))
        leftRedNotificationViewConstraintArr.append(NSLayoutConstraint(item: leftRedNotificationView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: redCircleSize))
        NSLayoutConstraint.activate(leftRedNotificationViewConstraintArr)
    }
    
    private func setupRightRedNotificationView(){
        rightRedNotificationView.translatesAutoresizingMaskIntoConstraints = false
        
        var rightRedNotificationViewConstraintArr = [NSLayoutConstraint]()
        rightRedNotificationViewConstraintArr.append(NSLayoutConstraint(item: rightRedNotificationView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: -iconWidth/2))
        
        rightRedNotificationViewConstraintArr.append(NSLayoutConstraint(item: rightRedNotificationView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: -margin
        ))
        rightRedNotificationViewConstraintArr.append(NSLayoutConstraint(item: rightRedNotificationView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: redCircleSize))
        rightRedNotificationViewConstraintArr.append(NSLayoutConstraint(item: rightRedNotificationView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: redCircleSize))
        NSLayoutConstraint.activate(rightRedNotificationViewConstraintArr)
    }
    
    private func setupTouchToStartLabel(){
        touchToStartLabel.translatesAutoresizingMaskIntoConstraints = false
        
        var touchToStartLabelConstraintArr = [NSLayoutConstraint]()
        
        touchToStartLabelConstraintArr.append(NSLayoutConstraint(item: touchToStartLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -screenHeight/12
        ))
        NSLayoutConstraint.activate(touchToStartLabelConstraintArr)
    }
    
    private func setupMememeLabel(){
        mememeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        var mememeLabelConstraintArr = [NSLayoutConstraint]()
        mememeLabelConstraintArr.append(NSLayoutConstraint(item: mememeLabel, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: margin
        ))
        mememeLabelConstraintArr.append(NSLayoutConstraint(item: mememeLabel, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: -margin
        ))
        
        mememeLabelConstraintArr.append(NSLayoutConstraint(item: mememeLabel, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: screenHeight/12
        ))
        NSLayoutConstraint.activate(mememeLabelConstraintArr)
    }
    
}
