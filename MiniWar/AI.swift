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
    
    var aiBoardsProcessing = [AIBoard]()
    var aiBoardsDone = [AIBoard]()
    
    func calculateNextStep()->Set<Set<Int>>{
        getAllPossibleMove()

        if rootBoard.playerLastMoves[rootBoard.otherPlayer()].count == 0{
            //first player first move
            let x = Int(arc4random_uniform(UInt32(rootBoard.boardSize) - 4)) + 2
            let y = Int(arc4random_uniform(UInt32(rootBoard.boardSize) - 4)) + 2
            let possibleMoves = rootBoard.getAllWays([x,y])
            return Tool.randomElementFromSet(possibleMoves)
            
        }else if rootBoard.playerLastMoves[rootBoard.playerToGo].count == 0{
            //second player first move
            let x = Int(arc4random_uniform(UInt32(rootBoard.boardSize) - 4)) + 2
            let y = Int(arc4random_uniform(UInt32(rootBoard.boardSize) - 4)) + 2
            let possibleMoves = rootBoard.getAllWays([x,y])
            return Tool.randomElementFromSet(possibleMoves)
            
        }else{
            
            if rootBoard.playerLastMoves[rootBoard.otherPlayer()].count == 1{
                let sortedResults = twoStepEmptySearch(self.rootBoard, ways: Set<Set<Set<Int>>>())
                let maxScore = sortedResults[0].1
                var bestResults = [AIBoard]()
                for r in sortedResults{
                    print(r.1)
                    if r.1 == maxScore{
                        bestResults.append(r.0)
                    }else{
                        break
                    }
                }
                return Tool.randomElementFromArray(bestResults).originalMoves

            }else{
                // have more prev move
                
                let enemyBoard = AIBoard(copy: rootBoard)
                enemyBoard.playerToGo = (enemyBoard.playerToGo+1) % 2
                let sortedBestEnemyMove = searchAllPossibleRoutes(enemyBoard)
                let sortedBestSelfMove = searchAllPossibleRoutes(rootBoard)
                
                if sortedBestSelfMove[0].1 >= sortedBestEnemyMove[0].1{
                    // bigger advantage advance self
                    let maxScore = sortedBestSelfMove[0].1
                    var bestResults = [AIBoard]()
                    for r in sortedBestSelfMove{
                        print(r.1)
                        if r.1 == maxScore{
                            bestResults.append(r.0)
                        }else{
                            break
                        }
                    }
                    return Tool.randomElementFromArray(bestResults).originalMoves
                }else{
                    //enemy has bigger advantage
                    print("enemy has bigger advantage")
                    let maxScore = sortedBestEnemyMove[0].1
                    var bestResults = [AIBoard]()
                    for r in sortedBestEnemyMove{
                        print(r.1)
                        if r.1 == maxScore{
                            bestResults.append(r.0)
                        }else{
                            break
                        }
                    }
                    var bestMoves = Set<Set<Int>>()
                    for res in bestResults{
                        bestMoves = Tool.mergeSet(bestMoves, smallset: res.originalMoves)
                    }
                    var bestPoints = Set<Int>()
                    for move in bestMoves{
                        bestPoints.insert(Array(move)[0])
                        bestPoints.insert(Array(move)[1])
                    }
                    print(bestPoints)
                    var combinedWays = Set<Set<Set<Int>>>()
                    for lastMoveDot in bestPoints{
                        combinedWays = Tool.mergeSet(combinedWays, smallset: self.rootBoard.getAllWaysWithoutEmpty([lastMoveDot / 10,lastMoveDot % 10]))
                    }
                    let sortedBestCombineMove = twoStepEmptySearch(rootBoard, ways: combinedWays)
                    let maxCombinedScore = sortedBestCombineMove[0].1
                    var bestCombinedResults = [AIBoard]()
                    for r in sortedBestCombineMove{
                        print(r.1)
                        if r.1 == maxCombinedScore{
                            bestCombinedResults.append(r.0)
                        }else{
                            break
                        }
                    }
                    return Tool.randomElementFromArray(bestCombinedResults).originalMoves
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
            for lastMoveDot in lastMove{
                dots.insert(lastMoveDot[0] * 10 + lastMoveDot[1])
            }
        }
        var ways = Set<Set<Set<Int>>>()
        for dot in dots{
            ways = Tool.mergeSet(ways, smallset: startBoard.getAllWaysWithoutEmpty([dot/10,dot%10]))
        }
        for way in ways{
            let tempBoard = AIBoard(copy: startBoard)
            tempBoard.depth++
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
        return determineAction(startBoard).sort{$0.1 > $1.1}
    }
    
    func twoStepEmptySearch(startBoard: AIBoard, var ways: Set<Set<Set<Int>>>)->[(AIBoard, Int)]{
        
        aiBoardsProcessing = [AIBoard]()
        aiBoardsDone = [AIBoard]()
        startBoard.gameTree = [AIBoard]()

        if ways.count == 0{
            for lastMoveDot in rootBoard.playerLastMoves[rootBoard.otherPlayer()].last!{
                ways = Tool.mergeSet(ways, smallset: startBoard.getAllWaysWithoutEmpty(lastMoveDot))
            }
            for lastMoveDot in rootBoard.playerLastMoves[rootBoard.playerToGo].last!{
                ways = Tool.mergeSet(ways, smallset: startBoard.getAllWaysWithoutEmpty(lastMoveDot))
            }
        }
        
        for way in ways{
            let tempBoard = AIBoard(copy: startBoard)
            tempBoard.depth++
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
        return determineAction(startBoard).sort{$0.1 > $1.1}
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
                    ways = Tool.mergeSet(ways, smallset: lastBoard.getAllWaysWithoutEmpty(lastMoveDot))
                }
                for lastMoveDot in lastBoard.playerLastMoves[lastBoard.playerToGo].last!{
                    ways = Tool.mergeSet(ways, smallset: lastBoard.getAllWaysWithoutEmpty(lastMoveDot))
                }
                for w in ways{
                    let newBoard = AIBoard(copy: lastBoard)
                    newBoard.depth++
                    newBoard.playerMove(w)
                    lastBoard.gameTree.append(newBoard)
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
    }
    
    func getAllPossibleMove(){
        var total = 0
        for var x = 0; x < self.rootBoard.boardSize; x++ {
            for var y = 0; y < self.rootBoard.boardSize; y++ {
                total = total + self.rootBoard.getAllWaysWithoutEmpty([x,y]).count
            }
        }
//        print(total)
    }
    
    func determineAction(board: AIBoard)->[(AIBoard, Int)]{
        var possibilities = [(AIBoard, Int)]()
        
        func calculateScore(bd: AIBoard , previousVal: Int){
            for board in bd.gameTree{
                if board.gameTree.count == 0{
                    possibilities.append((board, board.playerGain[board.otherPlayer()].count + previousVal))
                }else{
                    var results = [(AIBoard, Int)]()
                    for child in board.gameTree{
                        results.append((child, child.playerGain[child.otherPlayer()].count))
                    }
                    let sortedResult =  results.sort {$0.1 < $1.1}
                    let total = previousVal + board.playerGain[board.otherPlayer()].count - sortedResult.last!.1
                    
                    if sortedResult.last!.0.gameTree.count > 0{
                        //more to explore
                        calculateScore(sortedResult.last!.0, previousVal: total)
                    }else{
                        possibilities.append((sortedResult.last!.0, total))
                    }
                }
            }
        }
        calculateScore(board, previousVal: 0)
        return possibilities
    }
}

