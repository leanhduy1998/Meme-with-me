//
//  SettingViewController.swift
//  Mememe
//
//  Created by Duy Le on 11/9/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit
import AWSGoogleSignIn

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    
    var sections = ["Change Your Name","Change Your Profile Picture","Log Out Of Google Account"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "SettingCell") as? SettingTableViewCell
        cell?.label.text = sections[indexPath.row]
        switch(indexPath.row){
            case 0:
                cell?.imageview.image = #imageLiteral(resourceName: "id card")
            break
            case 1:
                cell?.imageview.image = #imageLiteral(resourceName: "emptyUser")
            break
            case 2:
                cell?.imageview.image = #imageLiteral(resourceName: "logout")
            break
            default:
            break
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row){
        case 0:
            performSegue(withIdentifier: "ChangeNameSettingViewControllerSegue", sender: self)
            break
        
        case 1:
            performSegue(withIdentifier: "ChangePictureSegue", sender: self)
            break
        case 2:
            AWSSignInManager.sharedInstance().logout(completionHandler: { (result, state, error) in
                if error == nil {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "startViewUnwind", sender: self)
                    }
                }
            })
            
            break
        default:
            break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChangeUserPictureViewController {
            destination.isFromSetting = true
        }
        if let destination = segue.destination as? StartViewController {
            destination.isLoggedOut = true
        }
    }
    

}
