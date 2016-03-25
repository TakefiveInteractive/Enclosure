//
//  PauseViewController.swift
//  Enclosure
//
//  Created by Kedan Li on 3/14/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class PauseViewController: UIViewController {
    @IBOutlet var resume: UIButton!
    @IBOutlet var restart: UIButton!
    @IBOutlet var exit: UIButton!
    
    override func viewDidLoad() {
        resume.addTarget(self, action: #selector(PauseViewController.removePause(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        restart.addTarget(self, action: "restart:", forControlEvents: UIControlEvents.TouchUpInside)
        exit.addTarget(self, action: #selector(PauseViewController.exit(_:)), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func exit(but: UIButton){
        (parentViewController as! GameViewController).exit()
        removeView()
    }
    
    func restart(but: UIButton){
        (parentViewController as! GameViewController).replay()
        removeView()
    }

    func removePause(but: UIButton){
        removeView()
    }
    
    func removeView(){
        (parentViewController as! GameViewController).isPaused = false
        self.view.userInteractionEnabled = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.alpha = 0
            }) { (finish) -> Void in
                self.view.removeFromSuperview()
                self.removeFromParentViewController()
        }
    }
}
