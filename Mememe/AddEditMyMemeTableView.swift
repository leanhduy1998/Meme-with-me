//
//  AddEditMyMemeTableView.swift
//  Mememe
//
//  Created by Duy Le on 8/14/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit
import SwiftTryCatch

extension AddEditMyMemeViewController {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddEditMyMemeTableCell") as? AddEditMyMemeTableCell
        
        cell?.memeLabel.text = memesArrangement[indexPath.row]
        cell?.memeLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell?.memeLabel.numberOfLines = 0
    
        let lpGestureRecognizer: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressCell))
        cell?.contentView.addGestureRecognizer(lpGestureRecognizer)
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    /*
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }*/
    

    
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
                /*
                if bottomLabel.text == dragLabel.text {
                    bottomLabel.text = " "
                }*/
                topLabel.font = originalFont
                if !isTextEmpty(string: topLabel.text!) {
                    self.memesArrangement.append(topLabel.text!)
                }
                
                DispatchQueue.main.async {
                    MemeLabelConfigurer.configureMemeLabel(self.topLabel, defaultText: self.dragLabel.text!)
                    
                    var count = 0
                    for meme in self.memesArrangement {
                        if meme == self.dragLabel.text {
                            self.memesArrangement.remove(at: count)
                            self.tableview.reloadData()
                        }
                        count = count + 1
                    }
                }
                
            }
            if bottomUIView.frame.intersects(dragLabel.frame) {
                // for some reason, the text need to have a space in it to make the animation works
                /*if topLabel.text == dragLabel.text {
                    topLabel.text = " "
                }*/
                bottomLabel.font = originalFont
                if !isTextEmpty(string: bottomLabel.text!) {
                    self.memesArrangement.append(bottomLabel.text!)
                }
                
                DispatchQueue.main.async {
                    MemeLabelConfigurer.configureMemeLabel(self.bottomLabel, defaultText: self.dragLabel.text!)
                    
                    var count = 0
                    for meme in self.memesArrangement {
                        if meme == self.dragLabel.text {
                            self.memesArrangement.remove(at: count)
                            self.tableview.reloadData()
                        }
                        count = count + 1
                    }
                }
                
            }
        default:
            print("Any other action?")
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memesArrangement.count
    }
}
