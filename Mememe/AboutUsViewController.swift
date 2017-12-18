//
//  AboutUsViewController.swift
//  Meme with Me
//
//  Created by Duy Le on 11/11/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {

    @IBOutlet weak var iv1: UIImageView!
    @IBOutlet weak var iv2: UIImageView!
    
    @IBAction func patreonBtnPressed(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: "https://www.patreon.com/taydrew")! as URL)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        iv1 = UIImageViewHelper.roundImageView(imageview: iv1, radius: 5)
        iv2 = UIImageViewHelper.roundImageView(imageview: iv2, radius: 5)
    }
}
