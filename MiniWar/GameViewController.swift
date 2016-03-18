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
    
    @IBOutlet var baseProgress: ProgressView!
    
    @IBOutlet var playerRow: Rows!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        board.layer.shadowOpacity = 0.3
        board.layer.shadowRadius = 1.5
        board.delegate = self
        player0Score.text = "0"
        player1Score.text = "0"
        player1Name.text = ""
        player0Name.text = ""
        pause.addTarget(self, action: "pause:", forControlEvents: UIControlEvents.TouchUpInside)
        timer.userInteractionEnabled = false
        timer.text = "0s"
        
        nstimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timing", userInfo: nil, repeats: true)
    }

    override func viewDidAppear(animated: Bool) {
        game = EnclosureGame()
        board.buildGame(game)
        baseProgress.build()
        setPlayerNames()
    }
    
    func timing(){
        if !isPaused{
            timePassed++
            dispatch_async(dispatch_get_main_queue(), {
                self.timer.text = "\(self.timePassed)s"
            })
        }
    }
    
    func setPlayerNames(){
        
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
        buildGame()
        resetTimer()
        baseProgress.resetProgress()
        player0Score.text = "0"
        player1Score.text = "0"
        setPlayerNames()
    }
    
    func buildGame(){
        game = EnclosureGame()
        board.buildGame(game)
    }
    
    func endGame(winPlayer: Int) {
        let endContr = self.storyboard?.instantiateViewControllerWithIdentifier("endGame") as! EndGameViewController
        endContr.view.alpha = 0
        endContr.modalPresentationStyle = .OverCurrentContext
        self.addChildViewController(endContr)
        view.addSubview(endContr.view)
        endContr.view.alpha = 0
        UIView.animateWithDuration(0.4) { () -> Void in
            endContr.view.alpha = 0.9
        }
        if winPlayer == 1{
            player1Score.text = "WIN"
            endContr.showWin(winPlayer, name: player1Name.text!)
        }else{
            player0Score.text = "WIN"
            endContr.showWin(winPlayer, name: player0Name.text!)
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
    
    func changeProgress(player: Int){
        let rawTotal = board.calculateTotalScore()
        let percent = CGFloat(game.playerScore[player]) / CGFloat(rawTotal)
        baseProgress.updateProgress(player, percent: percent)
    }
    
    func showTotalRow(player: Int, row: Int) {
        if player == 0{
            playerRow.changeBarNum(row, color: player0Score.textColor)
        }else{
            playerRow.changeBarNum(row, color: player1Score.textColor)
        }
    }
    
}

class ProgressView: UIView{
    
    var p0Progress = UIView()
    var p1Progress = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

    }
    
    func updateProgress(player: Int, percent: CGFloat){
        
        UIView.animateWithDuration(0.5) { () -> Void in
            if player == 0{
                self.p0Progress.frame = CGRect(x: 0, y: 0, width: self.frame.width * percent, height: self.frame.height)
            }else{
                self.p1Progress.frame = CGRect(x: self.frame.width * (1 - percent), y: 0, width: self.frame.width * percent, height: self.frame.height)
            }
        }
    }
    
    func build(){
        p0Progress = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: frame.height))
        p1Progress = UIView(frame: CGRect(x: frame.width, y: 0, width: 0, height: frame.height))
        p0Progress.backgroundColor = redOnBoard
        p1Progress.backgroundColor = blueOnBoard
        self.addSubview(p0Progress)
        self.addSubview(p1Progress)
        layer.cornerRadius = frame.height/4
        p0Progress.layer.cornerRadius = frame.height/4
        p1Progress.layer.cornerRadius = frame.height/4
        
        let centralLine = UIView(frame: CGRect(x: 0, y: -2, width: 1, height: self.frame.height + 4))
        centralLine.backgroundColor = UIColor.blackColor()
        centralLine.center = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        self.addSubview(centralLine)
    }
    
    func resetProgress(){
        UIView.animateWithDuration(0.5) { () -> Void in
            self.p0Progress.frame = CGRect(x: 0, y: 0, width: 0, height: self.frame.height)
            self.p1Progress.frame = CGRect(x: self.frame.width, y: 0, width: 0, height: self.frame.height)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
