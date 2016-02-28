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
    init(game: EnclosureGame) {
        currentConfiguration = game
        self.rootBoard = AIBoard(bigGame: currentConfiguration)
        super.init()
    }
    
    func calculateNextStep(){
        getAllPossibleMove()
        if rootBoard.playerLastMoves[(rootBoard.playerToGo+1)%2].count == 0{
            //first player first move
            let x = Int(arc4random_uniform(UInt32(rootBoard.boardSize) - 4)) + 2
            let y = Int(arc4random_uniform(UInt32(rootBoard.boardSize) - 4)) + 2
            let possibleMoves = rootBoard.getAllWays([x,y])
            
        }else if rootBoard.playerLastMoves[rootBoard.playerToGo].count == 0{
            //second player first move
//            var ways = Set<Set<Set<Int>>>()
//            for lastMoveDot in rootBoard.playerLastMoves[rootBoard.otherPlayer()].last!{
//                ways = Tool.mergeSet(ways, smallset: self.rootBoard.getAllWays(lastMoveDot))
//            }
//            print(Array(rootBoard.canReachList.keys))

        }else{
            
            var ways = Set<Set<Set<Int>>>()
            for lastMoveDot in rootBoard.playerLastMoves[rootBoard.otherPlayer()].last!{
                ways = Tool.mergeSet(ways, smallset: self.rootBoard.getAllWaysWithoutEmpty(lastMoveDot))
            }
            for lastMoveDot in rootBoard.playerLastMoves[rootBoard.playerToGo].last!{
                ways = Tool.mergeSet(ways, smallset: self.rootBoard.getAllWaysWithoutEmpty(lastMoveDot))
            }
            
            for way in ways{
                var tempBoard = AIBoard(copy: self.rootBoard)
                tempBoard.playerMove(way)
                tempBoard.originalMoves = way
                aiBoardsProcessing.append(tempBoard)
            }
            
            var indexer = 0
            
            while aiBoardsProcessing.count > 0{
                let lastBoard = aiBoardsProcessing[indexer]
                if lastBoard.depth < 2{
                    var ways = Set<Set<Set<Int>>>()
                    for lastMoveDot in lastBoard.playerLastMoves[lastBoard.otherPlayer()].last!{
                        ways = Tool.mergeSet(ways, smallset: lastBoard.getAllWaysWithoutEmpty(lastMoveDot))
                    }
                    for lastMoveDot in lastBoard.playerLastMoves[lastBoard.playerToGo].last!{
                        ways = Tool.mergeSet(ways, smallset: lastBoard.getAllWaysWithoutEmpty(lastMoveDot))
                    }
                    for w in ways{
                        let newBoard = AIBoard(copy: lastBoard)
                        newBoard.playerMove(w)
                        aiBoardsProcessing.append(newBoard)
                    }
                }else{
                    aiBoardsDone.append(aiBoardsProcessing[indexer])
                }
                aiBoardsProcessing.removeAtIndex(indexer)
                indexer++
                if indexer > aiBoardsProcessing.count - 1{
                    indexer = 0
                }
            }
            print(aiBoardsDone.count)

        }

    }
    
    let proportion = 1.0
    
    var aiBoardsProcessing = [AIBoard]()
    var aiBoardsDone = [AIBoard]()

    func investigateMove(lastBoard: AIBoard, depth: Int, actualMove: Set<Set<Int>>){

        if depth == 0{
            // judge the gain of the current display
        }else{
            // investigate based on last movement
            var ways = Set<Set<Set<Int>>>()
            for lastMoveDot in lastBoard.playerLastMoves[lastBoard.otherPlayer()].last!{
                ways = Tool.mergeSet(ways, smallset: lastBoard.getAllWays(lastMoveDot))
            }
            if lastBoard.playerLastMoves[lastBoard.playerToGo].count > 0{
                for lastMoveDot in lastBoard.playerLastMoves[lastBoard.playerToGo].last!{
                    ways = Tool.mergeSet(ways, smallset: lastBoard.getAllWays(lastMoveDot))
                }
            }
            var wayList = Array(ways)
            var totalTry = Int(proportion * Double(ways.count))
            while totalTry > 0{
                let m = Int(arc4random_uniform(UInt32(wayList.count)))
                var tempBoard = AIBoard(copy: lastBoard)
                tempBoard.playerMove(wayList[m])
                wayList.removeAtIndex(m)
                investigateMove(tempBoard, depth: depth - 1, actualMove: actualMove)
                totalTry--
            }
        }
    }
    

    
    func getAllPossibleMove(){
        
        print(Tool.profile { () -> () in
            for var x = 0; x < self.rootBoard.boardSize; x++ {
                for var y = 0; y < self.rootBoard.boardSize; y++ {
                    self.rootBoard.getAllWays([x,y])
                }
            }
        })

    }
}

