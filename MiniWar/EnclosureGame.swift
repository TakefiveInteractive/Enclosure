//
//  EnclosureGame.swift
//  Enclosure
//
//  Created by Kedan Li on 2/25/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

// The GAME LOGIC

class EnclosureGame: NSObject {

    let playerNum = 2
    let boardSize = 9
    var firstMove = false
    
    var totalStep = 0
    
    
    var nodes = [[FenceNode]]()
    var fences = [Fence]()
    var lands = [[Land]]()
    
    var prevMovesByUser = [[[FenceNode]]]()
    var userLastEdges = [[[Fence]]]()
    
    
    var playerScore = [Int]()
    var playerFencesNum = [Int]()

    var neutralLand = [Land]()
    var playerLand = [[Land]]()

    var neutralFence = [Fence]()
    var playerFence = [[Fence]]()
    
    func currentPlayer()->Int{
        return self.totalStep % self.playerNum
    }
    
    func updateMove(fs:[Fence], nodes:[FenceNode])->[Land]{
        for f in fs{
            f.player = currentPlayer()
            playerFence[currentPlayer()].append(f)
        }
        let set1 = Set(neutralFence)
        let set2 = Set(fs)
        neutralFence = Array(Tool.subtractSet(set1, subset: set2))
        
        if !firstMove {
            firstMove = true
            playerFencesNum[currentPlayer()]++
        }
        
        let polygons = searchPolygon(nodes[0], good: [currentPlayer()])
        let updatedAreas = updateArea(polygons)
        recalculateScore()
        
        userLastEdges[currentPlayer()].append(fs)
        prevMovesByUser[currentPlayer()].append(nodes)
        totalStep++
//        let c = playerFence[1].count + playerFence[0].count + neutralFence.count
//        print(c)
        return updatedAreas
    }
    
    func recalculateScore(){
        playerScore = [Int](count: playerNum, repeatedValue: 0)
        for var player = 0; player < playerNum; player++ {
            for land in playerLand[player]{
                playerScore[player] += land.score
            }
        }
    }
    
    func searchPolygon(seed: FenceNode, good: [Int])->[[CGPoint]]{
        
        for fence in fences{
            fence.exploreFlag = false
        }
        var tempPathes = [[FenceNode]]()
        var polygons = [[FenceNode]]()
        tempPathes.append([seed])
        
        while tempPathes.count > 0{
            for var path = tempPathes.count-1 ; path >= 0 ; path-- {
                let toExpand = tempPathes[path].last
                for n in (toExpand?.fences.keys)!{
                    if good.contains(toExpand!.fences[n]!.player) && !toExpand!.fences[n]!.exploreFlag{
                        toExpand!.fences[n]!.exploreFlag = true
                        
                        var mergePath:[FenceNode]!
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
        
        var uiPolygon = [[CGPoint]]()
        for var x = 0; x < polygons.count; x++ {
            uiPolygon.append([CGPoint]())
            for var y = 0; y < polygons[x].count; y++ {
                uiPolygon[x].append(polygons[x][y].view.center)
            }
        }

        return uiPolygon
    }
    
    func updateArea(polygons: [[CGPoint]])->[Land]{
        var updatedList = [Land]()
        for land in neutralLand{
            for p in polygons{
                if containPolygon(p, test: land.view.center){
                    land.player = currentPlayer()
                    playerLand[currentPlayer()].append(land)
                    updatedList.append(land)
                    break
                }
            }
        }
        

        let set1 = Set(neutralLand)
        let set2 = Set(updatedList)
        neutralLand = Array(Tool.subtractSet(set1, subset: set2))
        return updatedList
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
    
    func checkEnd()->Bool{
        
        var end = true
        
        var polygon = searchPolygon(neutralFence[0].nodes[1], good: [-1, currentPlayer()])
        for neutral in neutralLand{
            for p in polygon{
                if containPolygon(p, test: neutral.view.center){
                    end = false
                    break
                }
            }
            if !end{
                break
            }
        }
        
        polygon = searchPolygon(neutralFence[0].nodes[1], good: [-1, (currentPlayer()+1)%2])
        for neutral in neutralLand{
            for p in polygon{
                if containPolygon(p, test: neutral.view.center){
                    end = false
                    break
                }
            }
            if !end{
                break
            }
        }
        
        return end
    }
    
    override init() {
        super.init()
        
        prevMovesByUser = [[[FenceNode]]](count: playerNum, repeatedValue: [[FenceNode]]())
        userLastEdges = [[[Fence]]](count: playerNum, repeatedValue: [[Fence]]())
        neutralLand = [Land]()
        playerLand = [[Land]](count: playerNum, repeatedValue: [Land]())
        playerScore = [Int](count: playerNum, repeatedValue: 0)
        playerFencesNum = [2, 3]
        neutralFence = [Fence]()
        playerFence = [[Fence]](count: playerNum, repeatedValue: [Fence]())
        
        //create nodees
        for var x = 0; x <  boardSize; x++ {
            nodes.append([FenceNode]())
            for var y = 0; y < boardSize; y++ {
                nodes[x].append(FenceNode(x: x, y: y))
            }
        }
        
        //create fences
        for var x = 0; x <  boardSize; x++ {
            for var y = 0; y < boardSize; y++ {
                if x < boardSize - 1{
                    let fence = Fence(player: -1)
                    fence.nodes.append(nodes[x][y])
                    fence.nodes.append(nodes[x+1][y])
                    
                    nodes[x][y].fences[nodes[x+1][y]] = fence
                    nodes[x+1][y].fences[nodes[x][y]] = fence
                    fences.append(fence)
                    neutralFence.append(fence)
                }
                if y < boardSize - 1{
                    let fence = Fence(player: -1)
                    fence.nodes.append(nodes[x][y])
                    fence.nodes.append(nodes[x][y+1])
                    
                    nodes[x][y].fences[nodes[x][y+1]] = fence
                    nodes[x][y+1].fences[nodes[x][y]] = fence
                    fences.append(fence)
                    neutralFence.append(fence)
                }
            }
        }
        //create lands
        for var x = 0; x <  boardSize; x++ {
            if x < boardSize - 1{
                lands.append([Land]())
                for var y = 0; y < boardSize; y++ {
                    if x < boardSize - 1 && y < boardSize - 1{
                        let land = Land(player: -1, x: x, y: y)
                        lands[x].append(land)
                        neutralLand.append(land)
                    }
                }
            }
        }
    }
    
}

class FenceNode: NSObject {
    
    var fences = [FenceNode: Fence]()
    let x:Int
    let y:Int
    var view:UIView!

    init(x:Int, y:Int) {
        self.x = x
        self.y = y
    }
    
}

class Fence: NSObject {
    
    var player: Int
    var nodes = [FenceNode]()
    var view:UIView!
    var exploreFlag = false

    init(player: Int) {
        self.player = player
    }
    
}

class Land: NSObject {
    
    let score = 1
    var player: Int
    let x:Int
    let y:Int
    var view:UIView!
    
    init(player: Int, x:Int, y:Int) {
        self.x = x
        self.y = y
        self.player = player
    }
    
    func changeOwner(){
        
    }
    
}
