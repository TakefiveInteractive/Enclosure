//
//  TutorialBoard.swift
//  Enclosure
//
//  Created by Kedan Li on 3/25/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

protocol TutorialDelegate{
    func toNext()
}

class TutorialBoard: GameBoard {
    
    var delegateT: TutorialDelegate?
    
    var stage = 0
    
    var highlight = [[Fence]]()
    var opponent = [[Fence]]()
    
    
    override func buildGame(game: EnclosureGame) {
        super.buildGame(game)
        
        highlighting = true

        highlight = [[game.nodes[4][5].fences[game.nodes[4][6]]!,game.nodes[4][5].fences[game.nodes[4][4]]!],
        [game.nodes[4][4].fences[game.nodes[5][4]]!,game.nodes[5][4].fences[game.nodes[5][5]]!,game.nodes[5][5].fences[game.nodes[4][5]]!],
        [game.nodes[7][6].fences[game.nodes[6][6]]!,game.nodes[6][6].fences[game.nodes[5][6]]!,game.nodes[5][6].fences[game.nodes[4][6]]!],
        [game.nodes[7][6].fences[game.nodes[7][5]]!,game.nodes[7][5].fences[game.nodes[7][4]]!,game.nodes[7][4].fences[game.nodes[7][3]]!],
        [game.nodes[2][0].fences[game.nodes[2][1]]!,game.nodes[2][1].fences[game.nodes[3][1]]!,game.nodes[3][0].fences[game.nodes[3][1]]!],
        [game.nodes[2][2].fences[game.nodes[2][1]]!,game.nodes[2][2].fences[game.nodes[1][2]]!,game.nodes[1][2].fences[game.nodes[1][3]]!],
        [game.nodes[5][4].fences[game.nodes[5][3]]!,game.nodes[5][3].fences[game.nodes[6][3]]!,game.nodes[7][3].fences[game.nodes[6][3]]!],
        [game.nodes[1][3].fences[game.nodes[1][4]]!,game.nodes[1][4].fences[game.nodes[1][5]]!,game.nodes[2][5].fences[game.nodes[1][5]]!],
        [game.nodes[2][5].fences[game.nodes[2][6]]!,game.nodes[2][6].fences[game.nodes[3][6]]!,game.nodes[3][6].fences[game.nodes[4][6]]!],
        [game.nodes[4][2].fences[game.nodes[4][1]]!,game.nodes[4][2].fences[game.nodes[5][2]]!,game.nodes[5][2].fences[game.nodes[5][3]]!],
        [game.nodes[3][1].fences[game.nodes[4][1]]!,game.nodes[4][1].fences[game.nodes[5][1]]!,game.nodes[5][2].fences[game.nodes[5][1]]!],
        [game.nodes[8][1].fences[game.nodes[7][1]]!,game.nodes[7][1].fences[game.nodes[6][1]]!,game.nodes[6][1].fences[game.nodes[5][1]]!],
        [game.nodes[8][1].fences[game.nodes[8][2]]!,game.nodes[8][2].fences[game.nodes[8][3]]!,game.nodes[8][3].fences[game.nodes[8][4]]!],
        [game.nodes[7][6].fences[game.nodes[8][6]]!,game.nodes[8][6].fences[game.nodes[8][5]]!,game.nodes[8][5].fences[game.nodes[8][4]]!],
        [game.nodes[6][1].fences[game.nodes[6][0]]!,game.nodes[6][0].fences[game.nodes[7][0]]!,game.nodes[7][0].fences[game.nodes[8][0]]!],
        [game.nodes[8][3].fences[game.nodes[8][2]]!,game.nodes[8][2].fences[game.nodes[8][1]]!,game.nodes[8][1].fences[game.nodes[8][0]]!]
        ]
        opponent = [[game.nodes[4][3].fences[game.nodes[3][3]]!,game.nodes[3][3].fences[game.nodes[3][4]]!,game.nodes[2][4].fences[game.nodes[3][4]]!],
        [game.nodes[0][4].fences[game.nodes[0][3]]!,game.nodes[0][4].fences[game.nodes[1][4]]!,game.nodes[2][4].fences[game.nodes[1][4]]!],
        [game.nodes[0][2].fences[game.nodes[0][3]]!,game.nodes[0][2].fences[game.nodes[0][1]]!,game.nodes[0][1].fences[game.nodes[0][0]]!],
        [game.nodes[2][0].fences[game.nodes[3][0]]!,game.nodes[2][0].fences[game.nodes[1][0]]!,game.nodes[1][0].fences[game.nodes[0][0]]!],
        [game.nodes[1][0].fences[game.nodes[1][1]]!,game.nodes[1][1].fences[game.nodes[1][2]]!,game.nodes[1][2].fences[game.nodes[0][2]]!],
        [game.nodes[0][3].fences[game.nodes[1][3]]!,game.nodes[2][3].fences[game.nodes[1][3]]!,game.nodes[2][3].fences[game.nodes[3][3]]!],
        [game.nodes[0][4].fences[game.nodes[0][3]]!,game.nodes[0][4].fences[game.nodes[0][5]]!,game.nodes[0][5].fences[game.nodes[0][6]]!],
        [game.nodes[0][7].fences[game.nodes[1][7]]!,game.nodes[1][7].fences[game.nodes[2][7]]!,game.nodes[0][7].fences[game.nodes[0][6]]!],
        [game.nodes[3][0].fences[game.nodes[4][0]]!,game.nodes[4][0].fences[game.nodes[5][0]]!,game.nodes[5][0].fences[game.nodes[5][1]]!],
        [game.nodes[2][7].fences[game.nodes[3][7]]!,game.nodes[3][7].fences[game.nodes[3][6]]!,game.nodes[3][6].fences[game.nodes[3][5]]!],
        [game.nodes[4][4].fences[game.nodes[3][4]]!,game.nodes[3][4].fences[game.nodes[3][5]]!,game.nodes[4][5].fences[game.nodes[3][5]]!],
        [game.nodes[0][7].fences[game.nodes[0][8]]!,game.nodes[0][8].fences[game.nodes[1][8]]!,game.nodes[1][8].fences[game.nodes[2][8]]!],
        [game.nodes[4][7].fences[game.nodes[3][7]]!,game.nodes[3][7].fences[game.nodes[3][8]]!,game.nodes[3][8].fences[game.nodes[2][8]]!],
        [game.nodes[6][8].fences[game.nodes[5][8]]!,game.nodes[5][8].fences[game.nodes[4][8]]!,game.nodes[4][8].fences[game.nodes[3][8]]!],
        [game.nodes[6][8].fences[game.nodes[6][7]]!,game.nodes[6][7].fences[game.nodes[5][7]]!,game.nodes[4][7].fences[game.nodes[5][7]]!]
        ]
        highlightMove()
    }
    
