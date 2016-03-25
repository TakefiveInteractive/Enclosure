//
//  TutorialViewController.swift
//  Enclosure
//
//  Created by Kedan Li on 3/24/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class TutorialViewController: GameViewController {
    override func viewDidAppear(animated: Bool) {
        let endContr = self.storyboard?.instantiateViewControllerWithIdentifier("endGame") as! EndGameViewController
        endContr.view.alpha = 0
        endContr.modalPresentationStyle = .OverCurrentContext
        self.addChildViewController(endContr)
        view.addSubview(endContr.view)
        endContr.view.alpha = 0
        UIView.animateWithDuration(0.4) { () -> Void in
            endContr.view.alpha = 0.9
        }
    }
}
