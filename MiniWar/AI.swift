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
    let rootBoard: AIBoard
    let lastSteps: [FenceNode]
    init(game: EnclosureGame, lastSteps: [FenceNode]) {
        currentConfiguration = game
        self.lastSteps = lastSteps
        self.rootBoard = AIBoard(bigGame: currentConfiguration, lastMoves:  lastSteps)
        super.init()
    }
    
    func calculateNextStep(){
        
        var possibleMove:Set<Set<Set<NSArray>>> = Set()
        
        let hhh = {
            for var x = 0; x < self.rootBoard.boardSize; x++ {
                for var y = 0; y < self.rootBoard.boardSize; y++ {
                    let r = self.rootBoard.getAllWays([x,y])
                    possibleMove = possibleMove.union(r)
                }
            }
        }
        print(Tool.profile(hhh))
        
        print(possibleMove.count)
    }
}

class AIBoard: NSObject {
    
    
    let playerNum: Int
    let boardSize: Int

    var playerToGo: Int
    
    var nodes = [[[Int]]]() //[[(Int,Int)]]()
    var fences = [Set<NSArray>]() //[((Int,Int),(Int,Int))]()
    var lands = [[[Int]]]()
    
    var playerScore = [Int]()
    var playerFencesNum = [Int]()
    
    var neutralLand = [[Int]]()
    var playerLand = [[[Int]]]()
    
    var neutralFence = [Set<NSArray>]()
    var playerFence = [[Set<NSArray>]]()
    
    var selfLastMoves = [[Int]]()
    var enemyLastMoves = [[Int]]()

    // search all the connectable trace from a node
    
    func getAllWays(startPoint:[Int])->Set<Set<Set<NSArray>>>{
        
        var tempPath = Set<Set<Set<NSArray>>>()
        
        func getAllWaysBranch(head:[Int], path: Set<Set<NSArray>>){
            if path.count < playerFencesNum[playerToGo]{
                if head[0] - 1 >= 0{
                    var tp = path
                    if !tp.contains(Set([head,[head[0] - 1, head[1]]])){
                        tp.insert(Set([head,[head[0] - 1, head[1]]]))
                        getAllWaysBranch([head[0] - 1, head[1]], path: tp)
                    }
                }
                if head[0] + 1 < boardSize{
                    var tp = path
                    if !tp.contains(Set([head,[head[0] + 1, head[1]]])){
                        tp.insert(Set([head,[head[0] + 1, head[1]]]))
                        getAllWaysBranch([head[0] + 1, head[1]], path: tp)
                    }
                }
                if head[1] - 1 >= 0{
                    var tp = path
                    if !tp.contains(Set([head,[head[0], head[1] - 1]])){
                        tp.insert(Set([head,[head[0], head[1] - 1]]))
                        getAllWaysBranch([head[0], head[1] - 1], path: tp)
                    }
                }
                if head[1] + 1 < boardSize{
                    var tp = path
                    if !tp.contains(Set([head,[head[0], head[1] + 1]])){
                        tp.insert(Set([head,[head[0], head[1] + 1]]))
                        getAllWaysBranch([head[0], head[1] + 1], path: tp)
                    }
                }
            }else{
                tempPath.insert(path)
            }
        }
        
        getAllWaysBranch(startPoint, path: Set<Set<NSArray>>())
        
        return tempPath
        
    }
    
    
    init(var copy: AIBoard) {
        self.playerNum = copy.playerNum
        self.boardSize = copy.boardSize
        self.playerToGo = (copy.playerToGo + 1) % 2
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
        
        self.selfLastMoves = copy.selfLastMoves
        self.enemyLastMoves = copy.enemyLastMoves

    }
    
    init(bigGame: EnclosureGame, lastMoves:[FenceNode]) {
        self.playerNum = bigGame.playerNum
        self.boardSize = bigGame.boardSize
        self.playerToGo = bigGame.currentPlayer()
        super.init()
        
        for node in lastMoves{
            self.enemyLastMoves.append([node.x, node.y])
        }
        
        neutralLand = [[Int]]()
        playerLand = [[[Int]]](count: playerNum, repeatedValue: [[Int]]())
        neutralFence = [Set<NSArray>]()
        playerFence = [[Set<NSArray>]](count: playerNum, repeatedValue: [Set<NSArray>]())
        playerFencesNum = bigGame.playerFencesNum
        playerScore = bigGame.playerScore
        
        //create nodees
        for var x = 0; x < boardSize; x++ {
            nodes.append([[Int]]())
            for var y = 0; y < boardSize; y++ {
                nodes[x].append([x, y])
            }
        }
        
        //create fences
        for var x = 0; x <  boardSize; x++ {
            for var y = 0; y < boardSize; y++ {
                if x < boardSize - 1{
                    fences.append(Set([[x,y],[x+1,y]]))
                    
                    if bigGame.nodes[x][y].fences[bigGame.nodes[x+1][y]]!.player == -1{
                        neutralFence.append(Set([[x,y],[x+1,y]]))
                    }else{
                        playerFence[bigGame.nodes[x][y].fences[bigGame.nodes[x+1][y]]!.player].append(Set([[x,y],[x+1,y]]))
                    }
                }
                if y < boardSize - 1{
                    fences.append(Set([[x,y],[x,y+1]]))
                    
                    if bigGame.nodes[x][y].fences[bigGame.nodes[x][y+1]]!.player == -1{
                        neutralFence.append(Set([[x,y],[x,y+1]]))
                    }else{
                        playerFence[bigGame.nodes[x][y].fences[bigGame.nodes[x][y+1]]!.player].append(Set([[x,y],[x,y+1]]))
                    }
                }
            }
        }
        
        //create lands
        for var x = 0; x <  boardSize; x++ {
            if x < boardSize - 1{
                lands.append([[Int]]())
                for var y = 0; y < boardSize; y++ {
                    if x < boardSize - 1 && y < boardSize - 1{
                        let land = [x,y]
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