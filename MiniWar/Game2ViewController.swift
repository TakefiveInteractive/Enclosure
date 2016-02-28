//
//  Game1ViewController.swift
//  MiniWar
//
//  Created by Kedan Li on 2/20/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class Game2ViewController: UIViewController, GameBoardDelegate {
    
    @IBOutlet var board: GameBoard!
    @IBOutlet var player1Score: UILabel!
    @IBOutlet var player0Score: UILabel!

    @IBOutlet var player1row: Rows!
    @IBOutlet var player0row: Rows!
    @IBOutlet var restart: UIButton!

    var game = EnclosureGame()

    func endGame(winPlayer: Int) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        board.layer.shadowOpacity = 0.3
        board.layer.shadowRadius = 1.5
        board.delegate = self
        
        player0row.color = player0Score.textColor
        player1row.color = player1Score.textColor
        restart.addTarget(self, action: "replay:", forControlEvents: UIControlEvents.TouchUpInside)

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func updateScoreLabel(player: Int) {
        if player == 0{
            player0Score.text = String(1)
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
            player1Score.text = String(1)
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
    
    func animateScore(area: Area, score: Int, player: Int){
        var lab = UILabel(frame: CGRect(x: 0, y: 0, width: board.unitWidth * 1.5, height: board.unitWidth * 1.5))
        lab.center = lab.convertPoint(area.center, fromView: area)
        lab.textColor = board.playerColors[game.currentPlayer()]
        lab.alpha = 1
        lab.textAlignment = NSTextAlignment.Center
        lab.font = UIFont(name: "Avenir-Light", size: 20.0)
        lab.text = "+\(score)"
        self.view.addSubview(lab)
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            lab.alpha = 0
            if player == 0{
                lab.center == self.player0Score.center
            }else{
                lab.center == self.player1Score.center
            }
            }) { (haha) -> Void in
                
        }
    }
    
    func replay(but: UIButton){
        board.buildGame(game)
    }
    
    func updateScore(playerscore: [Int]) {
        player1Score.text = String(playerscore[1])
        player0Score.text = String(playerscore[0])
    }
    
    func showTotalRow(player: Int, row: Int) {
        if player == 0{
            player0row.changeBarNum(row)
        }else if player == 1{
            player1row.changeBarNum(row)
        }
    }
    
    func setTotalRow(player: Int, row: Int) {
        if player == 0{
            player0row.changeBarNum(row)
        }else if player == 1{
            player1row.changeBarNum(row)
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
