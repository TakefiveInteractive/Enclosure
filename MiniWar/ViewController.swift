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
        
        let lab1 = UILabel(frame: CGRect(x: 0, y: circle1.frame.origin.y + circleLength + 10, width: 200, height: 30))
        lab1.center = CGPoint(x: circle1.center.x, y: lab1.center.y)
        lab1.textColor = UIColor.grayColor()
        lab1.alpha = 0.6
        lab1.textAlignment = NSTextAlignment.Center
        lab1.font = UIFont(name: "Avenir-Light", size: 22.0)
        lab1.text = "I. Rural Land"
        
        circle2.backgroundColor = UIColor.whiteColor()
        circle2.frame = CGRect(x: self.view.frame.width * 1 / 8, y: self.view.frame.width * 1 / 8 + circleLength+200, width: circleLength, height: circleLength)
        circle2.layer.cornerRadius = circleLength / 2
        circle2.layer.shadowRadius = 3
        circle2.layer.shadowOpacity = 0.4
        
        let lab2 = UILabel(frame: CGRect(x: 0, y: circle2.frame.origin.y + circleLength + 10, width: 200, height: 30))
        lab2.center = CGPoint(x: circle1.center.x, y: lab2.center.y)
        lab2.textColor = UIColor.grayColor()
        lab2.alpha = 0.6
        lab2.textAlignment = NSTextAlignment.Center
        lab2.font = UIFont(name: "Avenir-Light", size: 22.0)
        lab2.text = "II. Farm & Village"
        
        circle3.backgroundColor = UIColor.whiteColor()
        circle3.frame = CGRect(x: self.view.frame.width * 1 / 8, y: self.view.frame.width * 1 / 8 + 2 * circleLength + 400, width: circleLength, height: circleLength)
        circle3.layer.cornerRadius = circleLength / 2
        circle3.layer.shadowRadius = 3
        circle3.layer.shadowOpacity = 0.4
        
        let lab3 = UILabel(frame: CGRect(x: 0, y: circle3.frame.origin.y + circleLength + 10, width: 200, height: 30))
        lab3.center = CGPoint(x: circle1.center.x, y: lab3.center.y)
        lab3.textColor = UIColor.grayColor()
        lab3.alpha = 0.6
        lab3.textAlignment = NSTextAlignment.Center
        lab3.font = UIFont(name: "Avenir-Light", size: 22.0)
        lab3.text = "III. War & Chao"
        
        entry.addSubview(rect1)
        entry.addSubview(rect2)


        entry.addSubview(circle1)
        entry.addSubview(circle2)
        entry.addSubview(circle3)
        
        circle1.addTarget(self, action: "toFirst:", forControlEvents: UIControlEvents.TouchUpInside)
        circle2.addTarget(self, action: "toSecond:", forControlEvents: UIControlEvents.TouchUpInside)
        circle3.addTarget(self, action: "toThird:", forControlEvents: UIControlEvents.TouchUpInside)
        
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
        entry.addSubview(lab1)
        entry.addSubview(lab2)
        entry.addSubview(lab3)

        
        // UIColor(red: 239.0/255.0 , green: 239.0/255.0, blue: 244.0/255.0,
        
    }
    
    func toFirst(but:UIButton){
        self.performSegueWithIdentifier("tofirst", sender: self)
    }
    func toSecond(but:UIButton){
        self.performSegueWithIdentifier("tosecond", sender: self)
    }
    func toThird(but:UIButton){
        self.performSegueWithIdentifier("tothird", sender: self)
    }
}

