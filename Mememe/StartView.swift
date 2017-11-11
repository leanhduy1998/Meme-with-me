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
        ceasarIcon = UIImageViewHelper.roundImageView(imageview: ceasarIcon, radius: 5)
        userIcon = UIImageViewHelper.roundImageView(imageview: userIcon, radius: 25)
        touchToStartLabel.isHidden = false
        
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
            
       /*     self.laughingIcon.frame.origin.x += 100
            self.leftRedNotificationView.frame.origin.x += 100
            self.leftNotificationLabel.frame.origin.x += 100
            
            self.ceasarIcon.frame.origin.x -= 100
            self.rightRedNotificationView.frame.origin.x -= 100
            self.rightNotificationLabel.frame.origin.x -= 100*/
            
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
    
    private func setupTouchToStartLabel(){
        /*touchToStartLabel.translatesAutoresizingMaskIntoConstraints = false
        
        var touchToStartLabelConstraintArr = [NSLayoutConstraint]()
        
        touchToStartLabelConstraintArr.append(NSLayoutConstraint(item: touchToStartLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -screenHeight/12
        ))
        NSLayoutConstraint.activate(touchToStartLabelConstraintArr)*/
    }
    
}
