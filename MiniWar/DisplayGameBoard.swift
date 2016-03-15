//
//  DisplayGameBoard.swift
//  Enclosure
//
//  Created by Kedan Li on 3/14/16.\
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

//import UIKit
//
//
//  GameBoard.swift
//  MiniWar
//
//  Created by Kedan Li on 2/20/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class BoardText: UIButton {
    init(frame: CGRect, text: String) {
        super.init(frame: frame)
        self.setTitle(text, forState: UIControlState.Normal)
        self.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 25.0)
        self.titleLabel?.sizeToFit()
        self.setTitleColor(UIColor(hexString: "FBFBFC"), forState: UIControlState.Normal)
        self.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        self.alpha = 0.7
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BoardButton: UIButton {
    init(frame: CGRect, text: String) {
        super.init(frame: frame)
        self.setTitle(text, forState: UIControlState.Normal)
        self.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 25.0)
        self.titleLabel?.sizeToFit()
        self.setTitleColor(UIColor(hexString: "FBFBFC"), forState: UIControlState.Normal)
        self.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
        self.alpha = 0.7
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BoardBack: UIView {
    
    var board: DisplayGameBoard!
    var controller: MainViewController!
    
    func drawMenu1(){
        
        print(UIFont.familyNames())
        
        var x = board.game.nodes[4][2].fences[board.game.nodes[5][2]]!.view.frame.origin.x
        var y = board.game.nodes[4][2].fences[board.game.nodes[4][3]]!.view.frame.origin.y
        var width = board.game.nodes[7][2].fences[board.game.nodes[7][3]]!.view.frame.origin.x - x
        var height = board.game.nodes[4][3].fences[board.game.nodes[5][3]]!.view.frame.origin.y - y
        var classic = BoardButton(frame: CGRect(x: x, y: y, width: width, height: height), text: "Classic")

        classic.backgroundColor = controller.beta.textColor
        
        self.addSubview(classic)
        
        x = board.game.nodes[1][3].fences[board.game.nodes[2][3]]!.view.frame.origin.x
        y = board.game.nodes[1][3].fences[board.game.nodes[1][4]]!.view.frame.origin.y
        width = board.game.nodes[5][3].fences[board.game.nodes[5][4]]!.view.frame.origin.x - x
        height = board.game.nodes[4][4].fences[board.game.nodes[5][4]]!.view.frame.origin.y - y
        var mp = BoardButton(frame: CGRect(x: x, y: y, width: width, height: height), text: "Multi Player")
        mp.backgroundColor = controller.beta.textColor
        self.addSubview(mp)
        
        
        board.game.nodes[4][2].fences[board.game.nodes[4][3]]?.player = 0
        board.game.nodes[7][2].fences[board.game.nodes[7][3]]?.player = 0
        board.game.nodes[4][2].fences[board.game.nodes[5][2]]?.player = 0
        board.game.nodes[6][2].fences[board.game.nodes[5][2]]?.player = 0
        board.game.nodes[6][2].fences[board.game.nodes[7][2]]?.player = 0
        board.game.nodes[4][3].fences[board.game.nodes[5][3]]?.player = 0
        board.game.nodes[6][3].fences[board.game.nodes[5][3]]?.player = 0
        board.game.nodes[6][3].fences[board.game.nodes[7][3]]?.player = 0
        
        board.game.nodes[1][3].fences[board.game.nodes[2][3]]?.player = 0
        board.game.nodes[2][3].fences[board.game.nodes[3][3]]?.player = 0
        board.game.nodes[4][3].fences[board.game.nodes[3][3]]?.player = 0
        board.game.nodes[4][3].fences[board.game.nodes[5][3]]?.player = 0
        board.game.nodes[5][3].fences[board.game.nodes[5][4]]?.player = 0
        board.game.nodes[4][4].fences[board.game.nodes[5][4]]?.player = 0
        board.game.nodes[3][4].fences[board.game.nodes[4][4]]?.player = 0
        board.game.nodes[2][4].fences[board.game.nodes[3][4]]?.player = 0
        board.game.nodes[2][4].fences[board.game.nodes[1][4]]?.player = 0
        board.game.nodes[1][4].fences[board.game.nodes[1][3]]?.player = 0

//        board.drawBoard()
    }
    
}

class DisplayGameBoard: GameBoard {
    
//    let edgeWidth: CGFloat
//    
//    var game: EnclosureGame!
//    
//    let playerColors = [UIColor(red: 247.0/255.0, green: 149.0/255.0, blue: 157.0/255.0, alpha: 1), UIColor(red: 140.0/255.0, green: 196.0/255.0, blue: 299.0/255.0, alpha: 1)]
//    
//    let drawAnimationTime = 0.5
//    
//    var tempPath = [Grid]()
//    var lineLayer = CAShapeLayer()
//
//    var grids = [Grid]()
//    var areas = [Area]()
//    var edges = [Edge]()
//    
//    var unitWidth: CGFloat!
    
    override func buildGame(game: EnclosureGame){
        
        self.userInteractionEnabled = false
        
        self.game = game
        
        for v in self.subviews{
            v.removeFromSuperview()
        }
        
        grids = [Grid]()
        edges = [Edge]()
        areas = [Area]()
        tempPath = [Grid]()
        
        unitWidth = self.frame.width / CGFloat(game.boardSize)
        
        //build all nodes
        for arr in game.nodes{
            for node in arr{
                let grid = Grid(frame: CGRect(x: CGFloat(node.x) * unitWidth, y: CGFloat(node.y) * unitWidth, width: unitWidth, height: unitWidth), gameElement: node, game: self)
                grids.append(grid)
                node.view = grid
                grid.alpha = 0
                self.addSubview(grid)
                UIView.animateWithDuration(0.1, delay: 0.03 * Double(node.x + node.y), options: UIViewAnimationOptions.CurveEaseInOut, animations: { () -> Void in
                    grid.alpha = 1
                    }, completion: { (done) -> Void in
                        
                })
            }
        }
        
        //build all edges
        for fence in game.fences{
            if fence.nodes[0].x == fence.nodes[1].x{
                //vertical fence
                var upper: FenceNode!
                if fence.nodes[0].y < fence.nodes[1].y{
                    upper = fence.nodes[0]
                }else{
                    upper = fence.nodes[1]
                }
                let edge = Edge(frame: CGRect(x: upper.view.center.x - edgeWidth/2, y: upper.view.center.y + edgeWidth/2, width: edgeWidth, height: unitWidth - edgeWidth), gameElement: fence, game: self)
                self.addSubview(edge)
                fence.view = edge
                edges.append(edge)
            }else{
                //horizontal fence
                var lefter: FenceNode!
                if fence.nodes[0].x < fence.nodes[1].x{
                    lefter = fence.nodes[0]
                }else{
                    lefter = fence.nodes[1]
                }
                let edge = Edge(frame: CGRect(x: lefter.view.center.x + edgeWidth/2, y: lefter.view.center.y - edgeWidth/2, width: unitWidth - edgeWidth, height: edgeWidth), gameElement: fence, game: self)
                self.addSubview(edge)
                fence.view = edge
                edges.append(edge)
            }
        }
        
        //build all area
        for arr in game.nodes{
            for node in arr{
                if node.y < game.boardSize - 1 && node.x < game.boardSize - 1{
                    let area = Area(frame: CGRect(x: node.view.center.x + edgeWidth/2, y: node.view.center.y + edgeWidth/2, width: unitWidth - edgeWidth, height: unitWidth - edgeWidth), gameElement: game.lands[node.x][node.y], game: self)
                    game.lands[node.x][node.y].view = area
                    areas.append(area)
                    self.addSubview(area)
                }
            }
        }
        liftElements()
    }
    
    override func liftElements(){
        lineLayer.backgroundColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(lineLayer)
        
        //lift nodes up
        for node in grids{
            self.bringSubviewToFront(node)
        }
    }
    // redraw all the element on the board according to the game
    override func drawBoard(){
        for node in grids{
            node.toNormal()
        }
        for edge in edges{
            edge.update()
        }
        for area in areas{
            area.update()
        }
    }
    
    override func drawPath(){
        for elem in tempPath{
            elem.enlarge()
            if elem != tempPath.last{
                let index = tempPath.indexOf(elem)
                (elem.gameElement.fences[self.tempPath[index! + 1].gameElement]?.view as! Edge).backgroundColor = self.playerColors[self.game.currentPlayer()]
            }
        }
    }
    
    
    override func moveToNextStep(fences: [Fence], nodes:[FenceNode]){
        
        self.delegate?.showTotalRow(game.currentPlayer(), row: 0)
        
        // move to next step
        let areaChanged = game.updateMove(fences, nodes: nodes)
        drawBoard()
        self.delegate?.showTotalRow(game.currentPlayer(), row: game.playerFencesNum[game.currentPlayer()])
        
    }
    
//     func getCorrespondingGrid(p: CGPoint)->Grid{
//        var x = Int(p.x/unitWidth)
//        if x < 0{
//            x = 0
//        }else if x >= game.boardSize{
//            x = game.boardSize - 1
//        }
//        var y = Int(p.y/unitWidth)
//        if y < 0{
//            y = 0
//        }else if y >= game.boardSize{
//            y = game.boardSize - 1
//        }
//        return game.nodes[x][y].view as! Grid
//    }

    
}