    override func shouldReset() -> Bool {
        var fenceSet = Set<Fence>()
        for index in 0 ..< tempPath.count - 1 {
            fenceSet.insert(tempPath[index].gameElement.fences[tempPath[index + 1].gameElement]!)
        }
        if fenceSet == Set(highlight[stage]){
            return false
        }
        return true
    }
    
    override func afterPlayerMove() {
        super.afterPlayerMove()
        if stage < opponent.count{
            moveToNextStep(opponent[stage])
            stage += 1
            self.delegateT?.toNext()
        }
    }
    
    func highlightMove(){
        UIView.animateWithDuration(1, animations: { () -> Void in
            for fence in self.highlight[self.stage] {
                fence.view.alpha = 0.1
                fence.view.backgroundColor = redOnBoard
            }
            }, completion: { (finish) -> Void in
                self.highlightMoveBack()
        })
    }
    
    func highlightMoveBack(){
        UIView.animateWithDuration(1, animations: { () -> Void in
            for fence in self.highlight[self.stage] {
                fence.view.alpha = 0.5
                fence.view.backgroundColor = redOnBoard
            }
            }, completion: { (finish) -> Void in
                if self.highlighting {
                    self.highlightMove()
                }else{
                    for fence in self.highlight[self.stage] {
                        fence.view.alpha = 1
                    }
                }
        })
    }
    
}
