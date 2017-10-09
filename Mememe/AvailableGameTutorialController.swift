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
    @IBAction func unwindToAvailableGamesViewController(segue:UIStoryboardSegue) { }
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var plusBtnView: UIView!
    
    @IBOutlet weak var backgroundColorIV: UIImageView!
    
    

    let helper = UserFilesHelper()

    var backgroundPlayer: AVAudioPlayer!
    
    
    override func viewDidLoad() {
        UserOnlineSystem.updateUserOnlineStatus()
        tableview.reloadData()
        backgroundPlayer = SoundPlayerHelper.getAudioPlayer(songName: "availableRoomMusic", loop: true)
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
    
    
    @IBAction func plusButtonPressed(_ sender: Any) {
        let roomOptionAlertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        roomOptionAlertController.addAction(UIAlertAction(title: "Create a room", style: UIAlertActionStyle.default, handler: createAPrivateGame))
        roomOptionAlertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(roomOptionAlertController, animated: true, completion: nil)
    }
    

    func createAPrivateGame(action: UIAlertAction){
        performSegue(withIdentifier: "RoomTutorialController", sender: self)
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? RoomTutorialController {
            backgroundPlayer.stop()
        }
    }
}
