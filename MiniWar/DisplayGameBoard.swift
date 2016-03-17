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

class BoardText: UILabel {
    init(frame: CGRect, text: String, color: UIColor, size: CGFloat) {
        super.init(frame: frame)
        self.text = text
        self.textAlignment = NSTextAlignment.Center
        self.font = UIFont(name: "Avenir-Heavy", size: 30.0 * size / 414.0)
        self.textColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class InputText: UITextField {
    init(frame: CGRect, text: String, color: UIColor, size: CGFloat) {
        super.init(frame: frame)
        self.text = text
        self.textAlignment = NSTextAlignment.Center
        self.font = UIFont(name: "Avenir-Heavy", size: 30.0 * size / 414.0)
        self.textColor = color
        self.backgroundColor = UIColor(hexString: "FBFBFC")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BoardButton: UIButton {
    init(frame: CGRect, text: String, color: UIColor, size: CGFloat) {
        super.init(frame: frame)
        self.setTitle(text, forState: UIControlState.Normal)
        self.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 25.0 * size / 414.0)
        self.titleLabel?.sizeToFit()
        self.backgroundColor = color
        self.setTitleColor(UIColor(hexString: "FBFBFC"), forState: UIControlState.Normal)
        self.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ChapterButton: UIButton {
    init(frame: CGRect, text: String, color: UIColor, size: CGFloat) {
        super.init(frame: frame)
        self.setTitle(text, forState: UIControlState.Normal)
        self.titleLabel?.font = UIFont(name: "Avenir-Medium", size: 50.0 * size / 414.0)
        self.titleLabel?.sizeToFit()
        self.backgroundColor = color
        self.setTitleColor(UIColor(hexString: "FBFBFC"), forState: UIControlState.Normal)
        self.setTitleColor(UIColor.grayColor(), forState: UIControlState.Highlighted)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class BoardBack: UIView , UITextFieldDelegate{
    
    var board: DisplayGameBoard!
    var controller: MainViewController!
    var input: InputText!
    var roomNum: BoardText!
    
    var firstSelection = 0
    
    var elements = [UIView]()
    
    func selectChap(but: UIButton){
        
        for fence in board.game.fences{
            fence.player = -1
        }
        
        board.drawBoard()
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            for element in self.elements{
                element.alpha = 0
            }
            }) { (finish) -> Void in
                for element in self.elements{
                    element.removeFromSuperview()
                }
                if but.tag == 0 && self.firstSelection == 0{
                    self.controller.performSegueWithIdentifier("playAI1", sender: self.controller)
                }else if but.tag == 1 && self.firstSelection == 0{
                    self.controller.performSegueWithIdentifier("playAI2", sender: self.controller)
                }else if but.tag == 0 && self.firstSelection == 1{
                    self.controller.performSegueWithIdentifier("play1", sender: self.controller)
                }else if but.tag == 1 && self.firstSelection == 1{
                    self.controller.performSegueWithIdentifier("play2", sender: self.controller)
                }else if but.tag == 0 && self.firstSelection == 2{
                    self.controller.createGameRoom("1")
                    self.waitRoom()
                }
        }
    }
    
    func submit(but: UIButton){
        Connection.setName((elements[0] as! UITextField).text!)
        cleanBoard(drawMenu1)
    }

    
    func play(but: UIButton){
        firstSelection = but.tag
        cleanBoard(drawTwoMode)
    }
    
    func back(but: UIButton){
       cleanBoard(drawMenu1)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func waitRoom(){
        var x = board.game.nodes[1][3].fences[board.game.nodes[2][3]]!.view.frame.origin.x
        var y = board.game.nodes[1][3].fences[board.game.nodes[1][4]]!.view.frame.origin.y
        var width = board.game.nodes[8][3].fences[board.game.nodes[8][4]]!.view.frame.origin.x - x
        var height = board.game.nodes[3][4].fences[board.game.nodes[4][4]]!.view.frame.origin.y - y
        let roomNumLab = BoardText(frame: CGRect(x: x, y: y, width: width, height: height), text: "Room Number:", color: controller.beta.textColor, size: controller.view.frame.width)
        roomNumLab.alpha = 0
        self.addSubview(roomNumLab)
        
        x = board.game.nodes[2][1].fences[board.game.nodes[3][1]]!.view.frame.origin.x
        y = board.game.nodes[2][1].fences[board.game.nodes[2][2]]!.view.frame.origin.y
        width = board.game.nodes[4][1].fences[board.game.nodes[4][2]]!.view.frame.origin.x - x
        height = board.game.nodes[4][2].fences[board.game.nodes[5][2]]!.view.frame.origin.y - y
        let back = BoardButton(frame: CGRect(x: x, y: y, width: width, height: height), text: "Back", color: controller.beta.textColor, size: controller.view.frame.width)
        back.alpha = 0
        back.addTarget(self, action: "back:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(back)
        
        
        x = board.game.nodes[1][1].fences[board.game.nodes[2][1]]!.view.frame.origin.x
        y = board.game.nodes[1][1].fences[board.game.nodes[1][2]]!.view.frame.origin.y
        width = board.game.nodes[2][1].fences[board.game.nodes[2][2]]!.view.frame.origin.x - x
        height = board.game.nodes[1][2].fences[board.game.nodes[2][2]]!.view.frame.origin.y - y
        let B = BoardText(frame: CGRect(x: x, y: y, width: width, height: height), text: "B", color: controller.beta.textColor, size: controller.view.frame.width)
        B.alpha = 0
        self.addSubview(B)
        
        x = board.game.nodes[3][5].fences[board.game.nodes[4][5]]!.view.frame.origin.x
        y = board.game.nodes[3][5].fences[board.game.nodes[3][6]]!.view.frame.origin.y
        width = board.game.nodes[8][5].fences[board.game.nodes[8][6]]!.view.frame.origin.x - x
        height = board.game.nodes[3][6].fences[board.game.nodes[4][6]]!.view.frame.origin.y - y
        roomNum = BoardText(frame: CGRect(x: x, y: y, width: width, height: height), text: "", color: controller.enclosure.textColor, size: controller.view.frame.width)
        roomNum.alpha = 0
        self.addSubview(roomNum)

        board.game.nodes[1][1].fences[board.game.nodes[1][2]]?.player = 0
        board.game.nodes[1][1].fences[board.game.nodes[2][1]]?.player = 0
        board.game.nodes[2][1].fences[board.game.nodes[2][2]]?.player = 0
        board.game.nodes[1][2].fences[board.game.nodes[2][2]]?.player = 0
        
        self.addSubview(B)

        elements.append(roomNum)
        elements.append(B)
        elements.append(back)
        elements.append(roomNumLab)
        
        showElements()

    }
    
    func inputNickName(){
        var x = board.game.nodes[1][1].fences[board.game.nodes[2][1]]!.view.frame.origin.x
        var y = board.game.nodes[1][1].fences[board.game.nodes[1][2]]!.view.frame.origin.y
        var width = board.game.nodes[7][1].fences[board.game.nodes[7][2]]!.view.frame.origin.x - x
        var height = board.game.nodes[3][2].fences[board.game.nodes[4][2]]!.view.frame.origin.y - y
        let nickname = BoardText(frame: CGRect(x: x, y: y, width: width, height: height), text: "Your Nickname:", color: controller.enclosure.textColor, size: controller.view.frame.width)
        nickname.alpha = 0
        self.addSubview(nickname)
        
        x = board.game.nodes[2][3].fences[board.game.nodes[3][3]]!.view.frame.origin.x
        y = board.game.nodes[2][3].fences[board.game.nodes[2][4]]!.view.frame.origin.y
        width = board.game.nodes[7][1].fences[board.game.nodes[7][2]]!.view.frame.origin.x - x
        height = board.game.nodes[4][4].fences[board.game.nodes[5][4]]!.view.frame.origin.y - y
        input = InputText(frame: CGRect(x: x, y: y, width: width, height: height), text: "", color: controller.enclosure.textColor, size: controller.view.frame.width)
        input.alpha = 0
        self.addSubview(input)
        
        x = board.game.nodes[4][5].fences[board.game.nodes[5][5]]!.view.frame.origin.x
        y = board.game.nodes[4][5].fences[board.game.nodes[4][6]]!.view.frame.origin.y
        width = board.game.nodes[7][3].fences[board.game.nodes[7][4]]!.view.frame.origin.x - x
        height = board.game.nodes[4][6].fences[board.game.nodes[5][6]]!.view.frame.origin.y - y
        let submit = BoardButton(frame: CGRect(x: x, y: y, width: width, height: height), text: "Submit", color: controller.beta.textColor, size: controller.view.frame.width)
        submit.alpha = 0
        submit.addTarget(self, action: "submit:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(submit)
        
        x = board.game.nodes[1][5].fences[board.game.nodes[2][5]]!.view.frame.origin.x
        y = board.game.nodes[1][5].fences[board.game.nodes[1][6]]!.view.frame.origin.y
        width = board.game.nodes[3][3].fences[board.game.nodes[3][4]]!.view.frame.origin.x - x
        height = board.game.nodes[4][6].fences[board.game.nodes[5][6]]!.view.frame.origin.y - y
        let back = BoardButton(frame: CGRect(x: x, y: y, width: width, height: height), text: "Back", color: controller.beta.textColor, size: controller.view.frame.width)
        back.addTarget(self, action: "back:", forControlEvents: UIControlEvents.TouchUpInside)
        back.alpha = 0
        self.addSubview(back)
        
        input.delegate = self
        elements.append(input)
        elements.append(nickname)
        elements.append(submit)
        elements.append(back)
        
        board.game.nodes[3][4].fences[board.game.nodes[2][4]]?.player = 1
        board.game.nodes[4][4].fences[board.game.nodes[3][4]]?.player = 1
        board.game.nodes[5][4].fences[board.game.nodes[4][4]]?.player = 1
        board.game.nodes[6][4].fences[board.game.nodes[5][4]]?.player = 1
        board.game.nodes[7][4].fences[board.game.nodes[6][4]]?.player = 1

        board.game.nodes[2][4].fences[board.game.nodes[2][3]]?.player = 1
        board.game.nodes[7][4].fences[board.game.nodes[7][3]]?.player = 1

        board.game.nodes[3][3].fences[board.game.nodes[2][3]]?.player = 1
        board.game.nodes[4][3].fences[board.game.nodes[3][3]]?.player = 1
        board.game.nodes[5][3].fences[board.game.nodes[4][3]]?.player = 1
        board.game.nodes[6][3].fences[board.game.nodes[5][3]]?.player = 1
        board.game.nodes[7][3].fences[board.game.nodes[6][3]]?.player = 1
        
        showElements()

        input.becomeFirstResponder()

    }
    
    func cleanBoard(action:()->()){
        
        for fence in board.game.fences{
            fence.player = -1
        }
        
        board.drawBoard()
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            for element in self.elements{
                element.alpha = 0
            }
            }) { (finish) -> Void in
                for element in self.elements{
                    element.removeFromSuperview()
                }
                self.elements = [UIView]()
                action()
        }
    }
    
    
    func drawTwoMode(){
        var x = board.game.nodes[5][3].fences[board.game.nodes[6][3]]!.view.frame.origin.x
        var y = board.game.nodes[5][3].fences[board.game.nodes[5][4]]!.view.frame.origin.y
        var width = board.game.nodes[7][3].fences[board.game.nodes[7][4]]!.view.frame.origin.x - x
        var height = board.game.nodes[4][5].fences[board.game.nodes[5][5]]!.view.frame.origin.y - y
        let chapter1 = ChapterButton(frame: CGRect(x: x, y: y, width: width, height: height), text: "1", color: controller.beta.textColor, size: controller.view.frame.width)
        chapter1.alpha = 0
        chapter1.tag = 0
        chapter1.addTarget(self, action: "selectChap:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(chapter1)
    
        x = board.game.nodes[2][5].fences[board.game.nodes[3][5]]!.view.frame.origin.x
        y = board.game.nodes[2][5].fences[board.game.nodes[2][6]]!.view.frame.origin.y
        width = board.game.nodes[4][4].fences[board.game.nodes[4][5]]!.view.frame.origin.x - x
        height = board.game.nodes[4][7].fences[board.game.nodes[5][7]]!.view.frame.origin.y - y
        let chapter2 = ChapterButton(frame: CGRect(x: x, y: y, width: width, height: height), text: "2", color: controller.enclosure.textColor, size: controller.view.frame.width)
        chapter2.tag = 1
        chapter2.alpha = 0
        chapter2.addTarget(self, action: "selectChap:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(chapter2)
        
        x = board.game.nodes[2][1].fences[board.game.nodes[3][1]]!.view.frame.origin.x
        y = board.game.nodes[2][1].fences[board.game.nodes[2][2]]!.view.frame.origin.y
        width = board.game.nodes[4][1].fences[board.game.nodes[4][2]]!.view.frame.origin.x - x
        height = board.game.nodes[4][2].fences[board.game.nodes[5][2]]!.view.frame.origin.y - y
        let back = BoardButton(frame: CGRect(x: x, y: y, width: width, height: height), text: "Back", color: controller.beta.textColor, size: controller.view.frame.width)
        back.alpha = 0
        back.addTarget(self, action: "back:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(back)
        
        x = board.game.nodes[1][1].fences[board.game.nodes[2][1]]!.view.frame.origin.x
        y = board.game.nodes[1][1].fences[board.game.nodes[1][2]]!.view.frame.origin.y
        width = board.game.nodes[2][1].fences[board.game.nodes[2][2]]!.view.frame.origin.x - x
        height = board.game.nodes[1][2].fences[board.game.nodes[2][2]]!.view.frame.origin.y - y
        let B = BoardText(frame: CGRect(x: x, y: y, width: width, height: height), text: "B", color: controller.beta.textColor, size: controller.view.frame.width)
        B.alpha = 0
        self.addSubview(B)
        
        board.game.nodes[1][1].fences[board.game.nodes[1][2]]?.player = 0
        board.game.nodes[1][1].fences[board.game.nodes[2][1]]?.player = 0
        board.game.nodes[2][1].fences[board.game.nodes[2][2]]?.player = 0
        board.game.nodes[1][2].fences[board.game.nodes[2][2]]?.player = 0
        
        elements.append(chapter2)
        elements.append(chapter1)
        elements.append(B)
        elements.append(back)
        
        showElements()
    }
    
    func mp(but:UIButton){
        cleanBoard(multiPlayerGame)
    }
    
    func createGame(but:UIButton){
        firstSelection = but.tag
        cleanBoard(drawTwoMode)
    }
    
    
    func joinGame(but:UIButton){
        if input.text != nil && input.text != "" {
            controller.searchGameRoom(input.text!)
        }
    }
    
    func multiPlayerGame(){
        var x = board.game.nodes[3][3].fences[board.game.nodes[4][3]]!.view.frame.origin.x
        var y = board.game.nodes[3][3].fences[board.game.nodes[3][4]]!.view.frame.origin.y
        var width = board.game.nodes[7][3].fences[board.game.nodes[7][4]]!.view.frame.origin.x - x
        var height = board.game.nodes[3][4].fences[board.game.nodes[4][4]]!.view.frame.origin.y - y
        let createRoom = BoardButton(frame: CGRect(x: x, y: y, width: width, height: height), text: "Create Room", color: controller.beta.textColor, size: controller.view.frame.width)
        createRoom.tag = 2
        createRoom.alpha = 0
        createRoom.addTarget(self, action: "createGame:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(createRoom)
        
        x = board.game.nodes[2][5].fences[board.game.nodes[3][5]]!.view.frame.origin.x
        y = board.game.nodes[2][5].fences[board.game.nodes[2][6]]!.view.frame.origin.y
        width = board.game.nodes[6][5].fences[board.game.nodes[6][6]]!.view.frame.origin.x - x
        height = board.game.nodes[4][6].fences[board.game.nodes[5][6]]!.view.frame.origin.y - y
        let joinGame = BoardButton(frame: CGRect(x: x, y: y, width: width, height: height), text: "Join Room", color: controller.beta.textColor, size: controller.view.frame.width)
        joinGame.tag = 1
        joinGame.addTarget(self, action: "joinGame:", forControlEvents: UIControlEvents.TouchUpInside)
        joinGame.alpha = 0
        self.addSubview(joinGame)
        
        x = board.game.nodes[1][7].fences[board.game.nodes[2][7]]!.view.frame.origin.x
        y = board.game.nodes[1][7].fences[board.game.nodes[1][8]]!.view.frame.origin.y
        width = board.game.nodes[4][7].fences[board.game.nodes[4][8]]!.view.frame.origin.x - x
        height = board.game.nodes[4][8].fences[board.game.nodes[5][8]]!.view.frame.origin.y - y
        let room = BoardText(frame: CGRect(x: x, y: y, width: width, height: height), text: "Room:", color: controller.beta.textColor, size: controller.view.frame.width)
        room.alpha = 0
        self.addSubview(room)
        
        x = board.game.nodes[2][1].fences[board.game.nodes[3][1]]!.view.frame.origin.x
        y = board.game.nodes[2][1].fences[board.game.nodes[2][2]]!.view.frame.origin.y
        width = board.game.nodes[4][1].fences[board.game.nodes[4][2]]!.view.frame.origin.x - x
        height = board.game.nodes[4][2].fences[board.game.nodes[5][2]]!.view.frame.origin.y - y
        let back = BoardButton(frame: CGRect(x: x, y: y, width: width, height: height), text: "Back", color: controller.enclosure.textColor, size: controller.view.frame.width)
        back.alpha = 0
        back.addTarget(self, action: "back:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(back)
        
        x = board.game.nodes[4][7].fences[board.game.nodes[5][7]]!.view.frame.origin.x
        y = board.game.nodes[4][7].fences[board.game.nodes[4][8]]!.view.frame.origin.y
        width = board.game.nodes[7][1].fences[board.game.nodes[7][2]]!.view.frame.origin.x - x
        height = board.game.nodes[4][8].fences[board.game.nodes[5][8]]!.view.frame.origin.y - y
        input = InputText(frame: CGRect(x: x, y: y, width: width, height: height), text: "", color: controller.beta.textColor, size: controller.view.frame.width)
        input.keyboardType = UIKeyboardType.NumberPad
        input.alpha = 0
        self.addSubview(input)
        
        x = board.game.nodes[2][3].fences[board.game.nodes[3][3]]!.view.frame.origin.x
        y = board.game.nodes[2][3].fences[board.game.nodes[2][4]]!.view.frame.origin.y
        width = board.game.nodes[3][2].fences[board.game.nodes[3][3]]!.view.frame.origin.x - x
        height = board.game.nodes[3][4].fences[board.game.nodes[4][4]]!.view.frame.origin.y - y
        let I = BoardText(frame: CGRect(x: x, y: y, width: width, height: height), text: "1", color: controller.beta.textColor, size: controller.view.frame.width)
        I.alpha = 0
        self.addSubview(I)
        
        x = board.game.nodes[1][5].fences[board.game.nodes[2][5]]!.view.frame.origin.x
        y = board.game.nodes[1][5].fences[board.game.nodes[1][6]]!.view.frame.origin.y
        width = board.game.nodes[2][3].fences[board.game.nodes[2][4]]!.view.frame.origin.x - x
        height = board.game.nodes[1][6].fences[board.game.nodes[2][6]]!.view.frame.origin.y - y
        let II = BoardText(frame: CGRect(x: x, y: y, width: width, height: height), text: "2", color: controller.beta.textColor, size: controller.view.frame.width)
        II.alpha = 0
        self.addSubview(II)
        
        x = board.game.nodes[1][1].fences[board.game.nodes[2][1]]!.view.frame.origin.x
        y = board.game.nodes[1][1].fences[board.game.nodes[1][2]]!.view.frame.origin.y
        width = board.game.nodes[2][1].fences[board.game.nodes[2][2]]!.view.frame.origin.x - x
        height = board.game.nodes[1][2].fences[board.game.nodes[2][2]]!.view.frame.origin.y - y
        let B = BoardText(frame: CGRect(x: x, y: y, width: width, height: height), text: "B", color: controller.enclosure.textColor, size: controller.view.frame.width)
        B.alpha = 0
        self.addSubview(B)
        
        input.delegate = self
        elements.append(joinGame)
        elements.append(createRoom)
        elements.append(back)
        elements.append(input)
        elements.append(room)
        elements.append(I)
        elements.append(B)
        elements.append(II)
        
        board.game.nodes[2][3].fences[board.game.nodes[2][4]]?.player = 0
        board.game.nodes[2][4].fences[board.game.nodes[3][4]]?.player = 0
        board.game.nodes[3][3].fences[board.game.nodes[2][3]]?.player = 0
        board.game.nodes[3][3].fences[board.game.nodes[3][4]]?.player = 0
        
        board.game.nodes[1][5].fences[board.game.nodes[1][6]]?.player = 0
        board.game.nodes[1][5].fences[board.game.nodes[2][5]]?.player = 0
        board.game.nodes[2][6].fences[board.game.nodes[2][5]]?.player = 0
        board.game.nodes[2][6].fences[board.game.nodes[1][6]]?.player = 0
        
        board.game.nodes[1][1].fences[board.game.nodes[1][2]]?.player = 1
        board.game.nodes[1][1].fences[board.game.nodes[2][1]]?.player = 1
        board.game.nodes[2][1].fences[board.game.nodes[2][2]]?.player = 1
        board.game.nodes[1][2].fences[board.game.nodes[2][2]]?.player = 1
        
        board.game.nodes[4][7].fences[board.game.nodes[5][7]]?.player = 0
        board.game.nodes[4][7].fences[board.game.nodes[4][8]]?.player = 0
        board.game.nodes[5][8].fences[board.game.nodes[4][8]]?.player = 0
        board.game.nodes[5][8].fences[board.game.nodes[6][8]]?.player = 0
        board.game.nodes[6][8].fences[board.game.nodes[7][8]]?.player = 0
        board.game.nodes[7][7].fences[board.game.nodes[7][8]]?.player = 0
        board.game.nodes[6][7].fences[board.game.nodes[7][7]]?.player = 0
        board.game.nodes[6][7].fences[board.game.nodes[5][7]]?.player = 0
        
        showElements()
    }
    
    func showElements(){
        board.drawBoard()
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            for elem in self.elements{
                elem.alpha = 1
            }
            }) { (finish) -> Void in
                
        }
    }
    
    func drawMenu1(){
        
        var x = board.game.nodes[3][1].fences[board.game.nodes[4][1]]!.view.frame.origin.x
        var y = board.game.nodes[3][1].fences[board.game.nodes[3][2]]!.view.frame.origin.y
        var width = board.game.nodes[7][1].fences[board.game.nodes[7][2]]!.view.frame.origin.x - x
        var height = board.game.nodes[3][2].fences[board.game.nodes[4][2]]!.view.frame.origin.y - y
        let classic = BoardButton(frame: CGRect(x: x, y: y, width: width, height: height), text: "Single Player", color: controller.beta.textColor, size: controller.view.frame.width)
        classic.tag = 0
        classic.alpha = 0
        classic.addTarget(self, action: "play:", forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(classic)
        
        x = board.game.nodes[2][3].fences[board.game.nodes[3][3]]!.view.frame.origin.x
        y = board.game.nodes[2][3].fences[board.game.nodes[2][4]]!.view.frame.origin.y
        width = board.game.nodes[6][3].fences[board.game.nodes[6][4]]!.view.frame.origin.x - x
        height = board.game.nodes[4][4].fences[board.game.nodes[5][4]]!.view.frame.origin.y - y
        let multiplayer = BoardButton(frame: CGRect(x: x, y: y, width: width, height: height), text: "Multi Player", color: controller.beta.textColor, size: controller.view.frame.width)
        multiplayer.tag = 1
        multiplayer.addTarget(self, action: "play:", forControlEvents: UIControlEvents.TouchUpInside)
        multiplayer.alpha = 0
        self.addSubview(multiplayer)
        
        x = board.game.nodes[3][5].fences[board.game.nodes[4][5]]!.view.frame.origin.x
        y = board.game.nodes[3][5].fences[board.game.nodes[3][6]]!.view.frame.origin.y
        width = board.game.nodes[8][5].fences[board.game.nodes[8][6]]!.view.frame.origin.x - x
        height = board.game.nodes[3][6].fences[board.game.nodes[4][6]]!.view.frame.origin.y - y
        let ranking = BoardButton(frame: CGRect(x: x, y: y, width: width, height: height), text: "Ranking Match", color: controller.enclosure.textColor, size: controller.view.frame.width)
        ranking.alpha = 0
        self.addSubview(ranking)
        
        x = board.game.nodes[2][7].fences[board.game.nodes[3][7]]!.view.frame.origin.x
        y = board.game.nodes[2][7].fences[board.game.nodes[2][8]]!.view.frame.origin.y
        width = board.game.nodes[7][7].fences[board.game.nodes[7][8]]!.view.frame.origin.x - x
        height = board.game.nodes[4][8].fences[board.game.nodes[5][8]]!.view.frame.origin.y - y
        let friend = BoardButton(frame: CGRect(x: x, y: y, width: width, height: height), text: "Play w/ Friends", color: controller.enclosure.textColor, size: controller.view.frame.width)
        friend.addTarget(self, action: "mp:", forControlEvents: UIControlEvents.TouchUpInside)
        friend.tag = 2
        friend.alpha = 0
        self.addSubview(friend)
        
        x = board.game.nodes[2][1].fences[board.game.nodes[3][1]]!.view.frame.origin.x
        y = board.game.nodes[2][1].fences[board.game.nodes[2][2]]!.view.frame.origin.y
        width = board.game.nodes[3][1].fences[board.game.nodes[3][2]]!.view.frame.origin.x - x
        height = board.game.nodes[2][2].fences[board.game.nodes[3][2]]!.view.frame.origin.y - y
        let I = BoardText(frame: CGRect(x: x, y: y, width: width, height: height), text: "1", color: controller.beta.textColor, size: controller.view.frame.width)
        I.alpha = 0
        self.addSubview(I)

        x = board.game.nodes[1][3].fences[board.game.nodes[2][3]]!.view.frame.origin.x
        y = board.game.nodes[1][3].fences[board.game.nodes[1][4]]!.view.frame.origin.y
        width = board.game.nodes[2][3].fences[board.game.nodes[2][4]]!.view.frame.origin.x - x
        height = board.game.nodes[1][4].fences[board.game.nodes[2][4]]!.view.frame.origin.y - y
        let II = BoardText(frame: CGRect(x: x, y: y, width: width, height: height), text: "2", color: controller.beta.textColor, size: controller.view.frame.width)
        II.alpha = 0
        self.addSubview(II)
        
        x = board.game.nodes[2][5].fences[board.game.nodes[3][5]]!.view.frame.origin.x
        y = board.game.nodes[2][5].fences[board.game.nodes[2][6]]!.view.frame.origin.y
        width = board.game.nodes[3][5].fences[board.game.nodes[3][6]]!.view.frame.origin.x - x
        height = board.game.nodes[2][6].fences[board.game.nodes[3][6]]!.view.frame.origin.y - y
        let III = BoardText(frame: CGRect(x: x, y: y, width: width, height: height), text: "3", color: controller.enclosure.textColor, size: controller.view.frame.width)
        III.alpha = 0
        self.addSubview(III)
        
        x = board.game.nodes[1][7].fences[board.game.nodes[2][7]]!.view.frame.origin.x
        y = board.game.nodes[1][7].fences[board.game.nodes[1][8]]!.view.frame.origin.y
        width = board.game.nodes[2][7].fences[board.game.nodes[2][8]]!.view.frame.origin.x - x
        height = board.game.nodes[1][8].fences[board.game.nodes[2][8]]!.view.frame.origin.y - y
        let IV = BoardText(frame: CGRect(x: x, y: y, width: width, height: height), text: "4", color: controller.enclosure.textColor,size: controller.view.frame.width)
        IV.alpha = 0
        self.addSubview(IV)
        
        elements.append(I)
        elements.append(II)
        elements.append(IV)
        elements.append(III)
        elements.append(friend)
        elements.append(ranking)
        elements.append(classic)
        elements.append(multiplayer)
        
        board.game.nodes[2][1].fences[board.game.nodes[2][2]]?.player = 0
        board.game.nodes[2][2].fences[board.game.nodes[3][2]]?.player = 0
        board.game.nodes[3][1].fences[board.game.nodes[2][1]]?.player = 0
        board.game.nodes[3][1].fences[board.game.nodes[3][2]]?.player = 0
        
        board.game.nodes[1][3].fences[board.game.nodes[1][4]]?.player = 0
        board.game.nodes[1][3].fences[board.game.nodes[2][3]]?.player = 0
        board.game.nodes[2][4].fences[board.game.nodes[2][3]]?.player = 0
        board.game.nodes[2][4].fences[board.game.nodes[1][4]]?.player = 0
        
        board.game.nodes[2][5].fences[board.game.nodes[2][6]]?.player = 1
        board.game.nodes[2][6].fences[board.game.nodes[3][6]]?.player = 1
        board.game.nodes[3][5].fences[board.game.nodes[2][5]]?.player = 1
        board.game.nodes[3][5].fences[board.game.nodes[3][6]]?.player = 1
        
        board.game.nodes[1][7].fences[board.game.nodes[1][8]]?.player = 1
        board.game.nodes[1][7].fences[board.game.nodes[2][7]]?.player = 1
        board.game.nodes[2][8].fences[board.game.nodes[2][7]]?.player = 1
        board.game.nodes[2][8].fences[board.game.nodes[1][8]]?.player = 1
        
        showElements()

    }    
    
}

class DisplayGameBoard: GameBoard {
    
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
                edge.alpha = 1
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
                edge.alpha = 1
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




