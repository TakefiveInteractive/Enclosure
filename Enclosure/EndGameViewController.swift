//
//  EndGameViewController.swift
//  Enclosure
//
//  Created by Wang Yu on 3/17/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class EndGameViewController: UIViewController, RankUpdateDelegate{

    @IBOutlet weak var label: UILabel!
    
    @IBOutlet weak var rank: UILabel!
    
    func showWin(player: Int, name: String) {
        label.text = "\(name) Wins!"
    }
    
    func rankUpdate(new: Int, old: Int){
        var suf1 = "th"
        var suf2 = "th"
        if new == 1{
            suf1 = "st"
        }
        if new == 2{
            suf1 = "nd"
        }
        if new == 3{
            suf1 = "rd"
        }
        if old == 1{
            suf2 = "st"
        }
        if old == 2{
            suf2 = "nd"
        }
        if old == 3{
            suf2 = "rd"
        }
        if new <= old{
            rank.text = "Rank \(old)\(suf2) → \(new)\(suf1)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        print(rank.frame)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        (parentViewController as! GameViewController).afterEnd()
    }
    
}
