//
//  Game1ViewController.swift
//  MiniWar
//
//  Created by Kedan Li on 2/20/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class Game2ViewController: UIViewController, GameBoardDelegate {
    
    var game = EnclosureGame2()
    
    @IBOutlet var board: GameBoard2!
    @IBOutlet var player1Score: UILabel!
    @IBOutlet var player0Score: UILabel!
    @IBOutlet var player1Name: UILabel!
    @IBOutlet var player0Name: UILabel!
    @IBOutlet var pause: UIButton!
    @IBOutlet var timer: UIButton!
    
    @IBOutlet var playerRow: Rows!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        board.layer.shadowOpacity = 0.3
        board.layer.shadowRadius = 1.5
        board.delegate = self
        player0Score.text = "0"
        player1Score.text = "0"
        
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
    
    func replay(but: UIButton){
        board.userInteractionEnabled = true
        board.alpha = 1
        game = EnclosureGame2()
        board.buildGame(game)
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
        board.buildGame(game)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
