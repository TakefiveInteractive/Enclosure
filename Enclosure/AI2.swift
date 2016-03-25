//
//  AI2.swift
//  Enclosure
//
//  Created by Kedan Li on 3/7/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class AI2: AI {
    
    var scoreMap = [(Int, Int)]()
    
    let stepAdvantage = 1
    
    override init(game: EnclosureGame) {
        
        super.init(game: game)
        minToExplore = 4
        if rootBoard.neutralLand.count < (rootBoard.boardSize - 1) * (rootBoard.boardSize - 1) / 2{
            minToExplore = 3
        }
        if rootBoard.neutralLand.count < (rootBoard.boardSize - 1) * (rootBoard.boardSize - 1) / 4{
            minToExplore = 2
        }
        if rootBoard.neutralLand.count < (rootBoard.boardSize - 1) * (rootBoard.boardSize - 1) / 6{
            minToExplore = 1
        }
        for x in 0 ..< game.boardSize {
            for y in 0 ..< game.boardSize {
                if x < game.boardSize - 1 && y < game.boardSize - 1{
                    scoreMap.append((x * 10 + y, game.lands[x][y].score))
                }
            }
        }
        scoreMap = scoreMap.sort{$0.1 > $1.1}
    }
    
    override func calculateNextStep()->Set<Set<Int>>{
        getAllPossibleMove()
        
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
            if sortedBestSelfMove[0].1 >= sortedBestEnemyMove[0].1 - stepAdvantage{
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
    
    func findHighValueLand()->Set<Int>{
        var dots = Set<Int>()
        for land in scoreMap{
            if rootBoard.neutralLand.contains(land.0){
                //highest score land haven't been taken
                var fenceAvailable = 0
                if rootBoard.neutralFence.contains(Set([land.0,land.0+10])){
                    fenceAvailable += 1
                }
                if rootBoard.neutralFence.contains(Set([land.0,land.0+1])){
                    fenceAvailable += 1
                }
                if rootBoard.neutralFence.contains(Set([land.0+11,land.0+10])){
                    fenceAvailable += 1
                }
                if rootBoard.neutralFence.contains(Set([land.0+11,land.0+1])){
                    fenceAvailable += 1
                }
                if fenceAvailable > 2{
                    dots.insert(land.0)
                    dots.insert(land.0+1)
                    dots.insert(land.0+10)
                    dots.insert(land.0+11)
                }
            }
            if dots.count >= 8{
                break
            }
        }
        return dots
    }
    
    override func searchAllPossibleRoutes(startBoard: AIBoard)->[(AIBoard, Int)]{
        
        aiBoardsProcessing = [AIBoard]()
        aiBoardsDone = [AIBoard]()
        startBoard.gameTree = [AIBoard]()
        
        var dots = findHighValueLand()

        for lastMove in startBoard.playerLastMoves[startBoard.playerToGo]{
            dots = Tool.mergeSet(dots, smallset: lastMove)
        }
        var ways = Set<Set<Set<Int>>>()
        for dot in dots{
            ways = Tool.mergeSet(ways, smallset: startBoard.getAllWaysWithoutEmpty([dot/10,dot%10]))
        }
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
    
    override func calculateScore(bd: AIBoard , previousVal: Int, incremental: Bool){
        for board in bd.gameTree{
            if board.gameTree.count == 0{
                let total = getTotalScore(board.playerGain[board.otherPlayer()])
                possibilities.append((board, total + previousVal))
            }else{
                var results = [(AIBoard, Int)]()
                for child in board.gameTree{
                    let total = getTotalScore(child.playerGain[child.otherPlayer()])
                    results.append((child, total))
                }
                let sortedResult = results.sort {$0.1 < $1.1}
                var total = previousVal + getTotalScore(board.playerGain[board.otherPlayer()]) - sortedResult.last!.1
                if incremental{
                    total = previousVal + getTotalScore(board.playerGain[board.otherPlayer()]) + sortedResult.last!.1
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
    
    func getTotalScore(lands: Set<Int>)->Int{
        var total = 0
        for area in lands{
            total = total + (currentConfiguration as! EnclosureGame2).lands[area/10][area%10].score
        }
        return total
    }
}
