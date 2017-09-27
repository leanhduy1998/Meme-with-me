

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
    
    
    private let delegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupMainScreenTap()
        setupGoogleButton()
        
        /*
        do {
            try delegate.stack.dropAllData()
        }
        catch {
            fatalError()
        }*/
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
        touchToStartLabel.isHidden = true
        googleButton.isHidden = false
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
                                
                                self.performSegue(withIdentifier: "mainViewControllerSegue", sender: self)
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

}

