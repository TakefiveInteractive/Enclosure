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
    var circle2 = UIButton()
    var circle3 = UIButton()
    var rect1 = UIView()
    var rect2 = UIView()


    
    var circleLength: CGFloat = 0
    var lineLength: CGFloat = 0
    var lineWidth: CGFloat = 0


    override func viewDidAppear(animated: Bool) {
        
        entry.contentSize = CGSizeMake(self.view.frame.width, self.view.frame.width*4)
        
        circleLength = self.view.frame.width * 0.75
        lineLength = 200 + self.view.frame.width * 0.75
        lineWidth = self.view.frame.width * 0.5
        
        rect1.backgroundColor = UIColor.init(red: 200/255, green: 226/255, blue: 241/255, alpha: 1)
        rect1.frame = CGRect(x: self.view.frame.width * 1 / 4, y: self.view.frame.width * 1 / 8 + circleLength/2, width: lineWidth, height: lineLength)
        rect1.layer.shadowRadius = 3
        rect1.layer.shadowOpacity = 0.4
        
        rect2.backgroundColor =  UIColor.init(red: 249/255, green: 208/255, blue: 213/255, alpha: 1)
        rect2.frame = CGRect(x: self.view.frame.width * 1 / 4, y: self.view.frame.width * 1 / 8 + circleLength*3/2 + circleLength, width: lineWidth, height: lineLength)
        rect2.layer.shadowRadius = 3
        rect2.layer.shadowOpacity = 0.4
        
        
        circle1.backgroundColor = UIColor.whiteColor()
        circle1.frame = CGRect(x: self.view.frame.width * 1 / 8, y: self.view.frame.width * 1 / 8, width: circleLength, height: circleLength)
        circle1.layer.cornerRadius = circleLength / 2
        circle1.layer.shadowRadius = 3
        circle1.layer.shadowOpacity = 0.4
        
        
        circle2.backgroundColor = UIColor.whiteColor()
        circle2.frame = CGRect(x: self.view.frame.width * 1 / 8, y: self.view.frame.width * 1 / 8 + circleLength+200, width: circleLength, height: circleLength)
        circle2.layer.cornerRadius = circleLength / 2
        circle2.layer.shadowRadius = 3
        circle2.layer.shadowOpacity = 0.4
        
        
        circle3.backgroundColor = UIColor.whiteColor()
        circle3.frame = CGRect(x: self.view.frame.width * 1 / 8, y: self.view.frame.width * 1 / 8 + 2 * circleLength + 400, width: circleLength, height: circleLength)
        circle3.layer.cornerRadius = circleLength / 2
        circle3.layer.shadowRadius = 3
        circle3.layer.shadowOpacity = 0.4
        
        
        entry.addSubview(rect1)
        entry.addSubview(rect2)


        entry.addSubview(circle1)
        entry.addSubview(circle2)
        entry.addSubview(circle3)
        
        circle1.addTarget(self, action: "toFirst:", forControlEvents: UIControlEvents.TouchUpInside)
        circle2.addTarget(self, action: "toFirst:", forControlEvents: UIControlEvents.TouchUpInside)
        circle3.addTarget(self, action: "toFirst:", forControlEvents: UIControlEvents.TouchUpInside)
        
        let img1 = UIImage(named: "1.jpg")
        let img2 = UIImage(named: "2.png")
        let img3 = UIImage(named: "3.png")
        
        
        
        let img1V = UIImageView(frame: CGRectMake(0, 0, circleLength*0.6, circleLength*0.6))
        img1V.center = circle1.center
        img1V.image = img1
        img1V.alpha = 0.75
        
        let img2V = UIImageView(frame: CGRectMake(0, 0, circleLength*0.6, circleLength*0.6))
        img2V.center = circle2.center
        img2V.image = img2
        img2V.alpha = 0.75
        
        let img3V = UIImageView(frame: CGRectMake(0, 0, circleLength*0.6, circleLength*0.6))
        img3V.center = circle3.center
        img3V.image = img3
        img3V.alpha = 0.75
        
        entry.addSubview(img1V)
        entry.addSubview(img2V)
        entry.addSubview(img3V)
        
        
        // UIColor(red: 239.0/255.0 , green: 239.0/255.0, blue: 244.0/255.0,
        
    }
    
    func toFirst(but:UIButton){
        self.performSegueWithIdentifier("tofirst", sender: self)
    }
}

