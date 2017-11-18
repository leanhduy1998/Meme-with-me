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
    
    @IBOutlet weak var progressView: UIProgressView!
    
    
    var userImage = #imageLiteral(resourceName: "emptyUser")
    let imagePicker = UIImagePickerController()
    
    var isFromSetting = false
    
    let helper = UserFilesHelper()
    
    let compressedProfileImageDirectory = "public/compressedProfileImage"
    let originalProfileImageDirectory = "public/originalProfileImage"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        cameraBtn.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        searchTF.delegate = self
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y -= keyboardSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
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
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        if isFromSetting {
            helper.loadUserProfilePicture(userId: MyPlayerData.id, completeHandler: { (imageData) in
                DispatchQueue.main.async {
                    self.userIV.image = UIImage(data: imageData)
                }
            })
        }
        progressView.isHidden = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
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
        if isFromSetting{
            progressView.isHidden = false
            let S3Helper = UserFilesHelper()
            let data = userIV.image?.jpeg(UIImage.JPEGQuality.lowest)
            
            S3Helper.uploadData(directory: compressedProfileImageDirectory, fileName: "\(MyPlayerData.id!)", data: data!, progressView: progressView) { (url) in
                DispatchQueue.main.async {
                    let _ = FileManagerHelper.insertImageIntoMemory(imageName: "\(MyPlayerData.id)playerId", directory: [], image: UIImage(data: data!)!)
                    let alertController = UIAlertController(title: "Finish Upload", message: "I compressed and uploaded your image. Do you want to also upload your image at full resolution", preferredStyle: UIAlertControllerStyle.actionSheet)
                    alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: self.uploadFullResImage))
                    alertController.addAction(UIAlertAction(title: "Nah", style: UIAlertActionStyle.default, handler: self.finishUploading))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        else {
            performSegue(withIdentifier: "UnwindToSignUpViewController", sender: self)
        }
    }
    
    // this is only for when called from setting
    private func uploadFullResImage(action: UIAlertAction){
        let S3Helper = UserFilesHelper()
        let data = userIV.image?.jpeg(UIImage.JPEGQuality.highest)
        S3Helper.uploadData(directory: originalProfileImageDirectory, fileName: "\(MyPlayerData.id!)", data: data!, progressView: progressView) { (url) in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // this is only for when called from setting
    private func finishUploading(action: UIAlertAction){
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SignUpViewController {
            if userImage != #imageLiteral(resourceName: "emptyUser") {
                destination.currentUserImage = userImage
            }
        }
        if segue.destination is SettingViewController {
            isFromSetting = false
        }
    }
}


