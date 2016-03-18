//
//  EndGameViewController.swift
//  Enclosure
//
//  Created by Wang Yu on 3/17/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class EndGameViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    
    func showWin(player: Int, name: String) {
        label.text = "\(name) Wins!"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
