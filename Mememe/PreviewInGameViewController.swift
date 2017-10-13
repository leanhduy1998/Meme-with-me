//
//  PreviewInGameViewController.swift
//  Mememe
//
//  Created by Duy Le on 10/12/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class PreviewInGameViewController: UIViewController {
    @IBOutlet weak var previewScrollView: UIScrollView!
    
    @IBOutlet weak var currentPlayersScrollView: UIScrollView!
    
    @IBOutlet weak var previousRoundBtn: UIBarButtonItem!
    
    @IBOutlet weak var nextRoundBtn: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func doneBtnPressed(_ sender: Any) {
    }
    @IBAction func previousBtnPressed(_ sender: Any) {
    }
    @IBAction func nextBtnPressed(_ sender: Any) {
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
