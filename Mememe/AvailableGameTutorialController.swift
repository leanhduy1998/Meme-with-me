//
//  AvailableGameTutorialClass.swift
//  Mememe
//
//  Created by Duy Le on 10/9/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class AvailableGameTutorialController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var plusBtnView: UIView!
    
    @IBOutlet weak var backgroundColorIV: UIImageView!
    
    let helper = UserFilesHelper()
    var backgroundPlayer: AVAudioPlayer!
    var alertController = UIAlertController()
    
    var step3OfRoomTut = false
    
    var canStart = false
    
    override func viewDidLoad() {
        tableview.reloadData()
        backgroundPlayer = SoundPlayerHelper.getAudioPlayer(songName: "availableRoomMusic", loop: true)
        canStart = true
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.isBeingPresented || self.isMovingToParentViewController {
            if(!step3OfRoomTut){
                alertController = UIAlertController(title: "Thank you for playing Mememe!", message: "I will walk you through a few things in this game.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: step2))
                alertController.addAction(UIAlertAction(title: "Say no more! I'll figure things out myself", style: UIAlertActionStyle.cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func step2(action: UIAlertAction){
        alertController.dismiss(animated: true, completion: nil)
        alertController = UIAlertController(title: "Joining room!", message: "Normally, you will be able to join rooms that are open, like the one above.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: step3))
        alertController.addAction(UIAlertAction(title: "Say no more! I'll figure things out myself", style: UIAlertActionStyle.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func step3(action: UIAlertAction){
        alertController.dismiss(animated: true, completion: nil)
        alertController = UIAlertController(title: "For now, let just create a new room!", message: "Tap on the (+) and create a room!", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AvailableRoomHelper.deleteMyRoom()
        InGameHelper.removeYourInGameRoom()
        setupUI()
        backgroundPlayer.play()
        
        darkenUI()
    }
    
    func addPlusBtnAnimation(){
        UIView.animate(withDuration: 1.0, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 6.0, options: [.allowUserInteraction, .autoreverse, UIViewAnimationOptions.repeat], animations: {
            self.addBtn.transform = CGAffineTransform(scaleX: 0.95, y: 1)
            
        },completion: nil)
    }
    func setupUI(){
        addPlusBtnAnimation()
        tableview.backgroundColor = UIColor.clear
        self.tabBarController?.tabBar.barTintColor = UIColor.clear
        view.backgroundColor = UIColor.clear
        plusBtnView.isHidden = false
        tableview.separatorStyle = UITableViewCellSeparatorStyle.singleLine
    }
    
    func darkenUI(){
        view.backgroundColor = UIColor.clear
        backgroundColorIV.backgroundColor = UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 1.0)
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    @IBAction func plusButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "RoomTutorialController", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? RoomTutorialController {
            backgroundPlayer.stop()
            destination.step4IsReady = step3OfRoomTut
        }
    }
}
