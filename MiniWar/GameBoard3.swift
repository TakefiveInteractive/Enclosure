//
//  Gameboard2.swift
//  Enclosure
//
//  Created by Kedan Li on 2/20/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class GameBoard3: GameBoard2 {
    
    var areas3 = [[Area3]]()

    var playerMove = [3, 3]
    
    override func setup(){
        
        for v in self.subviews{
            v.removeFromSuperview()
        }
        
        playerscore = [Int]()
        nodes = [[Grid]]()
        areas3 = [[Area3]]()
        totalStep = 0
        tempPath = [Grid]()
        firstStep = true
        playerMove = [3, 3]
        
        self.delegate?.setTotalRow(0, row: 2)
        self.delegate?.setTotalRow(1, row: 3)
        self.delegate?.showTotalRow(1, row: 0)
        
        lineLayer.backgroundColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(lineLayer)
        
        for _ in players{
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
            areas3.append([Area3]())
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
                    let area = Area3(frame: CGRect(x: nodes[x][y].center.x + edgeWidth/2, y: nodes[x][y].center.y + edgeWidth/2, width: unitWidth - edgeWidth, height: unitWidth - edgeWidth))
                    areas3[x].append(area)
                    self.addSubview(area)
                }
            }
        }
    }

    override func dragged(sender: UIPanGestureRecognizer){
        let point = sender.locationInView(self)
        let grid = getCorrespondingGrid(point)
        if tempPath.count == 0{
            tempPath.append(grid)
        }else{
            if !tempPath.contains(grid) && grid.edges.keys.contains(tempPath.last!) && tempPath.count <= playerMove[totalStep % players.count] && (grid.edges[tempPath.last!]?.user == -1 || grid.edges[tempPath.last!]?.user == totalStep % players.count) && (!firstStep || tempPath.count <= pathNum - 1){
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
                self.delegate?.showTotalRow(totalStep % players.count, row: playerMove[totalStep % players.count] + 1 - tempPath.count)
            }
        }
        
        if sender.state == UIGestureRecognizerState.Cancelled || sender.state == UIGestureRecognizerState.Ended || sender.state == UIGestureRecognizerState.Failed {
            
            if firstStep && tempPath.count < 3{
                self.delegate?.showTotalRow(totalStep % players.count, row: 2)
            }else{
                if (firstStep && tempPath.count == 3) || tempPath.count == playerMove[totalStep % players.count] + 1{
                    self.delegate?.showTotalRow(totalStep % players.count, row: 0)
                    self.delegate?.showTotalRow((totalStep + 1) % players.count, row: playerMove[(totalStep + 1) % players.count])
                }else{
                    self.delegate?.showTotalRow(totalStep % players.count, row: playerMove[totalStep % players.count])
                    self.delegate?.showTotalRow((totalStep + 1) % players.count, row: 0)
                }
            }
            
            if (firstStep && tempPath.count == 3) || tempPath.count == playerMove[totalStep % players.count] + 1 {
                for var index = 0; index < self.tempPath.count - 1; index++ {
                    self.tempPath[index].edges[self.tempPath[index + 1]]!.backgroundColor = players[totalStep % players.count]
                    self.tempPath[index].edges[self.tempPath[index + 1]]!.user = totalStep % players.count
                }
                if firstStep {
                    firstStep = false
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
                    calculateScore(polygons)
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
            if !((firstStep && tempPath.count == 3) || tempPath.count == playerMove[totalStep % players.count] + 1) {
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

    
    override func calculateScore(polygons: [[CGPoint]]){
        for var x = 0; x < areas3.count; x++ {
            for var y = 0; y < areas3[x].count; y++ {
                for p in polygons{

                    if containPolygon(p, test: areas3[x][y].center) && areas3[x][y].user == -1{
                        areas3[x][y].user = totalStep % players.count
                        areas3[x][y].backgroundColor = players[totalStep % players.count]
                        areas3[x][y].lab.alpha = 1
                        areas3[x][y].lab.textColor = UIColor.whiteColor()
                        UIView.animateWithDuration(0.3, animations: { () -> Void in
                            self.areas3[x][y].alpha = 0.65
                        })
                        
                        if areas3[x][y].score == -1{
                            checkBomb(x, y: y)
                        }else if areas3[x][y].score == -2{
                            if playerMove[totalStep % players.count] < 5{
                                playerMove[totalStep % players.count]++
                                self.delegate?.setTotalRow(totalStep % players.count, row: playerMove[totalStep % players.count])
                                self.delegate?.showTotalRow(totalStep % players.count, row: 0)
                            }
                        }else{
                            playerscore[totalStep % players.count] = playerscore[totalStep % players.count] + areas3[x][y].score
                        }
                    }
                }
            }
        }
    }
    
    func checkBomb(x: Int, y: Int){
        var ars = [Area3]()
        if x-1 >= 0 {
            ars.append(areas3[x-1][y])
            if y-1 >= 0 {
                ars.append(areas3[x-1][y-1])
            }
            if y+1 < areas3.count{
                ars.append(areas3[x-1][y+1])
            }
        }
        if x+1 < areas3.count {
            ars.append(areas3[x+1][y])
            if y-1 >= 0 {
                ars.append(areas3[x+1][y-1])
            }
            if y+1 < areas3.count{
                ars.append(areas3[x+1][y+1])
            }
        }
        if y-1 >= 0 {
            ars.append(areas3[x][y-1])
        }
        if y+1 < areas3.count{
            ars.append(areas3[x][y+1])
        }
        
        for a in ars{
            if a.user == (totalStep + 1) % players.count{
                if a.score == -2{
                    if playerMove[totalStep % players.count] < 5{
                        playerMove[totalStep % players.count]++
                        self.delegate?.setTotalRow(totalStep % players.count, row: playerMove[totalStep % players.count])
                        self.delegate?.showTotalRow(totalStep % players.count, row: 0)
                    }
                    playerMove[(1 + totalStep) % players.count]--
                    self.delegate?.setTotalRow((1 + totalStep) % players.count, row: playerMove[(1 + totalStep) % players.count])
                }else if a.score > 0{
                    playerscore[totalStep % players.count] = playerscore[totalStep % players.count] + a.score
                    playerscore[(1 + totalStep) % players.count] = playerscore[(1 + totalStep) % players.count] - a.score

                }
            }else if a.user == -1{
                if a.score == -2{
                    if playerMove[totalStep % players.count] < 5{
                        playerMove[totalStep % players.count]++
                        self.delegate?.setTotalRow(totalStep % players.count, row: playerMove[totalStep % players.count])
                        self.delegate?.showTotalRow(totalStep % players.count, row: 0)
                    }
                }else if a.score > 0{
                    playerscore[totalStep % players.count] = playerscore[totalStep % players.count] + a.score
                }

            }
            a.backgroundColor = players[totalStep % players.count]
            a.user = totalStep % players.count
        }

    }
}

class Area3: Area {
    
    var lab: UILabel!
    let x = Int(arc4random_uniform(100))
    let y = Int(arc4random_uniform(100))
    var score = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        score = (x * y)/1000
        if score == 0{
            score = 1
        }
        if (x * y) > 7000{
            score = -1
        }
        if (x * y) > 8400{
            score = -2
        }
        lab = UILabel(frame: self.bounds)
        lab.textColor = UIColor.grayColor()
        lab.alpha = 0.6
        lab.textAlignment = NSTextAlignment.Center
        lab.font = UIFont(name: "Avenir-Light", size: 15.0)
        
        if score == -1{
            lab.text = "B"
        }else if score == -2{
            lab.text = "M+"
        }else if score != 1{
            lab.text = "\(score)"
        }
        self.addSubview(lab)
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}