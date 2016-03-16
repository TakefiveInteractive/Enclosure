////
////  Gameboard2.swift
////  Enclosure
////
////  Created by Kedan Li on 2/20/16.
////  Copyright © 2016 TakeFive Interactive. All rights reserved.
////
//
import UIKit

class GameBoard2: GameBoard {
    override func buildGame(game: EnclosureGame) {
        super.buildGame(game)
        for v in areas
        {
            v.removeFromSuperview()
        }
        areas = [Area]()
        
        //build all area
        for arr in game.nodes{
            for node in arr{
                if node.y < game.boardSize - 1 && node.x < game.boardSize - 1{
                    print(game.lands[node.x][node.y].score)
                    let area = Area2(frame: CGRect(x: node.view.center.x + edgeWidth/2, y: node.view.center.y + edgeWidth/2, width: unitWidth - edgeWidth, height: unitWidth - edgeWidth), gameElement: game.lands[node.x][node.y], game: self)
                    game.lands[node.x][node.y].view = area
                    areas.append(area)
                    self.addSubview(area)
                }
            }
        }
        liftElements()
    }
}

class Area2: Area {
    var lab: UILabel!
    
    override init(frame: CGRect, gameElement: Land, game: GameBoard) {
        super.init(frame: frame, gameElement: gameElement, game: game)
        self.backgroundColor = UIColor.whiteColor()
        self.alpha = 0.8
        lab = UILabel(frame: self.bounds)
        lab.textColor = UIColor.grayColor()
        lab.alpha = 0.6
        lab.textAlignment = NSTextAlignment.Center
        lab.font = UIFont(name: "Avenir-Light", size: 15.0)
        if gameElement.score != 1{
            lab.text = "\(gameElement.score)"
            lab.alpha = 1
        }
        self.addSubview(lab)
        
    }
    
    override func update(){
        super.update()
        if self.gameElement.player != -1{
            self.lab.textColor = UIColor.whiteColor()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}