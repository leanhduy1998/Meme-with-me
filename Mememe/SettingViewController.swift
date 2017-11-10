//
//  SettingViewController.swift
//  Mememe
//
//  Created by Duy Le on 11/9/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableview: UITableView!
    
    var sections = ["Change Your Name","Change Your Profile Picture","Log Out Of Google Account"]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: "SettingCell") as? SettingTableViewCell
        cell?.label.text = sections[indexPath.row]
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(sections[indexPath.row]){
        case "Change Your Name":
            performSegue(withIdentifier: "ChangeNameSettingViewControllerSegue", sender: self)
            break
        
        case "Change Your Profile Picture":
            performSegue(withIdentifier: "ChangePictureSegue", sender: self)
            break
            
        default:
            break
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ChangeUserPictureViewController {
            destination.isFromSetting = true
        }
    }
    

}
