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
    let boardSize = 10

    var totalStep = 0
    
    var nodes = [[FenceNode]]()
    var fences = [Fence]()
    var lands = [[Land]]()
    
    var playerScore = [Int]()
    var playerFences = [Int]()

    func currentPlayer()->Int{
        return self.totalStep % self.playerNum
    }
    
    override init() {
        super.init()
        
        playerScore = [Int](count: playerNum, repeatedValue: 0)
        playerFences = [2, 3]
        
        //create nodes
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
                }
                if y < boardSize - 1{
                    let fence = Fence(player: -1)
                    fence.nodes.append(nodes[x][y])
                    fence.nodes.append(nodes[x][y+1])
                    
                    nodes[x][y].fences[nodes[x][y+1]] = fence
                    nodes[x][y+1].fences[nodes[x][y]] = fence
                    fences.append(fence)
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
    var view = UIView()

    init(x:Int, y:Int) {
        self.x = x
        self.y = y
    }
    
}

class Fence: NSObject {
    
    var player: Int
    var nodes = [FenceNode]()
    var view = UIView()

    init(player: Int) {
        self.player = player
    }
    
}

class Land: NSObject {
    
    var player: Int
    let x:Int
    let y:Int
    var view = UIView()
    
    init(player: Int, x:Int, y:Int) {
        self.x = x
        self.y = y
        self.player = player
    }
    
}
//    
//    nodes = [[Grid]]()
//    areas = [[Area]]()
//    totalStep = 0
//    tempPath = [Grid]()
//
//
//    unitWidth = self.frame.width / CGFloat(leng)
//    
//    //build all edges and area
//    for var x = 0; x < leng; x++ {
//    areas.append([Area]())
//    for var y = 0; y < leng; y++ {
//    if x < leng - 1{
//    let edge = Edge(frame: CGRect(x: nodes[x][y].center.x + edgeWidth/2, y: nodes[x][y].center.y - edgeWidth/2, width: unitWidth - edgeWidth, height: edgeWidth))
//    self.addSubview(edge)
//    nodes[x][y].edges[nodes[x+1][y]] = edge
//    nodes[x+1][y].edges[nodes[x][y]] = edge
//    
//    }
//    if y < leng - 1{
//    let edge = Edge(frame: CGRect(x: nodes[x][y].center.x - edgeWidth/2, y: nodes[x][y].center.y + edgeWidth/2, width: edgeWidth, height: unitWidth - edgeWidth))
//    self.addSubview(edge)
//    nodes[x][y].edges[nodes[x][y+1]] = edge
//    nodes[x][y+1].edges[nodes[x][y]] = edge
//    }
//    
//    if y < leng - 1 && x < leng - 1{
//    let area = Area(frame: CGRect(x: nodes[x][y].center.x + edgeWidth/2, y: nodes[x][y].center.y + edgeWidth/2, width: unitWidth - edgeWidth, height: unitWidth - edgeWidth))
//    areas[x].append(area)
//    self.addSubview(area)
//    }
//    }
//    }
