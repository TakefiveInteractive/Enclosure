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
                let sortedResults = twoStepEmptySearch(self.rootBoard)
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

                let sortedBestMove = searchAllPossibleRoutes(rootBoard)
                let maxScore = sortedBestMove[0].1
                var bestResults = [AIBoard]()
                for r in sortedBestMove{
                    print(r.1)
                    if r.1 == maxScore{
                        bestResults.append(r.0)
                    }else{
                        break
                    }
                }
                return Tool.randomElementFromArray(bestResults).originalMoves
            }
        }
    }
    
    func searchAllPossibleRoutes(startBoard: AIBoard)->[(AIBoard, Int)]{
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
            tempBoard.playerMove(way)
            tempBoard.originalMoves = way
            rootBoard.gameTree.append(tempBoard)
            aiBoardsDone.append(tempBoard)
        }
        toDepth(1)
        for b in self.aiBoardsDone{
            let polygons = b.searchPolygon(b.playerFence[b.otherPlayer()])
            b.updateArea(polygons)
        }
        return determineAction().sort{$0.1 > $1.1}

    }
    
    func twoStepEmptySearch(startBoard: AIBoard)->[(AIBoard, Int)]{
        
        var ways = Set<Set<Set<Int>>>()
        for lastMoveDot in rootBoard.playerLastMoves[rootBoard.otherPlayer()].last!{
            ways = Tool.mergeSet(ways, smallset: self.rootBoard.getAllWaysWithoutEmpty(lastMoveDot))
        }
        for lastMoveDot in rootBoard.playerLastMoves[rootBoard.playerToGo].last!{
            ways = Tool.mergeSet(ways, smallset: self.rootBoard.getAllWaysWithoutEmpty(lastMoveDot))
        }
        
        for way in ways{
            let tempBoard = AIBoard(copy: startBoard)
            tempBoard.playerMove(way)
            tempBoard.originalMoves = way
            rootBoard.gameTree.append(tempBoard)
            aiBoardsDone.append(tempBoard)
        }
        
        toDepth(1)
        
        for b in self.aiBoardsDone{
            let polygons = b.searchPolygon(b.playerFence[b.otherPlayer()])
            b.updateArea(polygons)
        }
        
        toDepth(2)
        
        var playerDistinct = [(Set<Set<Int>>):AIBoard]()
        for b in self.aiBoardsDone{
            let pFence = b.playerFence[b.otherPlayer()]
            if let val = playerDistinct[pFence]{
                b.identicalUpdate(val)
            }else{
                let polygons = b.searchPolygon(b.playerFence[b.otherPlayer()])
                b.updateArea(polygons)
                playerDistinct[pFence] = b
            }
        }
        return determineAction().sort{$0.1 > $1.1}

    }
    
    var aiBoardsProcessing = [AIBoard]()
    var aiBoardsDone = [AIBoard]()
    
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
    
    func determineAction()->[(AIBoard, Int)]{
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
        calculateScore(rootBoard, previousVal: 0)
        return possibilities
    }
}

