//
//  ChangeNameSettingViewController.swift
//  Mememe
//
//  Created by Duy Le on 11/10/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class ChangeNameSettingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var label: UITextField!
    
    @IBOutlet weak var changeNameBtn: UIButton!
    
    @IBOutlet weak var cancelBt: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func changeNameBtnPressed(_ sender: Any) {
        if (label.text?.isEmpty)! {
            DisplayAlert.display(controller: self, title: "You cannot be NoName!", message: "Please enter your name!")
        }
        else {
            cancelBt.isEnabled = false
            changeNameBtn.isEnabled = false
            
            PlayerDataDynamoDB.updateUserName(name: label.text!, completionHandler: { (error) in
                DispatchQueue.main.async {
                    self.cancelBt.isEnabled = true
                    self.changeNameBtn.isEnabled = true
                    if error == nil {
                        DisplayAlert.display(controller: self, title: "Beep!", message: "You are now known as \(self.label.text!)")
                        MyPlayerData.name = self.label.text
                    }
                    else {
                        DisplayAlert.display(controller: self, title: "Error 404!", message: "For some reason, we can't change your name!")
                    }
                }
            })
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.endEditing(true)
        return true
    }
    func keyboardWillShow(_ notification:Notification) {
        view.frame.origin.y -=  getKeyboardHeight(notification)
    }
    func keyboardWillHide(_ notification:Notification){
        view.frame.origin.y = 0
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
    
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
