//
//  TutorialViewController.swift
//  Enclosure
//
//  Created by Kedan Li on 3/24/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit
import SwiftGifOrigin

class TutorialViewController: GameViewController, TutorialDelegate{
    
    var informations = ["Welcome to Enclosure! \n \n The goal of the game is to capture areas with fences. \n *Now, set up your first fences by dragging on the dots!* \n\n *Tap to continue*",
        "This indicator shows whose turn it is and how many move is left by the player. \n\n *Now, encircle an area!*",
        "Congrat!! \n\n You scored 1 by capturing an area. \n\n The progress bar indicate the percentage of your captured area. \n\n *Now, encircle more areas!*",
        "It's a good strategy to encircle big chunk of areas.",
        "Watch out of your opponent! Time to stop them.",
        "skip",
        "Secure your own area is also important!",
        "The "
        ]
    
    
    
    var images = [UIImage.gifWithName("guide1"), UIImage.gifWithName("guide2"), UIImage(named: "guide3.jpg"), nil, nil, nil,nil,]
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        (board as! TutorialBoard).delegateT = self
        showGuide()
    }
    
    func toNext() {
        showGuide()
    }
    
    override func pause(but: UIButton){
        showGuide()
    }
    
    func showGuide(){
        if informations[(board as! TutorialBoard).stage] != "skip"{

            let guideControl = self.storyboard?.instantiateViewControllerWithIdentifier("guideView") as! GuideViewController
            guideControl.view.alpha = 0
            guideControl.modalPresentationStyle = .OverCurrentContext
            guideControl.info.text = informations[(board as! TutorialBoard).stage]
            if images[(board as! TutorialBoard).stage] != nil{
                guideControl.image.image = images[(board as! TutorialBoard).stage]
            }
            self.addChildViewController(guideControl)
            view.addSubview(guideControl.view)
            guideControl.view.alpha = 0
            UIView.animateWithDuration(0.4) { () -> Void in
                guideControl.view.alpha = 0.9
                self.playerRow.alpha = 0
            }
        }
    }
    
    override func setPlayerNames() {
        player0Name.text = "You"
        player1Name.text = "Trainer"
    }
}
