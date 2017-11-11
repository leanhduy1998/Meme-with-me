//
//  PictureDetailViewController.swift
//  Mememe
//
//  Created by Duy Le on 11/11/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import UIKit

class PictureDetailViewController: UIViewController {

    
    @IBOutlet weak var imageview: UIImageView!
    
    @IBOutlet weak var topLabel: UILabel!
    
    @IBOutlet weak var bottomLabel: UILabel!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    
    var topText: String!
    var bottomText: String!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageview = UIImageViewHelper.roundImageView(imageview: imageview, radius: 15)

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MemeLabelConfigurer.setAttributeForLabel(topLabel, defaultText: topText, size: 25)
        MemeLabelConfigurer.setAttributeForLabel(bottomLabel, defaultText: bottomText, size: 25)
        
        view.bringSubview(toFront: topLabel)
        view.bringSubview(toFront: bottomLabel)
        imageview.image = image
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        let oldFrame = imageview.frame
        let oldFrame2 = navigationBar.frame
        let oldFrame3 = topLabel.frame
        
        imageview.frame = CGRect(x: imageview.frame.origin.x
            , y: imageview.frame.origin.y - 64, width: imageview.frame.width, height: imageview.frame.height + 64)
        
        topLabel.frame = CGRect(x: topLabel.frame.origin.x
            , y: topLabel.frame.origin.y - 64, width: topLabel.frame.width, height: topLabel.frame.height)
        
        navigationBar.frame = CGRect(x: navigationBar.frame.origin.x
            , y: imageview.frame.origin.y - 100, width: navigationBar.frame.width, height: navigationBar.frame.height)
        
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, 0)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)

        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        
        imageview.frame = oldFrame
        navigationBar.frame = oldFrame2
        topLabel.frame = oldFrame3
        
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        self.present(controller, animated: true, completion: nil)
        controller.completionWithItemsHandler = { (activity, completed, items, error) in
            if (completed) {
                self.dismiss(animated: true, completion: nil)
            }
            else {
            }
        }
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
