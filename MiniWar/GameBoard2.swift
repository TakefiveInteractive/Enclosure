////
////  Gameboard2.swift
////  Enclosure
////
////  Created by Kedan Li on 2/20/16.
////  Copyright © 2016 TakeFive Interactive. All rights reserved.
////
//
//import UIKit
//
//class GameBoard2: GameBoard {
//    
//    var areas2 = [[Area2]]()
//
//    override func setup(){
//        
//        for v in self.subviews{
//            v.removeFromSuperview()
//        }
//        
//        playerscore = [Int]()
//        nodes = [[Grid]]()
//        areas2 = [[Area2]]()
//        totalStep = 0
//        tempPath = [Grid]()
//        firstStep = true
//        
//        self.delegate?.setTotalRow(0, row: 2)
//        self.delegate?.setTotalRow(1, row: 3)
//        self.delegate?.showTotalRow(1, row: 0)
//        
//        lineLayer.backgroundColor = UIColor.clearColor().CGColor
//        self.layer.addSublayer(lineLayer)
//        
//        for _ in players{
//            playerscore.append(0)
//        }
//        
//        unitWidth = self.frame.width / CGFloat(leng)
//        
//        //build all nodes
//        for var x = 0; x <  leng; x++ {
//            nodes.append([Grid]())
//            for var y = 0; y < leng; y++ {
//                nodes[x].append(Grid(frame: CGRect(x: CGFloat(x) * unitWidth, y: CGFloat(y) * unitWidth, width: unitWidth, height: unitWidth)))
//                nodes[x][y].alpha = 0
//                self.addSubview(nodes[x][y])
//                UIView.animateWithDuration(0.1, delay: 0.03 * Double(x + y), options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
//                    self.nodes[x][y].alpha = 1
//                    }, completion: { (done) -> Void in
//                        
//                })
//            }
//        }
//        
//        //build all edges and area
//        for var x = 0; x < leng; x++ {
//            areas2.append([Area2]())
//            for var y = 0; y < leng; y++ {
//                if x < leng - 1{
//                    let edge = Edge(frame: CGRect(x: nodes[x][y].center.x + edgeWidth/2, y: nodes[x][y].center.y - edgeWidth/2, width: unitWidth - edgeWidth, height: edgeWidth))
//                    self.addSubview(edge)
//                    nodes[x][y].edges[nodes[x+1][y]] = edge
//                    nodes[x+1][y].edges[nodes[x][y]] = edge
//                    
//                }
//                if y < leng - 1{
//                    let edge = Edge(frame: CGRect(x: nodes[x][y].center.x - edgeWidth/2, y: nodes[x][y].center.y + edgeWidth/2, width: edgeWidth, height: unitWidth - edgeWidth))
//                    self.addSubview(edge)
//                    nodes[x][y].edges[nodes[x][y+1]] = edge
//                    nodes[x][y+1].edges[nodes[x][y]] = edge
//                }
//                
//                if y < leng - 1 && x < leng - 1{
//                    let area = Area2(frame: CGRect(x: nodes[x][y].center.x + edgeWidth/2, y: nodes[x][y].center.y + edgeWidth/2, width: unitWidth - edgeWidth, height: unitWidth - edgeWidth))
//                    areas2[x].append(area)
//                    self.addSubview(area)
//                }
//            }
//        }
//    }
//
//    
//    override func calculateScore(polygons: [[CGPoint]]){
//        for x in areas2{
//            for y in x{
//                for p in polygons{
//                    if containPolygon(p, test: y.center) && y.user == -1{
//                        y.user = totalStep % players.count
//                        y.backgroundColor = players[totalStep % players.count]
//                        y.lab.alpha = 1
//                        y.lab.textColor = UIColor.whiteColor()
//                        UIView.animateWithDuration(0.3, animations: { () -> Void in
//                            y.alpha = 0.65
//                        })
//                        playerscore[totalStep % players.count] = playerscore[totalStep % players.count] + y.score
//                    }
//                }
//            }
//        }
//    }
//}
//
//class Area2: Area {
//    var lab: UILabel!
//    let x = Int(arc4random_uniform(100))
//    let y = Int(arc4random_uniform(100))
//    var score = 0
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        score = (x * y)/1500
//        if score == 0{
//            score = 1
//        }
//        lab = UILabel(frame: self.bounds)
//        lab.textColor = UIColor.grayColor()
//        lab.alpha = 0.6
//        lab.textAlignment = NSTextAlignment.Center
//        lab.font = UIFont(name: "Avenir-Light", size: 15.0)
//        
//        if score != 1{
//            lab.text = "\(score)"
//        }
//        self.addSubview(lab)
//        
//    }
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//}