//
//  JudgingView.swift
//  Mememe
//
//  Created by Duy Le on 8/18/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension JudgingViewController {
    func setupUI() {
        cardHeight = (view.frame.height) * 5 / 6
        cardWidth = view.frame.width * 3 / 4
        
        memeScrollView.contentOffset.y = 0
        
        self.automaticallyAdjustsScrollViewInsets = false
        createMemeScrollView()
    }
    private func createMemeScrollView(){
        memeScrollView.translatesAutoresizingMaskIntoConstraints = false
        
        var memeScrollViewConstraintArr = [NSLayoutConstraint]()
        memeScrollViewConstraintArr.append(NSLayoutConstraint(item: memeScrollView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: view.frame.width))
        memeScrollViewConstraintArr.append(NSLayoutConstraint(item: memeScrollView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: cardHeight))
        
        NSLayoutConstraint.activate(memeScrollViewConstraintArr)
    }
}
