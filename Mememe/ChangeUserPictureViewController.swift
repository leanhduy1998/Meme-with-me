//
//  ChangeUserPictureViewController.swift
//  Mememe
//
//  Created by Duy Le on 8/31/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class ChangeUserPictureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var userIV: UIImageView!
    
    @IBOutlet weak var searchTF: UITextField!
    
    
    
    
    var userImage = #imageLiteral(resourceName: "emptyUser")
    let imagePicker = UIImagePickerController()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        cameraBtn.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        searchTF.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y += keyboardSize.height
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        finishBtn.isEnabled = false
    }

    @IBAction func libraryBtnPressed(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func cameraBtnPressed(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            userImage = image
            dismiss(animated: true, completion: {
                DispatchQueue.main.async {
                    self.finishBtn.isEnabled = true
                    self.userIV.image = self.userImage
                }
            })
        }
        else {
            print("NO!")
        }
    }
    
    @IBAction func searchBtnPressed(_ sender: Any) {
        if !(searchTF.text?.isEmpty)! {
            userIV.downloadedFrom(link: searchTF.text!, completeHandler: { (error) in
                DispatchQueue.main.async {
                    if error != nil {
                        if error?.localizedDescription == "The resource could not be loaded because the App Transport Security policy requires the use of a secure connection." {
                            let alertController = UIAlertController(title: "Cannot Download Image!", message: "The link provided does not have secure connection!", preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "Okay, chill!", style: UIAlertActionStyle.cancel, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                        else if error?.localizedDescription == "unsupported URL" {
                            let alertController = UIAlertController(title: "Not Supported URL", message: "The URL You typed is not correct!", preferredStyle: UIAlertControllerStyle.alert)
                            alertController.addAction(UIAlertAction(title: "Okay, chill!", style: UIAlertActionStyle.cancel, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                        else {
                            DisplayAlert.display(controller: self, title: "Cannot Download Image", message: (error?.localizedDescription)!)
                        }
                    }
                    else {
                        self.userImage = self.userIV.image!
                        self.finishBtn.isEnabled = true
                    }
                }
            })
        }
        dismissKeyboard()
    }
    
    @IBAction func finishBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "UnwindToSignUpViewController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SignUpViewController {
            if userImage != #imageLiteral(resourceName: "emptyUser") {
                destination.currentUserImage = userImage
            }
        }
    }
}


