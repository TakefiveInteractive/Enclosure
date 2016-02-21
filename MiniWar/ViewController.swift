//
//  ViewController.swift
//  MiniWar
//
//  Created by Kedan Li on 2/20/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var entry: UIScrollView!
    
    var circle1 = UIButton()
    
    var circleLength: CGFloat = 0
    
    override func viewDidAppear(animated: Bool) {
        
        circleLength = self.view.frame.width * 0.75
        
        entry.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.width*3)
        circle1.backgroundColor = UIColor.whiteColor()
        circle1.frame = CGRect(x: self.view.frame.width * 1 / 8, y: self.view.frame.width * 1 / 8, width: circleLength, height: circleLength)
        circle1.layer.cornerRadius = circleLength / 2
        circle1.layer.shadowRadius = 3
        circle1.layer.shadowOpacity = 0.4
        entry.addSubview(circle1)
        circle1.addTarget(self, action: "toFirst:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let img1 = UIImage(named: "2.pic_hd.jpg")
        
        let img1V = UIImageView(frame: CGRectMake(0, 0, circleLength*0.6, circleLength*0.6))
        img1V.center = circle1.center
        img1V.image = img1
        img1V.alpha = 0.75
        entry.addSubview(img1V)
        // UIColor(red: 239.0/255.0 , green: 239.0/255.0, blue: 244.0/255.0,

    }
    
    func toFirst(but:UIButton){
        self.performSegueWithIdentifier("tofirst", sender: self)
    }
}

