//
//  StarView.swift
//  Mememe
//
//  Created by Duy Le on 7/27/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import AWSGoogleSignIn

extension StartViewController {
    
    func setupUI(){
        setupDimensions()
        setupUserIcon()
        setupCeasarIcon()
        setupLaughingIcon()
        setupLeftRedNotificationView()
        setupRightRedNotificationView()
        
        setupTouchToStartLabel()
        addFadeInAnimation()
        setupGoogleButton()
    }
    
    private func setupGoogleButton(){
        googleButton.isHidden = true
        AWSGoogleSignInProvider.sharedInstance().setScopes(["profile", "openid"])
        AWSGoogleSignInProvider.sharedInstance().setViewControllerForGoogleSignIn(self)
        
        googleButton.buttonStyle = .large
        googleButton.delegate = self
    }
    
    private func addFadeInAnimation(){
        userIcon.alpha = 0
        laughingIcon.alpha = 0
        leftRedNotificationView.alpha = 0
        leftNotificationLabel.alpha = 0
        
        touchToStartLabel.backgroundColor = UIColor.white
        touchToStartLabel.alpha = 0
        
        UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
            self.userIcon.frame.origin.y += self.view.frame.height/2
            
            self.laughingIcon.frame.origin.x += 100
            self.leftRedNotificationView.frame.origin.x += 100
            self.leftNotificationLabel.frame.origin.x += 100
            
            self.ceasarIcon.frame.origin.x -= 100
            self.rightRedNotificationView.frame.origin.x -= 100
            self.rightNotificationLabel.frame.origin.x -= 100
            
            self.userIcon.alpha = 1
            self.laughingIcon.alpha = 1
            self.leftRedNotificationView.alpha = 1
            self.leftNotificationLabel.alpha = 1
            self.touchToStartLabel.alpha = 1
        }) { (completed) in
            if completed{
                self.addLoopingAnimation()
            }
        }
    }
    
    private func addLoopingAnimation(){
        UIView.animate(withDuration: 2, delay: 0.0, options:[UIViewAnimationOptions.repeat, UIViewAnimationOptions.autoreverse], animations: {
            self.laughingIcon.frame.origin.y += 5
            self.leftRedNotificationView.frame.origin.y += 10
            self.leftNotificationLabel.frame.origin.y += 1
            
            self.ceasarIcon.frame.origin.y += 5
            self.rightRedNotificationView.frame.origin.y += 10
            self.rightNotificationLabel.frame.origin.y += 1
            
            self.userIcon.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
            
            self.touchToStartLabel.alpha = 0
            
        }, completion: nil)
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
        
        userIcon = UIImageViewHelper.roundImageView(imageview: userIcon, radius: Float(userIcon.frame.width/2))
    }
    
    private func setupCeasarIcon(){
        ceasarIcon.translatesAutoresizingMaskIntoConstraints = false
        
        var ceasarIconConstraintArr = [NSLayoutConstraint]()
        ceasarIconConstraintArr.append(NSLayoutConstraint(item: ceasarIcon, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: iconWidth))
        ceasarIconConstraintArr.append(NSLayoutConstraint(item: ceasarIcon, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: iconWidth))
        NSLayoutConstraint.activate(ceasarIconConstraintArr)
        
        ceasarIcon = UIImageViewHelper.roundImageView(imageview: ceasarIcon, radius: 5)
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
    
}
