

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


    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupMainScreenTap()
        setupGoogleButton()
        myDataStack.initializeFetchedResultsController()
        
        userIcon.alpha = 0
        laughingIcon.alpha = 0
        leftRedNotificationView.alpha = 0
        leftNotificationLabel.alpha = 0
        
        touchToStartLabel.alpha = 0
        
        UIView.animate(withDuration: 1) {
            self.userIcon.frame.origin.y += self.view.frame.height/2
            
            self.laughingIcon.frame.origin.x += 100
            self.leftRedNotificationView.frame.origin.x += 100
            self.leftNotificationLabel.frame.origin.x += 100
            
            self.ceasarIcon.frame.origin.x -= 100
            self.rightRedNotificationView.frame.origin.x -= 100
            self.rightNotificationLabel.frame.origin.x -= 100
            
            self.userIcon.alpha = 1
            self.laughingIcon.alpha = 1
            self.leftRedNotificationView.alpha = 1
            self.leftNotificationLabel.alpha = 1
            self.touchToStartLabel.alpha = 1
        }
        
        UIView.animate(withDuration: 2, delay: 0.0, options:[UIViewAnimationOptions.repeat, UIViewAnimationOptions.autoreverse], animations: {
            self.laughingIcon.frame.origin.y += 5
            self.leftRedNotificationView.frame.origin.y += 10
            self.leftNotificationLabel.frame.origin.y += 1
            
            self.ceasarIcon.frame.origin.y += 5
            self.rightRedNotificationView.frame.origin.y += 10
            self.rightNotificationLabel.frame.origin.y += 1
            
            self.userIcon.transform = CGAffineTransform(scaleX: 1.10, y: 1.10)
            
            self.touchToStartLabel.alpha = 0
 
        }, completion: nil)
        
        let fetchedObjects = self.myDataStack.fetchedResultsController.fetchedObjects as? [MyCoreData]
        if((fetchedObjects?.count)! > 0){
            userIcon.image = UIImage(data: fetchedObjects![0].imageData as! Data)
            leftNotificationLabel.text = "\(Int(fetchedObjects![0].laughes))"
            rightNotificationLabel.text = "\(Int(fetchedObjects![0].madeCeasar))"
        }
    }

    private func setupGoogleButton(){
        googleButton.isHidden = true
        AWSGoogleSignInProvider.sharedInstance().setScopes(["profile", "openid"])
        AWSGoogleSignInProvider.sharedInstance().setViewControllerForGoogleSignIn(self)
        
        googleButton.buttonStyle = .large
        
        googleButton.delegate = self
    }
    func setupMainScreenTap(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    func handleTap(sender: UITapGestureRecognizer) {
        googleButton.isHidden = false
        googleButton.alpha = 0
        
        UIView.animate(withDuration: 1, animations: {
            self.view.backgroundColor = UIColor(red: 145/255, green: 255/255, blue: 255/255, alpha: 1.0)
            self.googleButton.alpha = 1
            self.touchToStartLabel.alpha = 0
        }) { (completed) in
            if(completed){
                self.touchToStartLabel.isHidden = true
            }
        }
    }
    

    func onLogin(signInProvider: AWSSignInProvider, result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) {
        if result != nil {
            MyPlayerData.id = AWSIdentityManager.default().identityId
            // handle success here
            DispatchQueue.main.async {
                PlayerDataDynamoDB.queryWithPartitionKeyWithCompletionHandler(userId: MyPlayerData.id) { (results, error) in
                    if error == nil {
                        if results?.items.count == 0 {
                            DispatchQueue.main.async {
                                self.performSegue(withIdentifier: "SignUpViewControllerSegue", sender: self)
                            }
                        }
                        else {
                            DispatchQueue.main.async {
                                let data = results?.items[0] as? PlayerDataDBObjectModel
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
                        }
                    }
                    else {
                        print((error?.description)!)
                    }
                }
            }
        } else {
            DisplayAlert.display(controller: self, title: "Login Error!", message: (error?.localizedDescription)!)
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

