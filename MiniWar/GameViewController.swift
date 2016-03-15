//
//  GameViewController.swift
//  Enclosure
//
//  Created by Kedan Li on 3/14/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, GameBoardDelegate {
    
    var nstimer = NSTimer()
    var game: EnclosureGame!
    var timePassed = 0
    var isPaused = false
    
    @IBOutlet var board: GameBoard!
    @IBOutlet var player1Score: UILabel!
    @IBOutlet var player0Score: UILabel!
    @IBOutlet var player1Name: UILabel!
    @IBOutlet var player0Name: UILabel!
    @IBOutlet var pause: UIButton!
    @IBOutlet var timer: UILabel!
    
    @IBOutlet var playerRow: Rows!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        board.layer.shadowOpacity = 0.3
        board.layer.shadowRadius = 1.5
        board.delegate = self
        player0Score.text = "0"
        player1Score.text = "0"
        pause.addTarget(self, action: "pause:", forControlEvents: UIControlEvents.TouchUpInside)
        timer.userInteractionEnabled = false
        timer.text = "0s"
        
        nstimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timing", userInfo: nil, repeats: true)
    }
    
    func timing(){
        if !isPaused{
            timePassed++
            dispatch_async(dispatch_get_main_queue(), {
                self.timer.text = "\(self.timePassed)s"
            })
        }
    }
    func resetTimer(){
        timePassed = 0
    }
    
    func pause(but: UIButton){
        let pauseContr = self.storyboard?.instantiateViewControllerWithIdentifier("pauseView") as! PauseViewController
        pauseContr.view.alpha = 0
        self.addChildViewController(pauseContr)
        view.addSubview(pauseContr.view)
        UIView.animateWithDuration(0.4) { () -> Void in
            pauseContr.view.alpha = 1
        }
        isPaused = true
    }

    func exit(){
        self.performSegueWithIdentifier("exit", sender: self)
    }
    
    //        let backgroundView = UIView(frame: view.bounds)
    //        backgroundView.backgroundColor = UIColor(gradientStyle:UIGradientStyle.LeftToRight, withFrame:view.bounds, andColors:[UIColor(hexString: "F7959D"), UIColor(hexString: "78B4FF")])
    //        backgroundView.alpha = 0.4
    //        view.addSubview(backgroundView)
    //        view.sendSubviewToBack(backgroundView)
    // Do any additional setup after loading the view, typically from a nib.
    
    func animateScore(area: Area, score: Int, player: Int){
        
        let lab = UILabel(frame: CGRect(x: 0, y: 0, width: board.unitWidth * 1.5, height: board.unitWidth * 1.5))
        lab.center = self.view.convertPoint(area.center, fromView: board)
        lab.textColor = board.playerColors[player]
        lab.alpha = 1
        lab.textAlignment = NSTextAlignment.Center
        lab.font = UIFont(name: "Avenir-Light", size: 30.0)
        lab.text = "+\(score)"
        self.view.addSubview(lab)
        let duration = Double(arc4random_uniform(10)) * 0.08 + 1
        UIView.animateWithDuration(duration, animations: { () -> Void in
            lab.alpha = 0
            if player == 0{
                lab.transform = CGAffineTransformMakeTranslation(self.player0Score.center.x - lab.center.x, self.player0Score.center.y - lab.center.y)
                
            }else{
                lab.transform = CGAffineTransformMakeTranslation(self.player1Score.center.x - lab.center.x, self.player1Score.center.y - lab.center.y)
            }
            }) { (haha) -> Void in
                lab.removeFromSuperview()
        }
    }
    
    func replay(){
        board.userInteractionEnabled = true
        board.alpha = 1
        game = EnclosureGame()
        board.buildGame(game)
        resetTimer()
    }
    
    func endGame(winPlayer: Int) {
        if winPlayer == 1{
            player1Score.text = "WIN"
        }else{
            player0Score.text = "WIN"
        }
        board.userInteractionEnabled = false
        board.alpha = 0.7
    }
    
    func updateScoreLabel(player: Int) {
        if player == 0{
            player0Score.text = String(game.playerScore[player])
            UIView.animateWithDuration(0.3, delay: 0.8, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.player0Score.transform = CGAffineTransformMakeScale(1.5, 1.5)
                }, completion: { (finish) -> Void in
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.player0Score.transform = CGAffineTransformMakeScale(1, 1)
                        }, completion: { (finish) -> Void in
                            self.player0Score.tag = -2
                    })
            })
            
        }else{
            player1Score.text = String(game.playerScore[player])
            UIView.animateWithDuration(0.3, delay: 0.8, options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                self.player1Score.transform = CGAffineTransformMakeScale(1.5, 1.5)
                }, completion: { (finish) -> Void in
                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                        self.player1Score.transform = CGAffineTransformMakeScale(1, 1)
                        }, completion: { (finish) -> Void in
                            self.player1Score.tag = -2
                    })
            })
        }
    }
    
    func showTotalRow(player: Int, row: Int) {
        if player == 0{
            playerRow.changeBarNum(row, color: player0Score.textColor)
        }else{
            playerRow.changeBarNum(row, color: player1Score.textColor)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        game = EnclosureGame()
        board.buildGame(game)
    }
}



class Rows: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor.clearColor()
    }
    
    let length:CGFloat = 60
    var views = [UIView]()
    
    func changeBarNum(num : Int, color: UIColor){
        
        for v in views{
            v.removeFromSuperview()
        }
        views = [UIView]()
        let startIndex: CGFloat = (self.frame.width - (length * CGFloat(num) + 10 * CGFloat(num - 1))) / 2
        for var index = 0; index < num; index++ {
            let v = UIView(frame: CGRect(x: startIndex + (10.0 + length) * CGFloat(index), y: 0, width: length, height: 6))
            v.backgroundColor = color
            views.append(v)
            self.addSubview(v)
        }
    }
    
}
