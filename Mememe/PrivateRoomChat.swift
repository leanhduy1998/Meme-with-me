//
//  PrivateRoomChat.swift
//  Mememe
//
//  Created by Duy Le on 9/30/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit
import Firebase

extension PrivateRoomViewController{
    
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func keyboardWillShow(_ notification:Notification) {
        if chatTextField.isEditing {
            view.frame.origin.y -=  getKeyboardHeight(notification)
            DispatchQueue.main.async {
                if(self.chatHelper.messages.count > 0){
                    let indexPath = IndexPath(row: self.chatHelper.messages.count-1, section: 0)
                    self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }

        }
    }
    func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: self.chatHelper.messages.count-1, section: 0)
            self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
}
