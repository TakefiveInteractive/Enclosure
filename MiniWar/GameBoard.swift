//
//  GameBoard.swift
//  MiniWar
//
//  Created by Kedan Li on 2/20/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit


let edgeWidth: CGFloat = 4
let leng = 10
let pathNum = 3

class GameBoard: UIView {
    
    let players = [UIColor.redColor(), UIColor.blueColor()]
    
    var currentplayer = 0
    
    var gesture: UIPanGestureRecognizer!
    
    var nodes = [[Grid]]()
    
    var unitWidth: CGFloat!
    
    override init(frame: CGRect) {

        super.init(frame: frame)
        gesture = UIPanGestureRecognizer(target: self, action: "dragged:")
        self.addGestureRecognizer(gesture)
    }
    
    func setup(){
        unitWidth = self.frame.width / CGFloat(leng)
        
        //build all nodes
        for var x = 0; x <  leng; x++ {
            nodes.append([Grid]())
            for var y = 0; y < leng; y++ {
                nodes[x].append(Grid(frame: CGRect(x: CGFloat(x) * unitWidth, y: CGFloat(y) * unitWidth, width: unitWidth, height: unitWidth)))
                nodes[x][y].alpha = 0
                self.addSubview(nodes[x][y])
                UIView.animateWithDuration(0.1, delay: 0.03 * Double(x + y), options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    self.nodes[x][y].alpha = 1
                    }, completion: { (done) -> Void in
                    
                })
            }
        }
        
        //build all edges
        for var x = 0; x < leng; x++ {
            for var y = 0; y < leng; y++ {
                if x < leng - 1{
                    let edge = Edge(frame: CGRect(x: nodes[x][y].center.x + edgeWidth/2, y: nodes[x][y].center.y - edgeWidth/2, width: unitWidth - edgeWidth, height: edgeWidth))
                    self.addSubview(edge)
                    nodes[x][y].edges[nodes[x+1][y]] = edge
                    nodes[x+1][y].edges[nodes[x][y]] = edge
                }
                if y < leng - 1{
                    let edge = Edge(frame: CGRect(x: nodes[x][y].center.x - edgeWidth/2, y: nodes[x][y].center.y + edgeWidth/2, width: edgeWidth, height: unitWidth - edgeWidth))
                    self.addSubview(edge)
                    nodes[x][y].edges[nodes[x][y+1]] = edge
                    nodes[x][y+1].edges[nodes[x][y]] = edge
                }
            }
        }
    }
    
    var path = [Grid]()
    
    func dragged(sender: UIPanGestureRecognizer){
        let point = sender.locationInView(self)
        print(point)
        let grid = getCorrespondingGrid(point)
        if path.count == 0{
            path.append(grid)
        }else{
            if !path.contains(grid) && grid.edges.keys.contains(path.last!) && path.count <= pathNum {
                path.append(grid)
            }
        }
        dispatch_async(dispatch_get_main_queue()) {
            if self.path.count > 1{
                for var index = 0; index < self.path.count - 1; index++ {
                    self.path[index].edges[self.path[index + 1]]!.backgroundColor = self.players[self.currentplayer % 2]
                }
            }
        }
        
        if sender.state == UIGestureRecognizerState.Cancelled || sender.state == UIGestureRecognizerState.Ended || sender.state == UIGestureRecognizerState.Failed {
            currentplayer++
        }
    }

    func getCorrespondingGrid(p: CGPoint)->Grid{
        return nodes[Int(p.x/unitWidth)][Int(p.y/unitWidth)]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        gesture = UIPanGestureRecognizer(target: self, action: "dragged:")
        self.addGestureRecognizer(gesture)
    }
    
}

class Grid: UIView {
    
    var edges = [Grid: Edge]()
    
    var reach = [Grid: Bool]()
    
    var centerGrid: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        centerGrid = UIView(frame: CGRect(x: 0, y: 0, width: edgeWidth, height: edgeWidth))
        centerGrid.backgroundColor = UIColor.blackColor()
        self.addSubview(centerGrid)
        centerGrid.center = CGPoint(x: self.bounds.width / 2, y: self.bounds.width / 2)
        self.userInteractionEnabled = false
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Edge: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

