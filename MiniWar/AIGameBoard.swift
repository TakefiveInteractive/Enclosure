//
//  AIGameBoard.swift
//  Enclosure
//
//  Created by Kedan Li on 3/4/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class AIGameBoard: GameBoard {
    
    var aiPlayer = 0
    
    var hasRestart = false
    
    override func buildGame(game: EnclosureGame) {
        super.buildGame(game)
        
        aiPlayer = Int(arc4random_uniform(10)) % 2
        if aiPlayer == 0{
            afterPlayerMove()
        }
        print(aiPlayer)
    }
    
    var highlighting = false
    
    func highlightLastAIMove(){
        if game.userLastEdges[aiPlayer].count > 0 {
            UIView.animateWithDuration(1, animations: { () -> Void in
                for fence in self.game.userLastEdges[self.aiPlayer].last!{
                    fence.view.alpha = 0.4
                }
                }, completion: { (finish) -> Void in
                    self.highlightLastAIMoveBack()
            })
        }
    }
    
    func highlightLastAIMoveBack(){
        if game.prevMovesByUser[aiPlayer].count > 0 {
            UIView.animateWithDuration(1, animations: { () -> Void in
                for fence in self.game.userLastEdges[self.aiPlayer].last!{
                    fence.view.alpha = 1
                }
                }, completion: { (finish) -> Void in
                    self.highlightLastAIMove()
            })
        }
    }
    
    override func afterPlayerMove(){
        
        super.afterPlayerMove()
        
        if game.currentPlayer() == aiPlayer{
            self.userInteractionEnabled = false
            self.alpha = 0.65
            let ai = AI(game: game)
            let qualityOfServiceClass = QOS_CLASS_BACKGROUND
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            dispatch_async(backgroundQueue, {
                
                let currentState = AIBoard(bigGame: self.game)
                let moves = ai.calculateNextStep()
                var fences = [Fence]()
                var setofNodes = Set<FenceNode>()
                for fence in Array(moves){
                    let fenceArr = Array(fence)
                    let node1 = self.game.nodes[fenceArr[0]/10][fenceArr[0]%10]
                    let node2 = self.game.nodes[fenceArr[1]/10][fenceArr[1]%10]
                    setofNodes.insert(node1)
                    setofNodes.insert(node2)
                    fences.append(node1.fences[node2]!)
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    let currentboard = AIBoard(bigGame: self.game)
                    if currentState.playerFence == currentboard.playerFence{
                        
                        self.moveToNextStep(fences, nodes: Array(setofNodes))
                        if !self.highlighting{
                            self.highlighting = true
                            self.highlightLastAIMove()
                        }
                        self.delegate?.resetTimer()
                    }
                })
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.alpha = 1
                    self.userInteractionEnabled = true
                })
            })
        }
    }
}
