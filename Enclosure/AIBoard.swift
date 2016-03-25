//
//  AIBoard.swift
//  Enclosure
//
//  Created by Kedan Li on 2/28/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class AIBoard: NSObject {
    
    var gameTree = [AIBoard]()
    
    let playerNum: Int
    let boardSize: Int
    var originalMoves = Set<Set<Int>>()
    
    var concurrent = 0
    
    var depth: Int

    var playerToGo: Int
    
    var fences = [Set<Int>]() //[((Int,Int),(Int,Int))]()
    
    var playerFencesNum = [Int]()
    
    var neutralFence = Set<Set<Int>>()
    var playerFence = [Set<Set<Int>>]()

    var playerLastDot: Int = 0
    var playerLastMoves = [[Set<Int>]]()
    var canReachList = [Int:Set<Set<Set<Int>>>]()
    
    var neutralLand = [Int]()
    var playerLand = [[Int]]()
    
    var playerGain = [Set<Int>]()
    
    func otherPlayer()->Int{
        return (playerToGo+1)%2
    }
    
    func playerMove(move: Set<Set<Int>>){
        neutralFence = Tool.subtractSet(neutralFence, subset: move)
        playerFence[playerToGo] = Tool.mergeSet(playerFence[playerToGo], smallset: move)
        var dots = Set<Int>()
        for fence in move{
            dots = Tool.mergeSet(dots, smallset: fence)
        }
        playerLastMoves[playerToGo].append(dots)
        playerToGo = (playerToGo + 1)%2
    }
    
    func explorableEdgeFromPoint(searchPoint: Int)->Int{
        var total = 0
        if searchPoint / 10 - 1 >= 0{
            if neutralFence.contains(Set([searchPoint - 10, searchPoint])){
                total += 1
            }
        }
        if searchPoint / 10 + 1 < boardSize{
            if neutralFence.contains(Set([searchPoint + 10, searchPoint])){
                total += 1
            }
        }
        if searchPoint % 10 - 1 >= 0{
            if neutralFence.contains(Set([searchPoint - 1, searchPoint])){
                total += 1
            }
        }
        if searchPoint % 10 + 1 < boardSize{
            if neutralFence.contains(Set([searchPoint + 1, searchPoint])){
                total += 1
            }
        }
        return total
    }
    
    // search all the connectable trace from a node
    
    func getAllWaysWithoutEmpty(startPoint:[Int])->Set<Set<Set<Int>>>{
        
        var tempPath = Set<Set<Set<Int>>>()
        
        let transform = startPoint[0] * 10 + startPoint[1]
        if canReachList[transform] != nil {
            var toRemove = Set<Set<Set<Int>>>()
            for path in canReachList[transform]!{
                for step in path{
                    if playerFence[otherPlayer()].contains(step){
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
    

    
    func getPossibleFences(node: Int)->[Int]{
        let x = node / 10
        let y = node % 10
        var result = [Int]()
        if x > 0{
            result.append(node - 10)
        }
        if y > 0{
            result.append(node - 1)
        }
        if x < boardSize - 1{
            result.append(node + 10)
        }
        if y < boardSize - 1{
            result.append(node + 1)
        }
        return result
    }
    
    func containPolygon(polygon: [CGPoint], test: CGPoint) -> Bool {
        if polygon.count <= 1 {
            return false //or if first point = test -> return true
        }
        
        let p = UIBezierPath()
        let firstPoint = polygon[0] as CGPoint
        
        p.moveToPoint(firstPoint)
        
        for index in 1...polygon.count-1 {
            p.addLineToPoint(polygon[index] as CGPoint)
        }
        p.closePath()
        
        return p.containsPoint(test)
    }
    
    func updateArea(polygons: [[CGPoint]])->Set<Int>{
        var increaseList = [Int]()
        for land in neutralLand{
            for p in polygons{
                if containPolygon(p, test: CGPoint(x: Double(land / 10) + 0.5, y: Double(land % 10) + 0.5)){
                    increaseList.append(land)
                    break
                }
            }
        }
        let increasedSet = Set(increaseList)
        neutralLand = Array(Tool.subtractSet(Set(neutralLand), subset: increasedSet))
        playerLand[otherPlayer()] = Array(Tool.mergeSet(Set(playerLand[otherPlayer()]), smallset: increasedSet))
        playerGain[otherPlayer()] = Tool.mergeSet(playerGain[otherPlayer()], smallset: Set(increaseList))
        return Set(increaseList)
    }
    
    func identicalUpdate(otherBoard: AIBoard){
        self.neutralLand = otherBoard.neutralLand
        self.playerGain = otherBoard.playerGain
        self.playerLand = otherBoard.playerLand
    }
    
    func searchPolygon(fence: Set<Set<Int>>)->[[CGPoint]]{
        
        var unreachedFences = fence
        
        var tempPathes = [[Int]]()
        var polygons = [[Int]]()
        
        while unreachedFences.count > 0{
            
            while tempPathes.count > 0{
                for var path = tempPathes.count-1 ; path >= 0 ; path -= 1 {
                    let toExpand = tempPathes[path].last
                    
                    let f = getPossibleFences(toExpand!)
                    
                    for n in f{
                        if unreachedFences.contains(Set([toExpand!, n])){
                            unreachedFences.remove(Set([toExpand!, n]))
                            var mergePath:[Int]!
                            // check if meet with the head of another search path
                            for p in tempPathes{
                                if n == p.last && p.last != toExpand{
                                    mergePath = p
                                    break
                                }
                            }
                            
                            if mergePath != nil{
                                polygons.append(tempPathes[path] + mergePath.reverse())
                            }else{
                                var newP = tempPathes[path]
                                newP.append(n)
                                tempPathes.append(newP)
                            }
                            
                        }
                    }
                    tempPathes.removeAtIndex(path)
                }
            }
            if unreachedFences.count > 0{
                let newseed = unreachedFences.first!.first!
                tempPathes.append([newseed])
            }
        }
        
        var uiPolygon = [[CGPoint]]()
        for x in 0 ..< polygons.count {
            uiPolygon.append([CGPoint]())
            for y in 0 ..< polygons[x].count {
                uiPolygon[x].append(CGPoint(x: CGFloat(polygons[x][y] / 10), y: CGFloat(polygons[x][y] % 10)))
            }
        }
        return uiPolygon
    }
    
    init(copy: AIBoard) {
        self.playerNum = copy.playerNum
        self.boardSize = copy.boardSize
        self.playerToGo = copy.playerToGo
        self.depth = copy.depth
        super.init()
        
        self.fences = copy.fences
        
        self.playerFencesNum = copy.playerFencesNum
        
        self.neutralFence = copy.neutralFence
        self.playerFence = copy.playerFence
        
        self.playerLastMoves = copy.playerLastMoves
        self.canReachList = copy.canReachList
        
        self.originalMoves = copy.originalMoves
        
        self.neutralLand = copy.neutralLand
        self.playerLand = copy.playerLand
        
        self.playerGain = copy.playerGain
    }
    
    init(bigGame: EnclosureGame) {
        self.playerNum = bigGame.playerNum
        self.boardSize = bigGame.boardSize
        self.playerToGo = bigGame.currentPlayer()
        self.depth = 0
        super.init()
        
        playerGain = [Set<Int>](count: playerNum, repeatedValue: Set<Int>())
        
        playerLastMoves = [[Set<Int>]](count: bigGame.playerNum, repeatedValue:[Set<Int>]())
        for p in 0 ..< bigGame.playerNum {
            for m in bigGame.prevMovesByUser[p]{
                var move = Set<Int>()
                for n in m{
                    move.insert(n.x * 10 + n.y)
                }
                playerLastMoves[p].append(move)
            }
        }
        
        neutralFence = Set<Set<Int>>()
        playerFence = [Set<Set<Int>>](count: playerNum, repeatedValue: Set<Set<Int>>())
        playerFencesNum = bigGame.playerFencesNum
        
        playerLand = [[Int]](count: playerNum, repeatedValue: [Int]())
        neutralLand = [Int]()
        //create fences
        for var x = 0; x <  boardSize; x += 1 {
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
        for var x = 0; x <  boardSize - 1; x += 1 {
            for var y = 0; y < boardSize; y++ {
                if x < boardSize - 1 && y < boardSize - 1{
                    let land = x * 10 + y
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