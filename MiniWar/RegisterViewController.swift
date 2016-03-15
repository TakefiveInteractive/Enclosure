//
//  RegisterView.swift
//  Enclosure
//
//  Created by Kedan Li on 3/12/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit
import Security

class RegisterViewController: UIViewController {
    
    @IBOutlet var done: UIButton!
    @IBOutlet var nickNameText: UITextField!
    
    override func viewDidLoad() {
        done.addTarget(self, action: "finishInputing:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let userId = Connection.getUserId()
        NSUserDefaults.standardUserDefaults().setObject(userId, forKey: "userId")
        NSUserDefaults.standardUserDefaults().setObject(false, forKey: "registered")

    }
    
    func finishInputing(button: UIButton){
        if nickNameText.text != ""{
            NSUserDefaults.standardUserDefaults().setObject(nickNameText.text!, forKey: "nickName")
            Connection.register(nickNameText.text!)
            self.performSegueWithIdentifier("toMainStart", sender: self)
        }else{
            //tell user text can't be empty
        }
    }
}