class AIBoard: NSObject {
    
    let depth: Int
    
    let playerNum: Int
    let boardSize: Int
    var originalMoves = Set<Set<Int>>()

    var playerToGo: Int
    
    var nodes = [[[Int]]]() //[[(Int,Int)]]()
    var fences = [Set<Int>]() //[((Int,Int),(Int,Int))]()
    var lands = [[[Int]]]()
    
    var playerScore = [Int]()
    var playerFencesNum = [Int]()
    
    var neutralLand = [[Int]]()
    var playerLand = [[[Int]]]()
    
    var neutralFence = Set<Set<Int>>()
    var playerFence = [Set<Set<Int>>]()
    
    var playerLastMoves = [[[[Int]]]]()
    var canReachList = [Int:Set<Set<Set<Int>>>]()
    
    func otherPlayer()->Int{
        return (playerToGo+1)%2
    }
    
    func playerMove(move: Set<Set<Int>>){
        neutralFence = Tool.subtractSet(neutralFence, subset: move)
        playerFence[playerToGo] = Tool.mergeSet(playerFence[playerToGo], smallset: move)
        
        var steps = Set<Int>()
        for f in move{
            steps = Tool.mergeSet(steps, smallset: f)
        }
        var arr = [[Int]]()
        for s in steps{
            arr.append([s/10,s%10])
        }
        playerLastMoves[playerToGo].append(arr)
        playerToGo = (playerToGo + 1)%2
    }
    
    // search all the connectable trace from a node
    
    func getAllWays(startPoint:[Int])->Set<Set<Set<Int>>>{
        
        var tempPath = Set<Set<Set<Int>>>()
        
        let transform = startPoint[0] * 10 + startPoint[1]
        if canReachList[transform] != nil {
            var toRemove = Set<Set<Set<Int>>>()
            for path in canReachList[transform]!{
                for step in path{
                    if !neutralFence.contains(step){
                        toRemove.insert(path)
                        break
                    }
                }
            }
            canReachList[transform] = Tool.subtractSet(canReachList[transform]!, subset: toRemove)
            return canReachList[transform]!
        }else{
            
            func getAllWaysBranch(head:[Int], path: Set<Set<Int>>){
                let raw = head[0] * 10 + head[1]
                if path.count < playerFencesNum[playerToGo]{
                    if head[0] - 1 >= 0{
                        var tp = path
                        if !tp.contains(Set([raw,raw - 10])) && !playerFence[otherPlayer()].contains(Set([raw,raw - 10])){
                            tp.insert(Set([raw,raw - 10]))
                            getAllWaysBranch([head[0] - 1, head[1]], path: tp)
                        }
                    }
                    if head[0] + 1 < boardSize{
                        var tp = path
                        if !tp.contains(Set([raw,raw + 10])) && !playerFence[otherPlayer()].contains(Set([raw,raw + 10])){
                            tp.insert(Set([raw,raw + 10]))
                            getAllWaysBranch([head[0] + 1, head[1]], path: tp)
                        }
                    }
                    if head[1] - 1 >= 0{
                        var tp = path
                        if !tp.contains(Set([raw, raw - 1])) && !playerFence[otherPlayer()].contains(Set([raw, raw - 1])){
                            tp.insert(Set([raw,raw - 1]))
                            getAllWaysBranch([head[0], head[1] - 1], path: tp)
                        }
                    }
                    if head[1] + 1 < boardSize{
                        var tp = path
                        if !tp.contains(Set([raw, raw + 1])) && !playerFence[otherPlayer()].contains(Set([raw, raw + 1])){
                            tp.insert(Set([raw,raw + 1]))
                            getAllWaysBranch([head[0], head[1] + 1], path: tp)
                        }
                    }
                }else{
                    tempPath.insert(path)
                }
            }
            getAllWaysBranch(startPoint, path: Set<Set<Int>>())
        }
        canReachList[transform] = tempPath
        return tempPath
        
    }
    
