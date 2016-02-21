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

protocol GameBoardDelegate{
    func updateScore(playerscore:[Int])
    func setTotalRow(player:Int, row: Int)
    func showTotalRow(player:Int, row: Int)
}

class GameBoard: UIView {
    
    let players = [UIColor.redColor(), UIColor.blueColor()]
    var delegate: GameBoardDelegate?
    
    var totalStep = 0
    
    var gesture: UIPanGestureRecognizer!
    var playerscore = [Int]()
    
    var nodes = [[Grid]]()
    var areas = [[Area]]()
    
    var unitWidth: CGFloat!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        gesture = UIPanGestureRecognizer(target: self, action: "dragged:")
        self.addGestureRecognizer(gesture)
    }
    
    func setup(){
        
        self.delegate?.setTotalRow(0, row: 2)
        self.delegate?.setTotalRow(1, row: 3)

        lineLayer.backgroundColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(lineLayer)
        
        for p in players{
            playerscore.append(0)
        }
        
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
    var firstStep = true
    func dragged(sender: UIPanGestureRecognizer){
        let point = sender.locationInView(self)
        let grid = getCorrespondingGrid(point)
        if tempPath.count == 0{
            tempPath.append(grid)
        }else{
            if !tempPath.contains(grid) && grid.edges.keys.contains(tempPath.last!) && tempPath.count <= pathNum && (grid.edges[tempPath.last!]?.user == -1 || grid.edges[tempPath.last!]?.user == totalStep % players.count) && (!firstStep || tempPath.count <= pathNum - 1){
                tempPath.append(grid)

            }
            if tempPath.count > 1 && grid == tempPath[tempPath.count - 2]{
                if self.tempPath.last?.edges[tempPath[tempPath.count - 2]]?.user == -1 {
                    tempPath.last?.edges[tempPath[tempPath.count - 2]]?.backgroundColor = UIColor.clearColor()
                }else{
                    tempPath.last?.edges[tempPath[tempPath.count - 2]]?.backgroundColor = players[totalStep % players.count]
                }
                tempPath.removeLast()
            }
        }
        if self.tempPath.count > 1{
            for var index = 0; index < self.tempPath.count - 1; index++ {
                self.tempPath[index].edges[self.tempPath[index + 1]]!.backgroundColor = self.players[self.totalStep % 2]
            }
        }
        
        if tempPath.count > 0 {
            if firstStep{
                self.delegate?.showTotalRow(totalStep % players.count, row: 3 - tempPath.count)
            }else{
                self.delegate?.showTotalRow(totalStep % players.count, row: 4 - tempPath.count)
            }
        }
        
        if sender.state == UIGestureRecognizerState.Cancelled || sender.state == UIGestureRecognizerState.Ended || sender.state == UIGestureRecognizerState.Failed {
            
            if firstStep{
                self.delegate?.showTotalRow(totalStep % players.count, row: 2)
            }else{
                self.delegate?.showTotalRow(totalStep % players.count, row: 3)
            }
            
            if (firstStep && tempPath.count == 3) || tempPath.count == 4 {
                for var index = 0; index < self.tempPath.count - 1; index++ {
                    self.tempPath[index].edges[self.tempPath[index + 1]]!.backgroundColor = players[totalStep % players.count]
                    self.tempPath[index].edges[self.tempPath[index + 1]]!.user = totalStep % players.count
                }
                if firstStep {
                    firstStep = false
                    self.delegate?.setTotalRow(0, row: 3)
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
                                if containPolygon(p, test: y.center) && y.user == -1{
                                    y.user = totalStep % players.count
                                    y.backgroundColor = players[totalStep % players.count]
                                    UIView.animateWithDuration(0.3, animations: { () -> Void in
                                        y.alpha = 0.65
                                    })
                                    playerscore[totalStep % players.count]++
                                }
                            }
                        }
                    }
                    self.delegate?.updateScore(playerscore)
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
            lineLayer.lineWidth = 0

        }else{
            if !((firstStep && tempPath.count == 3) || tempPath.count == 4) {
                let drawingLine = UIBezierPath()
                drawingLine.moveToPoint((tempPath.last?.center)!)
                drawingLine.addLineToPoint(point)
                drawingLine.closePath()
                lineLayer.path = drawingLine.CGPath
                lineLayer.strokeColor = players[totalStep%players.count].CGColor
                lineLayer.lineWidth = edgeWidth
            }else{
                lineLayer.lineWidth = 0
            }
        }
        
    }
    var lineLayer = CAShapeLayer()

    
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
    var lab:UILabel!
    var user = -1
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.whiteColor()
        self.alpha = 0.8
        
        lab = UILabel(frame: frame)
        lab.textColor = UIColor.grayColor()
        lab.alpha = 0.6
        
        
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Rows: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    let length:CGFloat = 60
    var color: UIColor!
    var views = [UIView]()
    
    func changeBarNum(num : Int){
        
        for v in views{
            v.removeFromSuperview()
        }
        views = [UIView]()
        let startIndex: CGFloat = (self.frame.width - (length * CGFloat(num) + 10 * CGFloat(num - 1))) / 2
        for var index = 0; index < num; index++ {
            let v = UIView(frame: CGRect(x: startIndex + (10.0 + length) * CGFloat(index), y: 0, width: length, height: 6))
            v.backgroundColor = color
            views.append(v)
            self.addSubview(v)
        }
    }
    
    func displayNum(num : Int){
        for var index = 0; index < views.count; index++ {
            if index < num{
                views[index].alpha = 1
            }else{
                views[index].alpha = 0
            }
        }
    }
    
}

