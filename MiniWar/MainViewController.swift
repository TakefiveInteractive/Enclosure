//
//  MainViewController.swift
//  Enclosure
//
//  Created by Kedan Li on 3/12/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit
import ChameleonFramework

class MainViewController: UIViewController {
    
    @IBOutlet var back: UIView!
    @IBOutlet var playWithAI: UIButton!
    @IBOutlet var playWithPlayerLocal: UIButton!
    @IBOutlet var rankingTounament: UIButton!
    @IBOutlet var casualRemote: UIButton!
    
    override func viewDidLoad() {
        //add gradient
        self.view.backgroundColor = UIColor(gradientStyle:UIGradientStyle.LeftToRight, withFrame:self.view.bounds, andColors:[UIColor.redColor(), UIColor.blueColor()])
    }
}
