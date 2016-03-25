//
//  TutorialViewController.swift
//  Enclosure
//
//  Created by Kedan Li on 3/24/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class TutorialViewController: GameViewController {
    
    var stage = 0
    
    var informations = ["Welcome to Enclosure! \n \n The goal of the game is to capture areas wirh fences. \n *Now, set up your first fences by dragging on the dots!*",
                        ]
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        showGuide()
    }
    
    override func pause(but: UIButton){
        showGuide()
    }
    
    func showGuide(){
        let guideControl = self.storyboard?.instantiateViewControllerWithIdentifier("guideView") as! GuideViewController
        guideControl.view.alpha = 0
        guideControl.modalPresentationStyle = .OverCurrentContext
        guideControl.info.text = informations[stage]
        self.addChildViewController(guideControl)
        view.addSubview(guideControl.view)
        guideControl.view.alpha = 0
        UIView.animateWithDuration(0.4) { () -> Void in
            guideControl.view.alpha = 0.9
        }
    }
}
