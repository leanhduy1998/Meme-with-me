//
//  AddEditMyMemeTableView.swift
//  Mememe
//
//  Created by Duy Le on 8/14/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension AddEditMyMemeViewController {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddEditMyMemeTableCell") as? AddEditMyMemeTableCell
        
        let memetexts = ["memeText1","memeText2","memeText3","memeText4","memeText5","memeText6","memeText7","memeText8","memeText9","memeText10","memeText11","memeText12","memeText13","memeText14","memeText15","memeText16","memeText17","memeText18","memeText19","memeText20"]
        cell?.memeLabel.text = memetexts[indexPath.row]
        cell?.memeLabel.tag = 0
        
        let lpGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressCell))
        cell?.contentView.addGestureRecognizer(lpGestureRecognizer)
        
        return cell!
    }
    
    func didLongPressCell (recognizer: UILongPressGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if let cellView: UIView = recognizer.view {
                let originalPoint = recognizer.location(in: view)
                if let label = cellView.subviews[0] as? UILabel {
                    dragLabel = UILabel(frame: CGRect(x: originalPoint.x, y: originalPoint.y, width: label.frame.width, height: label.frame.height))
                    dragLabel.text = label.text
                }

                view.addSubview(dragLabel!)
                view.bringSubview(toFront: dragLabel)
                
            }
        case .changed:
            dragLabel.center = recognizer.location(in: view)
            
        case .ended:
            if (dragLabel == nil) {return}
            
            dragLabel?.removeFromSuperview()
            if topUIView.frame.intersects(dragLabel.frame) {
                // for some reason, the text need to have a space in it to make the animation works
                if bottomLabel.text == dragLabel.text {
                    bottomLabel.text = " "
                }
                MemeLabelConfigurer.configureMemeLabel(topLabel, defaultText: dragLabel.text!)
            }
            if bottomUIView.frame.intersects(dragLabel.frame) {
                // for some reason, the text need to have a space in it to make the animation works
                if topLabel.text == dragLabel.text {
                    topLabel.text = " "
                }
                MemeLabelConfigurer.configureMemeLabel(bottomLabel, defaultText: dragLabel.text!)
            }
        default:
            print("Any other action?")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let memetexts = ["memeText1","memeText2","memeText3","memeText4","memeText5","memeText6","memeText7","memeText8","memeText9","memeText10","memeText11","memeText12","memeText13","memeText14","memeText15","memeText16","memeText17","memeText18","memeText19","memeText20"]
        return memetexts.count
    }
}
