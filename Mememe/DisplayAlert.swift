//
//  DisplayAlert.swift
//  Mememe
//
//  Created by Duy Le on 9/8/17.
//  Copyright © 2017 Andrew Le. All rights reserved.
//

import Foundation
import UIKit

class DisplayAlert {
    static func display(controller: UIViewController,title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        controller.present(alertController, animated: true, completion: nil)
    }
}
