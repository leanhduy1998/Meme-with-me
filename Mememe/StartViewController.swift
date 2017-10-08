

//
//  ViewController.swift
//  Mememe
//
//  Created by Duy Le on 7/27/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSGoogleSignIn
import AWSCore

import FirebaseDatabase

class StartViewController: UIViewController,UIGestureRecognizerDelegate, AWSSignInDelegate {

    @IBOutlet weak var userIcon: UIImageView!
    @IBOutlet weak var ceasarIcon: UIImageView!
    @IBOutlet weak var laughingIcon: UIImageView!
    @IBOutlet weak var mememeLabel: UILabel!
    @IBOutlet weak var leftRedNotificationView: UIView!
    @IBOutlet weak var rightRedNotificationView: UIView!
    @IBOutlet weak var touchToStartLabel: UILabel!
    @IBOutlet weak var leftNotificationLabel: UILabel!
    @IBOutlet weak var rightNotificationLabel: UILabel!
    @IBOutlet weak var googleButton: AWSGoogleSignInButton!
    
    
    var screenWidth = CGFloat(0)
    var screenHeight = CGFloat(0)
    let space = CGFloat(15)
    let margin = CGFloat(10)
    let redCircleSize = CGFloat(20)
    var iconWidth = CGFloat(0)
    
    let myDataStack = MyDataStack()
    
    var googleBtnClicked = false


    override func viewDidLoad() {
        super.viewDidLoad()
        SoundPlayer.sharedInstance.playStartMusic()
        
        setupUI()
    
        myDataStack.initializeFetchedResultsController()
        let fetchedObjects = self.myDataStack.fetchedResultsController.fetchedObjects as? [MyCoreData]
        if((fetchedObjects?.count)! > 0){
            userIcon.image = UIImage(data: fetchedObjects![0].imageData as! Data)
            leftNotificationLabel.text = "\(Int(fetchedObjects![0].laughes))"
            rightNotificationLabel.text = "\(Int(fetchedObjects![0].madeCeasar))"
        }
    }
    
    func onLogin(signInProvider: AWSSignInProvider, result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) {

        if result == nil {
            DisplayAlert.display(controller: self, title: "Login Error!", message: (error?.localizedDescription)!)
            googleBtnClicked = false
            return
        }
        if(googleBtnClicked){
            return
        }
        
        googleBtnClicked = true
     
        MyPlayerData.id = AWSIdentityManager.default().identityId
        // handle success here
        DispatchQueue.main.async {
            PlayerDataDynamoDB.queryWithPartitionKeyWithCompletionHandler(userId: MyPlayerData.id) { (results, error) in
                if(error != nil){
                    print((error?.description)!)
                    return
                }
    
                if results?.items.count == 0 {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "SignUpViewControllerSegue", sender: self)
                        return
                    }
                }
                else{
                    DispatchQueue.main.async {
                        self.handleLoginData(results: results?.items as! [PlayerDataDBObjectModel])
                    }
                }
            }
        }
    }
    
    private func handleLoginData(results: [PlayerDataDBObjectModel]){
        let data = results[0] as? PlayerDataDBObjectModel
        MyPlayerData.name = data?._name
        
        let helper = UserFilesHelper()
        helper.loadUserProfilePicture(userId: MyPlayerData.id) { (imageData) in
            DispatchQueue.main.async {
                var statChanged = false
                let fetchedObjects = self.myDataStack.fetchedResultsController.fetchedObjects as? [MyCoreData]
                if(fetchedObjects?.count == 0){
                    let _ = MyCoreData(imageData: imageData, laughes: Int((data?._laughes)!), madeCeasar: Int((data?._madeCeasar)!), context: self.myDataStack.stack.context)
                }
                else {
                    fetchedObjects![0].imageData = imageData as NSData
                    if(fetchedObjects![0].laughes != (data?._laughes as! Int16)){
                        statChanged = true
                    }
                    if(fetchedObjects![0].madeCeasar != Int16((data?._madeCeasar)!)){
                        statChanged = true
                    }
                    fetchedObjects![0].laughes = (data?._laughes as! Int16)
                    fetchedObjects![0].madeCeasar = Int16((data?._madeCeasar)!)
                }
                if(statChanged){
                    UIView.animate(withDuration: 0.5, delay: 0, options: [.autoreverse], animations: {
                        self.leftNotificationLabel.text = "\(Int((data?._laughes)!))"
                        self.rightNotificationLabel.text = "\(Int((data?._madeCeasar)!))"
                        self.leftNotificationLabel.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
                        self.leftNotificationLabel.textColor = UIColor.yellow
                        self.rightNotificationLabel.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
                        self.rightNotificationLabel.textColor = UIColor.yellow
                    }, completion: { (completed) in
                        if(completed){
                            DispatchQueue.main.async {
                                self.saveAndGoToAvailableGamesController()
                            }
                        }
                    })
                }
                else{
                    self.saveAndGoToAvailableGamesController()
                }
            }
        }
    }
    
    
    func saveAndGoToAvailableGamesController(){
        myDataStack.saveContext {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 2, animations: {
                    self.userIcon.alpha = 0
                    self.laughingIcon.alpha = 0
                    self.ceasarIcon.alpha = 0
                    self.leftNotificationLabel.alpha = 0
                    self.leftRedNotificationView.alpha = 0
                    self.rightNotificationLabel.alpha = 0
                    self.rightRedNotificationView.alpha = 0
                }, completion: { (completed) in
                    if(completed){
                        self.performSegue(withIdentifier: "mainViewControllerSegue", sender: self)
                    }
                })
                
            }
        }
    }

}

