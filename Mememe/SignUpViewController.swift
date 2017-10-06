//
//  SignUpViewController.swift
//  Mememe
//
//  Created by Duy Le on 8/31/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import AWSMobileHubHelper

class SignUpViewController: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var finishBtn: UIButton!
    
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    
    @IBAction func unwindToSignUpViewController(segue:UIStoryboardSegue) { }
    
    var currentUserImage: UIImage!
    
    let compressedProfileImageDirectory = "public/compressedProfileImage"
    let originalProfileImageDirectory = "public/originalProfileImage"
    
    var compressedProfileImageURL: URL!
    
    let S3Helper = UserFilesHelper()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        
        nameTextField.addTarget(self, action: #selector(textFieldDidChange), for: UIControlEvents.editingChanged)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (nameTextField.text?.isEmpty)! || currentUserImage == nil {
            finishBtn.isEnabled = false
        }
        else {
            finishBtn.isEnabled = true
        }
        
        if currentUserImage != nil {
            userImageView.image = currentUserImage
        }
        
        progressLabel.isHidden = true
        progressView.isHidden = true
        progressView.progress = 0.0
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textFieldDidChange(){
        if (nameTextField.text?.isEmpty)! || currentUserImage == nil {
            finishBtn.isEnabled = false
        }
        else {
            finishBtn.isEnabled = true
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    

    
    @IBAction func finishBtnPressed(_ sender: Any) {
        finishBtn.isEnabled = false
        progressView.isHidden = false
        progressLabel.isHidden = false
        
        var compressedImageData = (currentUserImage?.jpeg(.highest))!
       
        var quality = 5
        while compressedImageData.count > 2000000 {
            quality = quality - 1
            
            switch(quality){
            case 4:
                compressedImageData = (currentUserImage?.jpeg(.high))!
                break
            case 3:
                compressedImageData = (currentUserImage?.jpeg(.medium))!
                break
            case 2:
                compressedImageData = (currentUserImage?.jpeg(.low))!
                break
            case 1:
                compressedImageData = (currentUserImage?.jpeg(.lowest))!
                break
                
            default:
                break
            }
        }
        
        S3Helper.uploadData(directory: compressedProfileImageDirectory, fileName: "\(MyPlayerData.id!)", data: compressedImageData, progressView: progressView) { (url) in
            DispatchQueue.main.async {
                self.compressedProfileImageURL = url
                
                let alertController = UIAlertController(title: "Finish Upload", message: "I compressed and uploaded your image. Do you want to also upload your image at full resolution", preferredStyle: UIAlertControllerStyle.actionSheet)
                alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: self.uploadFullResImage))
                alertController.addAction(UIAlertAction(title: "Nah", style: UIAlertActionStyle.default, handler: self.finishUploading))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    private func uploadFullResImage(action: UIAlertAction){
        S3Helper.uploadData(directory: originalProfileImageDirectory, fileName: "\(MyPlayerData.id!)", data: UIImagePNGRepresentation(currentUserImage)!, progressView: progressView) { (url) in
            DispatchQueue.main.async {
                self.finishUploading()
            }
        }
    }
    private func finishUploading(){
        finishBtn.isEnabled = true
        MyPlayerData.userImageUrl = compressedProfileImageURL.absoluteString
        
        MyPlayerData.name = nameTextField.text
        PlayerDataDynamoDB.insertMyUserDataWithCompletionHandler({ (err) in
            if err != nil {
                print((err?.description)!)
            }
            else {
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "AvailableGamesViewControllerSegue", sender: self)
                }
            }
        })
    }
    private func finishUploading(action: UIAlertAction){
        finishUploading()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChangeUserPictureViewController {
            if currentUserImage != nil {
                destination.userImage = currentUserImage
            }
        }
    }
}