    func getAllWaysWithoutEmpty(startPoint:[Int])->Set<Set<Set<Int>>>{

        var tempPath = Set<Set<Set<Int>>>()
        
        let transform = startPoint[0] * 10 + startPoint[1]
        if canReachList[transform] != nil {
            var toRemove = Set<Set<Set<Int>>>()
            for path in canReachList[transform]!{
                for step in path{
                    if !neutralFence.contains(step){
                        toRemove.insert(path)
                        break
                    }
                }
            }
            canReachList[transform] = Tool.subtractSet(canReachList[transform]!, subset: toRemove)
            return canReachList[transform]!
        }else{
            
            func getAllWaysBranch(head:[Int], path: Set<Set<Int>>){
                let raw = head[0] * 10 + head[1]
                if path.count < playerFencesNum[playerToGo]{
                    if head[0] - 1 >= 0{
                        var tp = path
                        if !tp.contains(Set([raw,raw - 10])) && neutralFence.contains(Set([raw,raw - 10])){
                            tp.insert(Set([raw,raw - 10]))
                            getAllWaysBranch([head[0] - 1, head[1]], path: tp)
                        }
                    }
                    if head[0] + 1 < boardSize{
                        var tp = path
                        if !tp.contains(Set([raw,raw + 10])) && neutralFence.contains(Set([raw,raw + 10])){
                            tp.insert(Set([raw,raw + 10]))
                            getAllWaysBranch([head[0] + 1, head[1]], path: tp)
                        }
                    }
                    if head[1] - 1 >= 0{
                        var tp = path
                        if !tp.contains(Set([raw, raw - 1])) && neutralFence.contains(Set([raw, raw - 1])){
                            tp.insert(Set([raw,raw - 1]))
                            getAllWaysBranch([head[0], head[1] - 1], path: tp)
                        }
                    }
                    if head[1] + 1 < boardSize{
                        var tp = path
                        if !tp.contains(Set([raw, raw + 1])) && neutralFence.contains(Set([raw, raw + 1])){
                            tp.insert(Set([raw,raw + 1]))
                            getAllWaysBranch([head[0], head[1] + 1], path: tp)
                        }
                    }
                }else{
                    tempPath.insert(path)
                }
            }
            getAllWaysBranch(startPoint, path: Set<Set<Int>>())
        }
        canReachList[transform] = tempPath
        print("eeeeeeee")
        return tempPath
        
    }
    
    
    init(copy: AIBoard) {
        self.playerNum = copy.playerNum
        self.boardSize = copy.boardSize
        self.playerToGo = (copy.playerToGo + 1) % 2
        self.depth = copy.depth + 1
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
        
        self.playerLastMoves = copy.playerLastMoves
        self.canReachList = copy.canReachList
        
        self.originalMoves = copy.originalMoves
    }
    
    init(bigGame: EnclosureGame) {
        self.playerNum = bigGame.playerNum
        self.boardSize = bigGame.boardSize
        self.playerToGo = bigGame.currentPlayer()
        self.depth = 0
        super.init()
        
        playerLastMoves = [[[[Int]]]](count: playerNum, repeatedValue: [[[Int]]]())
        for var p = 0; p < bigGame.prevMovesByUser.count; p++ {
            for m in bigGame.prevMovesByUser[p]{
                var move = [[Int]]()
                for n in m{
                    move.append([n.x, n.y])
                }
                playerLastMoves[p].append(move)
            }
        }
        
        neutralLand = [[Int]]()
        playerLand = [[[Int]]](count: playerNum, repeatedValue: [[Int]]())
        neutralFence = Set<Set<Int>>()
        playerFence = [Set<Set<Int>>](count: playerNum, repeatedValue: Set<Set<Int>>())
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
                    let one = x*10+y
                    let two = (x+1)*10+y
                    fences.append(Set([one, two]))
                    
                    if bigGame.nodes[x][y].fences[bigGame.nodes[x+1][y]]!.player == -1{
                        neutralFence.insert(Set([one, two]))
                    }else{
                        playerFence[bigGame.nodes[x][y].fences[bigGame.nodes[x+1][y]]!.player].insert(Set([one, two]))
                    }
                }
                if y < boardSize - 1{
                    let one = x*10+y
                    let two = x*10+y+1
                    fences.append(Set([one, two]))
                    
                    if bigGame.nodes[x][y].fences[bigGame.nodes[x][y+1]]!.player == -1{
                        neutralFence.insert(Set([one, two]))
                    }else{
                        playerFence[bigGame.nodes[x][y].fences[bigGame.nodes[x][y+1]]!.player].insert(Set([one, two]))                    }
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