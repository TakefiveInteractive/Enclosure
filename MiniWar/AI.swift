//
//  AI.swift
//  Enclosure
//
//  Created by Kedan Li on 2/26/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class AI: NSObject {

    let currentConfiguration: EnclosureGame
    let lastSteps: [FenceNode]
    init(game: EnclosureGame, lastSteps: [FenceNode]) {
        currentConfiguration = game
        self.lastSteps = lastSteps
        super.init()
    }
    
    func calculateNextStep(){
        let start = NSDate()
        let gg = AIBoard(bigGame: currentConfiguration)

        var g = [AIBoard]()
        for var x = 0; x < 1000; x++ {
            g.append(AIBoard(copy: gg))
        }
        let end = NSDate();
        let timeInterval: Double = end.timeIntervalSinceDate(start)
        
        print("Time to evaluate problem : \(timeInterval) seconds");
    }
    
}

class AIBoard: NSObject {
    
    let playerNum: Int
    let boardSize: Int

    var nodes = [[(Int,Int)]]()
    var fences = [((Int,Int),(Int,Int))]()
    var lands = [[(Int,Int)]]()
    
    var playerScore = [Int]()
    var playerFencesNum = [Int]()
    
    var neutralLand = [(Int,Int)]()
    var playerLand = [[(Int,Int)]]()
    
    var neutralFence = [((Int,Int),(Int,Int))]()
    var playerFence = [[((Int,Int),(Int,Int))]]()
    
    init(copy: AIBoard) {
        self.playerNum = copy.playerNum
        self.boardSize = copy.boardSize
        super.init()
        
        self.nodes = copy.nodes
        self.fences = copy.fences
        self.lands = copy.lands
        
        self.playerScore = copy.playerScore
        self.playerFencesNum = copy.playerFencesNum
        
        self.neutralLand = copy.neutralLand
        self.playerLand = copy.playerLand
        
        self.neutralFence = copy.neutralFence
        self.playerFence = copy.playerFence

    }
    
    init(bigGame: EnclosureGame) {
        self.playerNum = bigGame.playerNum
        self.boardSize = bigGame.boardSize
        super.init()
        neutralLand = [(Int,Int)]()
        playerLand = [[(Int,Int)]](count: playerNum, repeatedValue: [(Int,Int)]())
        neutralFence = [((Int,Int),(Int,Int))]()
        playerFence = [[((Int,Int),(Int,Int))]](count: playerNum, repeatedValue: [((Int,Int),(Int,Int))]())
        
        //create nodees
        for var x = 0; x < boardSize; x++ {
            nodes.append([(Int,Int)]())
            for var y = 0; y < boardSize; y++ {
                nodes[x].append((x, y))
            }
        }
        
        //create fences
        for var x = 0; x <  boardSize; x++ {
            for var y = 0; y < boardSize; y++ {
                if x < boardSize - 1{
                    fences.append(((x,y),(x+1,y)))
                    
                    if bigGame.nodes[x][y].fences[bigGame.nodes[x+1][y]]!.player == -1{
                        neutralFence.append(((x,y),(x+1,y)))
                    }else{
                        playerFence[bigGame.nodes[x][y].fences[bigGame.nodes[x+1][y]]!.player].append(((x,y),(x+1,y)))
                    }
                }
                if y < boardSize - 1{
                    fences.append(((x,y),(x,y+1)))
                    
                    if bigGame.nodes[x][y].fences[bigGame.nodes[x][y+1]]!.player == -1{
                        neutralFence.append(((x,y),(x,y+1)))
                    }else{
                        playerFence[bigGame.nodes[x][y].fences[bigGame.nodes[x][y+1]]!.player].append(((x,y),(x,y+1)))
                    }
                }
            }
        }
        
        //create lands
        for var x = 0; x <  boardSize; x++ {
            if x < boardSize - 1{
                lands.append([(Int,Int)]())
                for var y = 0; y < boardSize; y++ {
                    if x < boardSize - 1 && y < boardSize - 1{
                        let land = (x,y)
                        lands[x].append(land)
                        if bigGame.lands[x][y].player == -1{
                            neutralLand.append(land)
                        }else{
                            playerLand[bigGame.lands[x][y].player].append(land)
                        }
                    }
                }
            }
        }
        
    }
    
}