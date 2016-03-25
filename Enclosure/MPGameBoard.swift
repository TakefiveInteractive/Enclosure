//
//  GameBoard.swift
//  MiniWar
//
//  Created by Kedan Li on 2/20/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class MPGameBoard: GameBoard, SocketGameDelegate{
    
    var onlineCurrentPlayer: Int = 0
    var parent: MPGame1ViewController!
    override func afterPlayerMove(){
        super.afterPlayerMove()
        var fencess = game.userLastEdges[onlineCurrentPlayer].last!
        var sendData = ""
        if fencess.count == 3 {
            sendData = "\(onlineCurrentPlayer):\(fencess[0].nodes[0].x),\(fencess[0].nodes[0].y)$\(fencess[0].nodes[1].x),\(fencess[0].nodes[1].y)|\(fencess[1].nodes[0].x),\(fencess[1].nodes[0].y)$\(fencess[1].nodes[1].x),\(fencess[1].nodes[1].y)|\(fencess[2].nodes[0].x),\(fencess[2].nodes[0].y)$\(fencess[2].nodes[1].x),\(fencess[2].nodes[1].y)"
        }else if fencess.count == 2 {
            sendData = "\(onlineCurrentPlayer):\(fencess[0].nodes[0].x),\(fencess[0].nodes[0].y)$\(fencess[0].nodes[1].x),\(fencess[0].nodes[1].y)|\(fencess[1].nodes[0].x),\(fencess[1].nodes[0].y)$\(fencess[1].nodes[1].x),\(fencess[1].nodes[1].y)"
        }
        print(sendData)
        mpSocket.playerMove(sendData)
        changeBoardAvailabiliity()
    }
    
    func playerDisconnect(){
        parent.waiting.setTitle("opponent disconnected", forState: UIControlState.Normal)
    }
    
    func gotMove(move: String) {
        let splitData = move.componentsSeparatedByString(":")
        print(splitData)
        
        if Int(splitData[0]) == game.currentPlayer(){
            let fs = splitData[1].componentsSeparatedByString("|")
            var fences = [Fence]()
            var setofNodes = Set<FenceNode>()
            for fence in Array(fs){
                let twoNode = fence.componentsSeparatedByString("$")
                let node1 = self.game.nodes[Int(twoNode[0].componentsSeparatedByString(",")[0])!][Int(twoNode[0].componentsSeparatedByString(",")[1])!]
                let node2 = self.game.nodes[Int(twoNode[1].componentsSeparatedByString(",")[0])!][Int(twoNode[1].componentsSeparatedByString(",")[1])!]
                setofNodes.insert(node1)
                setofNodes.insert(node2)
                fences.append(node1.fences[node2]!)
            }
            self.moveToNextStep(fences, nodes: Array(setofNodes))
        }
        changeBoardAvailabiliity()
    }
    
    func restartGame(player: Int) {
        parent.actualReplay()
    }
    
    func requestRestart(){
        parent.requestedRestart()
    }
    
    func changeBoardAvailabiliity(){
        if game.currentPlayer() != onlineCurrentPlayer{
            self.userInteractionEnabled = false
            self.alpha = 0.65
            parent.waiting.alpha = 1
            
        }else{
            self.userInteractionEnabled = true
            self.alpha = 1
            parent.waiting.alpha = 0
        }
    }

    func buildGame(game: EnclosureGame, player: Int, parent: MPGame1ViewController) {
        mpSocket.gameDelegate = self
        super.buildGame(game)
        self.parent = parent
        onlineCurrentPlayer = player
        changeBoardAvailabiliity()
    }
}
