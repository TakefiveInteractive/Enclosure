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
    
    var totalStep = 0
    
    var gesture: UIPanGestureRecognizer!
    
    var nodes = [[Grid]]()
    var areas = [[Area]]()
    
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
        
        //build all edges and area
        for var x = 0; x < leng; x++ {
            areas.append([Area]())
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
                
                if y < leng - 1 && x < leng - 1{
                    let area = Area(frame: CGRect(x: nodes[x][y].center.x + edgeWidth/2, y: nodes[x][y].center.y + edgeWidth/2, width: unitWidth - edgeWidth, height: unitWidth - edgeWidth))
                    areas[x].append(area)
                    self.addSubview(area)
                }
            }
        }
    }
    
    var tempPath = [Grid]()
    var fistStep = true
    func dragged(sender: UIPanGestureRecognizer){
        let point = sender.locationInView(self)
        let grid = getCorrespondingGrid(point)
        if tempPath.count == 0{
            tempPath.append(grid)
        }else{
            if !tempPath.contains(grid) && grid.edges.keys.contains(tempPath.last!) && tempPath.count <= pathNum && (grid.edges[tempPath.last!]?.user == -1 || grid.edges[tempPath.last!]?.user == totalStep % players.count) && (!fistStep || tempPath.count <= pathNum - 1){
                tempPath.append(grid)
            }
            if tempPath.count > 1 && grid == tempPath[tempPath.count - 2]{
                tempPath.last?.edges[tempPath[tempPath.count - 2]]?.backgroundColor = UIColor.clearColor()
                self.tempPath.last?.edges[tempPath[tempPath.count - 2]]?.user = -1
                tempPath.removeLast()
            }
        }
        if self.tempPath.count > 1{
            for var index = 0; index < self.tempPath.count - 1; index++ {
                self.tempPath[index].edges[self.tempPath[index + 1]]!.backgroundColor = self.players[self.totalStep % 2]
                self.tempPath[index].edges[self.tempPath[index + 1]]!.user = self.totalStep % 2
            }
        }
        
        if sender.state == UIGestureRecognizerState.Cancelled || sender.state == UIGestureRecognizerState.Ended || sender.state == UIGestureRecognizerState.Failed {
            
            if (fistStep && tempPath.count == 3) || tempPath.count == 4 {
                if fistStep {
                    fistStep = false
                }
                tempPathes = [[Grid]]()
                for g in tempPath{
                    checkArea(g, current: g, path: [Grid]())
                }
                
                if tempPathes.count > 0{
                    var polygons = [[CGPoint]]()
                    for p in tempPathes{
                        var polygon = [CGPoint]()
                        for grid in p{
                            polygon.append(grid.center)
                        }
                        polygons.append(polygon)
                    }
                    for x in areas{
                        for y in x{
                            for p in polygons{
                                print(containPolygon(p, test: y.center))
                                if containPolygon(p, test: y.center) && y.user == -1{
                                    y.user = totalStep % players.count
                                    y.backgroundColor = players[totalStep % players.count]
                                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                                        y.alpha = 0.7
                                    })
                                }
                            }
                        }
                    }
                    print(polygons)
                }
                totalStep++
            }else{
                if self.tempPath.count > 1{
                    for var index = 0; index < self.tempPath.count - 1; index++ {
                        self.tempPath[index].edges[self.tempPath[index + 1]]!.backgroundColor = UIColor.clearColor()
                        self.tempPath[index].edges[self.tempPath[index + 1]]!.user = -1
                    }
                }
            }
            tempPath = [Grid]()
        }
    }
    
    var tempPathes = [[Grid]]()
    func checkArea(start:Grid, current: Grid, var path: [Grid]){
        if current == start && path.count >= 3{
            path.append(current)
            tempPathes.append(path)
        }else{
            path.append(current)
            for key in (current.edges.keys){
                if (path.count == 1 || !path.contains(key) && key != start || key == start && path.count > 2) && current.edges[key]?.user == totalStep % players.count{
                    checkArea(start, current: key, path: path)
                }
            }
        }

    }

    func getCorrespondingGrid(p: CGPoint)->Grid{
        var x = Int(p.x/unitWidth)
        if x < 0{
            x = 0
        }else if x >= leng{
            x = leng - 1
        }
        var y = Int(p.y/unitWidth)
        if y < 0{
            y = 0
        }else if y >= leng{
            y = leng - 1
        }
        return nodes[x][y]
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        gesture = UIPanGestureRecognizer(target: self, action: "dragged:")
        self.addGestureRecognizer(gesture)
    }
    
    func containPolygon(polygon: [CGPoint], test: CGPoint) -> Bool {
        if polygon.count <= 1 {
            return false //or if first point = test -> return true
        }
        
        var p = UIBezierPath()
        let firstPoint = polygon[0] as CGPoint
        
        p.moveToPoint(firstPoint)
        
        for index in 1...polygon.count-1 {
            p.addLineToPoint(polygon[index] as CGPoint)
        }
        
        p.closePath()
        
        return p.containsPoint(test)
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
    var user = -1
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Area: UIView {
    var user = -1
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        self.alpha = 0.3
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}