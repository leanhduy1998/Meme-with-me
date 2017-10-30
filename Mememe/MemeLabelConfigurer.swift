//
//  MemeLabelConfigurer.swift
//  Mememe
//
//  Created by Duy Le on 8/14/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

class MemeLabelConfigurer {
    static func configureMemeLabel(_ label: UILabel, defaultText: String) {
        setAttribute(label: label, defaultText: defaultText)
        label.numberOfLines = 0
        label.textAlignment = .center
        
        resizeLabelFont(label: label)
    }
    
    private static func setAttribute(label: UILabel, defaultText: String) {
        let memeTextAttributes:[String:Any] = [
            NSStrokeColorAttributeName: UIColor.black,
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: label.font.pointSize)!,
            NSStrokeWidthAttributeName: -(label.font.pointSize/10)]
        let myString = NSMutableAttributedString(string: defaultText, attributes: memeTextAttributes )
        
        label.attributedText = myString
    }

    static func resizeLabelFont(label: UILabel){
        var labelTextWidth = (label.text! as NSString).boundingRect(
            with: CGSize(width: .greatestFiniteMagnitude, height: label.frame.height),
            options: .usesLineFragmentOrigin,
            attributes: [NSFontAttributeName: label.font],
            context: nil).size
        var labelTextHeight = (label.text! as NSString).boundingRect(
            with: CGSize(width: label.frame.width, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [NSFontAttributeName: label.font],
            context: nil).size
        

        
        while ( labelTextWidth.width < label.frame.width && labelTextHeight.height < label.frame.height) {
            let prediction = UILabel(frame: label.frame)
            prediction.font = UIFont(name: label.font.fontName, size: label.font.pointSize + 1)
            let predictionTextWidth = (label.text! as NSString).boundingRect(
                    with: CGSize(width: .greatestFiniteMagnitude, height: prediction.frame.height),
                    options: .usesLineFragmentOrigin,
                    attributes: [NSFontAttributeName: prediction.font],
                    context: nil).size

            
            if predictionTextWidth.width < label.frame.width {
                label.font = UIFont(name: label.font.fontName, size: label.font.pointSize + 1)
                labelTextWidth = (label.text! as NSString).boundingRect(
                        with: CGSize(width: .greatestFiniteMagnitude, height: prediction.frame.height),
                        options: .usesLineFragmentOrigin,
                        attributes: [NSFontAttributeName: label.font],
                        context: nil).size
                labelTextHeight = (label.text! as NSString).boundingRect(
                    with: CGSize(width: label.frame.width, height: .greatestFiniteMagnitude),
                    options: .usesLineFragmentOrigin,
                    attributes: [NSFontAttributeName: label.font],
                    context: nil).size
                
            }
            else {
                break
            }
        }
        
        while labelTextHeight.height > label.frame.height {
            label.font = UIFont(name: label.font.fontName, size: label.font.pointSize - 1)
            labelTextHeight = (label.text! as NSString).boundingRect(
                    with: CGSize(width: label.frame.width, height: .greatestFiniteMagnitude),
                    options: .usesLineFragmentOrigin,
                    attributes: [NSFontAttributeName: label.font],
                    context: nil).size
        }
        
        setAttribute(label: label, defaultText: label.text!)
    }
}
