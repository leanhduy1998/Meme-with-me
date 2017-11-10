

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
import AVFoundation

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

    var backgroundPlayer: AVAudioPlayer!


    func onlyForAdmin(){
        let path = Bundle.main.path(forResource: "topMemes", ofType: "txt")
        do {
            let data = try String(contentsOfFile: path!, encoding: .utf8)
            let myStrings = data.components(separatedBy: .newlines)
            Database.database().reference().child("meme").child("topMemes").setValue(myStrings)
        } catch {
            print(error)
        }
        
        let path2 = Bundle.main.path(forResource: "bottomMemes", ofType: "txt")
        do {
            let data = try String(contentsOfFile: path2!, encoding: .utf8)
            print(data)
            let myStrings = data.components(separatedBy: .newlines)
            Database.database().reference().child("meme").child("bottomMemes").setValue(myStrings)
        } catch {
            print(error)
        }
        
        let path3 = Bundle.main.path(forResource: "fullMemes", ofType: "txt")
        do {
            let data = try String(contentsOfFile: path3!, encoding: .utf8)
            print(data)
            let myStrings = data.components(separatedBy: .newlines)
            Database.database().reference().child("meme").child("fullMemes").setValue(myStrings)
        } catch {
            print(error)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //onlyForAdmin()
        
        setupUI()
        setupMainScreenTap()
        
        backgroundPlayer = SoundPlayerHelper.getAudioPlayer(songName: "startMusic", loop: true)
        backgroundPlayer.play()
        
        myDataStack.initializeFetchedResultsController()
        let fetchedObjects = self.myDataStack.fetchedResultsController.fetchedObjects as? [MyCoreData]
        if((fetchedObjects?.count)! > 0){
            let image = FileManagerHelper.getImageFromMemory(imagePath: fetchedObjects![0].imageStorageLocation!)
            userIcon.image = image
            leftNotificationLabel.text = "\(Int(fetchedObjects![0].laughes))"
            rightNotificationLabel.text = "\(Int(fetchedObjects![0].madeCeasar))"
        }
        
        GameStack.sharedInstance.initializeFetchedResultsController()
        let deleteItems = GameStack.sharedInstance.fetchedResultsController.fetchedObjects
        for item in deleteItems!{
          //      GameStack.sharedInstance.stack.context.delete(item as! NSManagedObject)
        }
    }
    
    private func setupMainScreenTap(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(sender:)))
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    @objc private func handleTap(sender: UITapGestureRecognizer) {
        googleButton.isHidden = false
        googleButton.alpha = 0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.touchToStartLabel.alpha = 0
            
            if Reachability.isConnectedToNetwork() {
                self.googleButton.alpha = 1
            }
            
        }) { (completed) in
            if(completed){
                self.touchToStartLabel.isHidden = true
                
                if !Reachability.isConnectedToNetwork() {
                    let alertController = UIAlertController(title: "Plot twist! There is no wifi!", message: "Do you want to see your previous games that are saved on your phone?", preferredStyle: UIAlertControllerStyle.actionSheet)
                    alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: self.showPreviewGames))
                    alertController.addAction(UIAlertAction(title: "Nah", style: UIAlertActionStyle.cancel, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    private func showPreviewGames(action: UIAlertAction){
        performSegue(withIdentifier: "PreviewGamesSegue", sender: self)
    }
    
    func onLogin(signInProvider: AWSSignInProvider, result: Any?, authState: AWSIdentityManagerAuthState, error: Error?) {

        if result == nil {
            googleBtnClicked = false
            if(error != nil){
                DisplayAlert.display(controller: self, title: "Login Error!", message: (error?.localizedDescription)!)
            }
            return
        }
        if(googleBtnClicked){
            return
        }
        
        googleBtnClicked = true
     
        MyPlayerData.id = AWSIdentityManager.default().identityId
        // handle success here
        
        MemeHelper.getAllMemes {
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
    }
    
    private func handleLoginData(results: [PlayerDataDBObjectModel]){
        let data = results[0] as? PlayerDataDBObjectModel
        MyPlayerData.name = data?._name
        
        let helper = UserFilesHelper()
        helper.loadUserProfilePicture(userId: MyPlayerData.id) { (imageData) in
            DispatchQueue.main.async {
                var statChanged = false
                let fetchedObjects = self.myDataStack.fetchedResultsController.fetchedObjects as? [MyCoreData]
                
                let playerIdForStorage = FileManagerHelper.getPlayerIdForStorage(playerId: MyPlayerData.id)
                
                let filePath = FileManagerHelper.insertImageIntoMemory(imageName: "\(playerIdForStorage)playerId", directory: [], image: UIImage(data: imageData)!)
                
                if(fetchedObjects?.count == 0){
                    let _ = MyCoreData(imageStorageLocation: filePath, laughes: Int((data?._laughes)!), madeCeasar: Int((data?._madeCeasar)!), context: self.myDataStack.stack.context)
                }
                else {
                    fetchedObjects![0].imageStorageLocation = filePath
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
                        self.leftNotificationLabel.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
                        self.leftNotificationLabel.textColor = UIColor.yellow
                        self.rightNotificationLabel.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        backgroundPlayer.stop()
    }

}

