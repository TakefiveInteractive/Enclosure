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
    var rootBoard: AIBoard
    init(game: EnclosureGame) {
        currentConfiguration = game
        self.rootBoard = AIBoard(bigGame: currentConfiguration)
        super.init()
        if rootBoard.neutralLand.count < (rootBoard.boardSize - 1) * (rootBoard.boardSize - 1) / 3{
            minToExplore = 1
        }
    }
    
    let performance = 3
    var minToExplore = 2
    
    var aiBoardsProcessing = [AIBoard]()
    var aiBoardsDone = [AIBoard]()
    
    func firstPlayerFirstMove()->Set<Set<Int>>{
        //first player first move
        let x = Int(arc4random_uniform(UInt32(rootBoard.boardSize) - 4)) + 2
        let y = Int(arc4random_uniform(UInt32(rootBoard.boardSize) - 4)) + 2
        let possibleMoves = rootBoard.getAllWaysWithoutEmpty([x,y])
        return Tool.randomElementFromSet(possibleMoves)
    }
    
    func secondPlayerFirstMove()->Set<Set<Int>>{
        //second player first move
        let x = Int(arc4random_uniform(UInt32(rootBoard.boardSize) - 4)) + 2
        let y = Int(arc4random_uniform(UInt32(rootBoard.boardSize) - 4)) + 2
        let possibleMoves = rootBoard.getAllWaysWithoutEmpty([x,y])
        return Tool.randomElementFromSet(possibleMoves)
    }
    
    func useBestMove(sortedBestMove: [(AIBoard, Int)])->Set<Set<Int>>{
        let maxScore = sortedBestMove[0].1
        var bestResults = [AIBoard]()
        for r in sortedBestMove{
            if r.1 == maxScore{
                bestResults.append(r.0)
            }else{
                break
            }
        }
        return Tool.randomElementFromArray(bestResults).originalMoves
    }
    
    
    func calculateNextStep()->Set<Set<Int>>{
        getAllPossibleMove()
        
        if rootBoard.playerLastMoves[rootBoard.otherPlayer()].count == 0{
            return firstPlayerFirstMove()
        }else if rootBoard.playerLastMoves[rootBoard.playerToGo].count == 0{
            return secondPlayerFirstMove()
        }else{
            
            let enemyBoard = AIBoard(copy: rootBoard)
            enemyBoard.playerToGo = (enemyBoard.playerToGo+1) % 2
            let sortedBestEnemyMove = searchAllPossibleRoutes(enemyBoard)
            let sortedBestSelfMove = searchAllPossibleRoutes(rootBoard)
            if sortedBestEnemyMove[0].1 <= minToExplore && sortedBestSelfMove[0].1 <= minToExplore{
                // explore when both have under minToExplore
                print("explore when both have under 2")
                var bestCombinedMoves = self.freeSearch(self.rootBoard)
                
                if bestCombinedMoves[0].1 > sortedBestSelfMove[0].1 * 2{
                    let maxScore = bestCombinedMoves[0].1
                    var bestResults = [(AIBoard, Int)]()
                    for r in bestCombinedMoves{
                        if r.1 == maxScore{
                            bestResults.append((r.0, r.0.concurrent))
                        }else{
                            break
                        }
                    }
                    //use most concurent
                    bestResults = bestResults.sort{$0.1 > $1.1}
                    return bestResults[0].0.originalMoves
                }else{
                    return useBestMove(sortedBestSelfMove)
                }
                
            }else{
                if sortedBestSelfMove[0].1 >= sortedBestEnemyMove[0].1{
                    // bigger advantage advance self
                    print("self has bigger advantage")
                    return useBestMove(sortedBestSelfMove)
                    
                }else{
                    //enemy has bigger advantage
                    print("enemy has bigger advantage")
                    var commonEnemyBoard = [(Set<Int>):[AIBoard]]()
                    for r in sortedBestEnemyMove{
                        let tempSet = Set(r.0.playerLand[r.0.otherPlayer()])
                        if commonEnemyBoard[tempSet] != nil{
                            commonEnemyBoard[tempSet]!.append(r.0)
                        }else{
                            commonEnemyBoard[tempSet] = [r.0]
                        }
                        if commonEnemyBoard.count > performance{
                            break
                        }
                    }
                    var allBestPoints = Set<Int>()
                    for commonArea in commonEnemyBoard.keys{
                        var commonSet = Set<Int>()
                        for board in commonEnemyBoard[commonArea]!{
                            var bestPoints = Set<Int>()
                            for move in Array(board.originalMoves){
                                bestPoints.insert(Array(move)[0])
                                bestPoints.insert(Array(move)[1])
                            }
                            if commonSet.count == 0{
                                commonSet = bestPoints
                            }else{
                                commonSet = commonSet.intersect(bestPoints)
                            }
                        }
                        allBestPoints = Tool.mergeSet(allBestPoints, smallset: commonSet)
                    }
                    
                    var moveCombine = Set<Int>()
                    for dot in rootBoard.playerLastMoves[rootBoard.otherPlayer()]{
                        moveCombine = Tool.mergeSet(moveCombine, smallset: dot)
                    }
                    allBestPoints = allBestPoints.intersect(moveCombine)
                    print(allBestPoints)
                    let sortedBestCombineMove = twoStepSpecificSearch(rootBoard, points: allBestPoints)
                    
                    let maxCombinedScore = sortedBestCombineMove[0].1
                    if maxCombinedScore + sortedBestEnemyMove[0].1 >= sortedBestSelfMove[0].1{
                        var bestCombinedResults = [AIBoard]()
                        for r in sortedBestCombineMove{
                            if r.1 == maxCombinedScore{
                                bestCombinedResults.append(r.0)
                            }else{
                                break
                            }
                        }
                        return Tool.randomElementFromArray(bestCombinedResults).originalMoves
                    }else{
                        
                        return useBestMove(sortedBestSelfMove)
                    }
                }
            }
        }
    }
    
    func searchAllPossibleRoutes(startBoard: AIBoard)->[(AIBoard, Int)]{
        
        aiBoardsProcessing = [AIBoard]()
        aiBoardsDone = [AIBoard]()
        startBoard.gameTree = [AIBoard]()
        
        var dots = Set<Int>()
        for lastMove in startBoard.playerLastMoves[startBoard.playerToGo]{
            dots = Tool.mergeSet(dots, smallset: lastMove)
        }
        var ways = Set<Set<Set<Int>>>()
        for dot in dots{
            ways = Tool.mergeSet(ways, smallset: startBoard.getAllWaysWithoutEmpty([dot/10,dot%10]))
        }
        print(dots)
        for way in ways{
            let tempBoard = AIBoard(copy: startBoard)
            tempBoard.depth += 1
            tempBoard.playerMove(way)
            tempBoard.originalMoves = way
            startBoard.gameTree.append(tempBoard)
            aiBoardsDone.append(tempBoard)
        }

        toDepthTruncate(1)
        for b in aiBoardsDone{
            let polygons = b.searchPolygon(b.playerFence[b.otherPlayer()])
            b.updateArea(polygons)
        }

        return determineAction(startBoard, incremental: false).sort{$0.1 > $1.1}
    }
    
    func twoStepEmptySearch(startBoard: AIBoard, oways: Set<Set<Set<Int>>>)->[(AIBoard, Int)]{
        
        var ways = oways
        
        aiBoardsProcessing = [AIBoard]()
        aiBoardsDone = [AIBoard]()
        startBoard.gameTree = [AIBoard]()
        
        if ways.count == 0{
            for lastMoveDot in rootBoard.playerLastMoves[rootBoard.otherPlayer()].last!{
                ways = Tool.mergeSet(ways, smallset: startBoard.getAllWaysWithoutEmpty([lastMoveDot/10, lastMoveDot%10]))
            }
            for lastMoveDot in rootBoard.playerLastMoves[rootBoard.playerToGo].last!{
                ways = Tool.mergeSet(ways, smallset: startBoard.getAllWaysWithoutEmpty([lastMoveDot/10, lastMoveDot%10]))
            }
        }
        
        for way in ways{
            let tempBoard = AIBoard(copy: startBoard)
            tempBoard.depth += 1
            tempBoard.playerMove(way)
            tempBoard.originalMoves = way
            startBoard.gameTree.append(tempBoard)
            aiBoardsDone.append(tempBoard)
        }
        
        toDepth(1)
        
        for b in aiBoardsDone{
            let polygons = b.searchPolygon(b.playerFence[b.otherPlayer()])
            b.updateArea(polygons)
        }
        
        toDepth(2)
        
        var playerDistinct = [(Set<Set<Int>>):AIBoard]()
        for b in aiBoardsDone{
            let pFence = b.playerFence[b.otherPlayer()]
            if let val = playerDistinct[pFence]{
                b.identicalUpdate(val)
            }else{
                let polygons = b.searchPolygon(b.playerFence[b.otherPlayer()])
                b.updateArea(polygons)
                playerDistinct[pFence] = b
            }
        }
        return determineAction(startBoard, incremental: false).sort{$0.1 > $1.1}
    }
    
    func freeSearch(startBoard: AIBoard)->[(AIBoard, Int)]{
        
        print(aiBoardsDone.count)
        var distinceBoard = [(Set<Set<Int>>): AIBoard]()
        for index in 0 ..< startBoard.gameTree.count {
            let b = startBoard.gameTree[index]
            let current = (b.playerToGo + 1) % 2
            b.playerToGo = current
            let identicalB = distinceBoard[b.playerFence[current]]
            if identicalB == nil {
                aiBoardsProcessing.append(b)
                distinceBoard[b.playerFence[current]] = b
            }else{
                startBoard.gameTree.removeAtIndex(index)
            }
        }
        
        let limit = 30
        
        while aiBoardsProcessing.count > limit{
            let randIndex = Int(arc4random_uniform(UInt32(aiBoardsProcessing.count) - 1))
            aiBoardsProcessing.removeAtIndex(randIndex)
        }
        
        aiBoardsDone = aiBoardsProcessing
        aiBoardsProcessing = [AIBoard]()
        print(aiBoardsDone.count)
        
        toDepthTruncate(2)
        
        var playerDistinct = [(Set<Set<Int>>):AIBoard]()
        for b in aiBoardsDone{
            let pFence = b.playerFence[b.otherPlayer()]
            if let val = playerDistinct[pFence]{
                b.identicalUpdate(val)
                val.concurrent += 1
                b.concurrent = val.concurrent
                
            }else{
                let polygons = b.searchPolygon(b.playerFence[b.otherPlayer()])
                b.updateArea(polygons)
                playerDistinct[pFence] = b
            }
        }

        return determineAction(startBoard, incremental: true).sort{$0.1 > $1.1}
    }
    
    func twoStepSpecificSearch(startBoard: AIBoard, points: Set<Int>)->[(AIBoard, Int)]{
        
        aiBoardsProcessing = [AIBoard]()
        aiBoardsDone = [AIBoard]()
        startBoard.gameTree = [AIBoard]()
        
        var ways = Set<Set<Set<Int>>>()
        for lastMoveDot in points{
            ways = Tool.mergeSet(ways, smallset: startBoard.getAllWaysWithoutEmpty([lastMoveDot / 10,lastMoveDot % 10]))
        }
        for way in ways{
            let tempBoard = AIBoard(copy: startBoard)
            tempBoard.depth += 1
            tempBoard.playerMove(way)
            tempBoard.originalMoves = way
            startBoard.gameTree.append(tempBoard)
            aiBoardsDone.append(tempBoard)
        }
        
        toDepthSpecificPoints(1, points: points)
        
        for b in aiBoardsDone{
            let polygons = b.searchPolygon(b.playerFence[b.otherPlayer()])
            b.updateArea(polygons)
        }
        
        toDepthSpecificPoints(2, points: points)
        
        var playerDistinct = [(Set<Set<Int>>):AIBoard]()
        for b in aiBoardsDone{
            let pFence = b.playerFence[b.otherPlayer()]
            if playerDistinct[pFence] != nil{
                b.identicalUpdate(playerDistinct[pFence]!)
            }else{
                let polygons = b.searchPolygon(b.playerFence[b.otherPlayer()])
                b.updateArea(polygons)
                playerDistinct[pFence] = b
            }
        }

        return determineAction(startBoard, incremental: false).sort{$0.1 > $1.1}
    }
    
    func toDepthSpecificPoints(depth: Int, points: Set<Int>){
        
        aiBoardsProcessing = aiBoardsDone
        aiBoardsDone = [AIBoard]()
        
        var indexer = 0
        while aiBoardsProcessing.count > 0{
            let lastBoard = aiBoardsProcessing[indexer]
            if lastBoard.depth < depth{
                var ways = Set<Set<Set<Int>>>()
                for dot in points{
                    ways = Tool.mergeSet(ways, smallset: lastBoard.getAllWaysWithoutEmpty([dot/10, dot%10]))
                }
                for w in ways{
                    let newBoard = AIBoard(copy: lastBoard)
                    newBoard.depth += 1
                    newBoard.playerMove(w)
                    lastBoard.gameTree.append(newBoard)
                    aiBoardsProcessing.append(newBoard)
                }
            }else{
                aiBoardsDone.append(aiBoardsProcessing[indexer])
            }
            aiBoardsProcessing.removeAtIndex(indexer)
            indexer += 1
            if indexer > aiBoardsProcessing.count - 1{
                indexer = 0
            }
        }
    }

    func toDepthTruncate(depth: Int){
        
        aiBoardsProcessing = aiBoardsDone
        aiBoardsDone = [AIBoard]()
        
        var indexer = 0
        while aiBoardsProcessing.count > 0{
            let lastBoard = aiBoardsProcessing[indexer]
            if lastBoard.depth < depth{
                
                var ways =  Set<Set<Set<Int>>>()
                for lastMoveDot in lastBoard.playerLastMoves[lastBoard.playerToGo].last!{
                    if lastBoard.explorableEdgeFromPoint(lastMoveDot) == 3 {
                        ways = Tool.mergeSet(ways, smallset: lastBoard.getAllWaysWithoutEmpty([lastMoveDot/10, lastMoveDot%10]))
                    }
                }
                if ways.count == 0{
                    for lastMoveDot in lastBoard.playerLastMoves[lastBoard.playerToGo].last!{
                        if lastBoard.explorableEdgeFromPoint(lastMoveDot) == 2 {
                            ways = Tool.mergeSet(ways, smallset: lastBoard.getAllWaysWithoutEmpty([lastMoveDot/10, lastMoveDot%10]))
                        }
                    }
                }
                if ways.count == 0{
                    for lastMoveDot in lastBoard.playerLastMoves[lastBoard.playerToGo].last!{
                        if lastBoard.explorableEdgeFromPoint(lastMoveDot) == 1 {
                            ways = Tool.mergeSet(ways, smallset: lastBoard.getAllWaysWithoutEmpty([lastMoveDot/10, lastMoveDot%10]))
                        }
                    }
                }
                for w in ways{
                    let newBoard = AIBoard(copy: lastBoard)
                    newBoard.depth += 1
                    newBoard.playerMove(w)
                    lastBoard.gameTree.append(newBoard)
                    aiBoardsProcessing.append(newBoard)
                }
            }else{
                aiBoardsDone.append(aiBoardsProcessing[indexer])
            }
            aiBoardsProcessing.removeAtIndex(indexer)
            indexer += 1
            if indexer > aiBoardsProcessing.count - 1{
                indexer = 0
            }
        }
    }
    
    func toDepth(depth: Int){
        
        aiBoardsProcessing = aiBoardsDone
        aiBoardsDone = [AIBoard]()
        
        var indexer = 0
        while aiBoardsProcessing.count > 0{
            let lastBoard = aiBoardsProcessing[indexer]
            if lastBoard.depth < depth{
                var ways = Set<Set<Set<Int>>>()
                for lastMoveDot in lastBoard.playerLastMoves[lastBoard.otherPlayer()].last!{
                    ways = Tool.mergeSet(ways, smallset: lastBoard.getAllWaysWithoutEmpty([lastMoveDot/10, lastMoveDot%10]))
                }
                for lastMoveDot in lastBoard.playerLastMoves[lastBoard.playerToGo].last!{
                    ways = Tool.mergeSet(ways, smallset: lastBoard.getAllWaysWithoutEmpty([lastMoveDot/10, lastMoveDot%10]))
                }
                for w in ways{
                    let newBoard = AIBoard(copy: lastBoard)
                    newBoard.depth += 1
                    newBoard.playerMove(w)
                    lastBoard.gameTree.append(newBoard)
                    aiBoardsProcessing.append(newBoard)
                }
            }else{
                aiBoardsDone.append(aiBoardsProcessing[indexer])
            }
            aiBoardsProcessing.removeAtIndex(indexer)
            indexer += 1
            if indexer > aiBoardsProcessing.count - 1{
                indexer = 0
            }
        }
    }
    
    func getAllPossibleMove(){
        var total = 0
        for x in 0 ..< self.rootBoard.boardSize {
            for y in 0 ..< self.rootBoard.boardSize {
                total = total + self.rootBoard.getAllWaysWithoutEmpty([x,y]).count
            }
        }
    }
    
    func calculateScore(bd: AIBoard , previousVal: Int, incremental: Bool){
        for board in bd.gameTree{
            if board.gameTree.count == 0{
                possibilities.append((board, board.playerGain[board.otherPlayer()].count + previousVal))
            }else{
                var results = [(AIBoard, Int)]()
                for child in board.gameTree{
                    results.append((child, child.playerGain[child.otherPlayer()].count))
                }
                let sortedResult =  results.sort {$0.1 < $1.1}
                var total = previousVal + board.playerGain[board.otherPlayer()].count - sortedResult.last!.1
                if incremental{
                    total = previousVal + board.playerGain[board.otherPlayer()].count + sortedResult.last!.1
                }
                if sortedResult.last!.0.gameTree.count > 0{
                    //more to explore
                    calculateScore(sortedResult.last!.0, previousVal: total, incremental: incremental)
                }else{
                    possibilities.append((sortedResult.last!.0, total))
                }
            }
        }
    }
    var possibilities = [(AIBoard, Int)]()
    func determineAction(board: AIBoard, incremental: Bool)->[(AIBoard, Int)]{
        possibilities = [(AIBoard, Int)]()
        calculateScore(board, previousVal: 0, incremental:  incremental)
        return possibilities
    }
    
}

