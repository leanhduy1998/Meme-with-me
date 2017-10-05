//
//  InGameChatTableView.swift
//  Mememe
//
//  Created by Duy Le on 8/4/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

extension InGameViewController {
    func calculateHeight(inString:String) -> CGFloat {
        let messageString = inString
        let attributes : [String : Any] = [NSFontAttributeName : UIFont.systemFont(ofSize: 15.0)]
        
        let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes)
        
        let rect : CGRect = attributedString.boundingRect(with: CGSize(width: 222.0, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        
        let requredSize:CGRect = rect
        return requredSize.height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension;
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if(tableView == chatTableView){
            let heightOfRow = calculateHeight(inString: chatHelper.messages[indexPath.row].text)
            return (heightOfRow + 40.0)
        }
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = chatHelper.messages[indexPath.row]
        if(message.senderId == MyPlayerData.id){
            var cell = tableView.dequeueReusableCell(withIdentifier: "MyChatTableViewCell") as? MyChatTableViewCell
            cell = CellAnimator.add(cell: cell!)
            cell?.messageTF.text = message.text
            cell?.messageTF.numberOfLines = 0
            cell?.messageTF.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell?.frame = (cell?.messageTF.frame)!
            
            s3Helper.loadUserProfilePicture(userId: message.senderId) { (imageData) in
                DispatchQueue.main.async {
                    cell?.userIV.image = UIImage(data: imageData)
                }
            }
            return cell!
        }
        else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "HerChatTableViewCell") as? HerChatTableViewCell
            cell = CellAnimator.add(cell: cell!)
            cell?.messageTF.text = message.text
            cell?.messageTF.numberOfLines = 0
            cell?.messageTF.lineBreakMode = NSLineBreakMode.byWordWrapping
            cell?.frame = (cell?.messageTF.frame)!
            
            s3Helper.loadUserProfilePicture(userId: message.senderId) { (imageData) in
                DispatchQueue.main.async {
                    cell?.userIV.image = UIImage(data: imageData)
                }
            }
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatHelper.messages.count
    }
}
