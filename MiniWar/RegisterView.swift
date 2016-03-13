//
//  RegisterView.swift
//  Enclosure
//
//  Created by Kedan Li on 3/12/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class RegisterView: UIViewController {
    
    @IBOutlet var done: UIButton!
    @IBOutlet var nickNameText: UITextField!
    
    override func viewDidLoad() {
        done.addTarget(self, action: "finishInputing:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func finishInputing(button: UIButton){
        if nickNameText.text != ""{
            self.performSegueWithIdentifier("toMainStart", sender: self)
        }
    }
}
