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
    
    var depth: Int

    var playerToGo: Int
    
    var fences = [Set<Int>]() //[((Int,Int),(Int,Int))]()
    
    var playerFencesNum = [Int]()
    
    var neutralFence = Set<Set<Int>>()
    var playerFence = [Set<Set<Int>>]()
    
    var playerLastMoves = [[[[Int]]]]()
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
    
//    func getAllWaysWithoutEmpty(startPoint:[Int])->Set<Set<Set<Int>>>{
//        
//        var tempPath = Set<Set<Set<Int>>>()
//        
//        let transform = startPoint[0] * 10 + startPoint[1]
//        if canReachList[transform] != nil {
//            var toRemove = Set<Set<Set<Int>>>()
//            for path in canReachList[transform]!{
//                for step in path{
//                    if !neutralFence.contains(step){
//                        toRemove.insert(path)
//                        break
//                    }
//                }
//            }
//            canReachList[transform] = Tool.subtractSet(canReachList[transform]!, subset: toRemove)
//            return canReachList[transform]!
//        }else{
//            
//            func getAllWaysBranch(head:[Int], path: Set<Set<Int>>){
//                let raw = head[0] * 10 + head[1]
//                if path.count < playerFencesNum[playerToGo]{
//                    if head[0] - 1 >= 0{
//                        var tp = path
//                        if !tp.contains(Set([raw,raw - 10])) && neutralFence.contains(Set([raw,raw - 10])){
//                            tp.insert(Set([raw,raw - 10]))
//                            getAllWaysBranch([head[0] - 1, head[1]], path: tp)
//                        }
//                    }
//                    if head[0] + 1 < boardSize{
//                        var tp = path
//                        if !tp.contains(Set([raw,raw + 10])) && neutralFence.contains(Set([raw,raw + 10])){
//                            tp.insert(Set([raw,raw + 10]))
//                            getAllWaysBranch([head[0] + 1, head[1]], path: tp)
//                        }
//                    }
//                    if head[1] - 1 >= 0{
//                        var tp = path
//                        if !tp.contains(Set([raw, raw - 1])) && neutralFence.contains(Set([raw, raw - 1])){
//                            tp.insert(Set([raw,raw - 1]))
//                            getAllWaysBranch([head[0], head[1] - 1], path: tp)
//                        }
//                    }
//                    if head[1] + 1 < boardSize{
//                        var tp = path
//                        if !tp.contains(Set([raw, raw + 1])) && neutralFence.contains(Set([raw, raw + 1])){
//                            tp.insert(Set([raw,raw + 1]))
//                            getAllWaysBranch([head[0], head[1] + 1], path: tp)
//                        }
//                    }
//                }else{
//                    tempPath.insert(path)
//                }
//            }
//            getAllWaysBranch(startPoint, path: Set<Set<Int>>())
//        }
//        canReachList[transform] = tempPath
//        return tempPath
//        
//    }
    
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
        let set1 = Set(neutralLand)
        let set2 = Set(increaseList)
        neutralLand = Array(Tool.subtractSet(set1, subset: set2))
        playerLand[otherPlayer()] = Array(Tool.mergeSet(set1, smallset: set2))
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
                for var path = tempPathes.count-1 ; path >= 0 ; path-- {
                    let toExpand = tempPathes[path].last
                    
                    let f = getPossibleFences(toExpand!)
                    
                    for n in f{
                        if fence.contains(Set([toExpand!, n])) && unreachedFences.contains(Set([toExpand!, n])){
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
        for var x = 0; x < polygons.count; x++ {
            uiPolygon.append([CGPoint]())
            for var y = 0; y < polygons[x].count; y++ {
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
        
        neutralFence = Set<Set<Int>>()
        playerFence = [Set<Set<Int>>](count: playerNum, repeatedValue: Set<Set<Int>>())
        playerFencesNum = bigGame.playerFencesNum
        
        playerLand = [[Int]](count: playerNum, repeatedValue: [Int]())
        neutralLand = [Int]()
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
        for var x = 0; x <  boardSize - 1; x++ {
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