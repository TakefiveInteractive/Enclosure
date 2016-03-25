//
//  MainViewController.swift
//  Enclosure
//
//  Created by Kedan Li on 3/12/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit
import MessageUI
import ChameleonFramework

let redOnBoard = UIColor(hexString: "F7959D")
let blueOnBoard = UIColor(hexString: "78B4FF")
let tableViewBackground = UIColor(hexString: "E6E6EE")

var mpSocket: Socket!

class MainViewController: UIViewController, UserDataDelegate, MFMailComposeViewControllerDelegate, SocketSuccessDelegate{
    
    @IBOutlet weak var titleWidth: NSLayoutConstraint!
    @IBOutlet var back: DisplayGameBoard!
    @IBOutlet var board: BoardBack!
    @IBOutlet var beta: UILabel!
    @IBOutlet var enclosure: UILabel!
    @IBOutlet var rank: UIButton!
    @IBOutlet var nickname: UIButton!
    @IBOutlet var feedback: UIButton!
    @IBOutlet var aboutus: UIButton!

    var sudoGame = EnclosureGame()
    var onlinePlayer = 0
    var opponentName = ""
    var opponentId = ""
    override func viewDidLoad() {
        nickname.addTarget(self, action: #selector(MainViewController.changeNickName(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        feedback.addTarget(self, action: #selector(MainViewController.feedback(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        aboutus.addTarget(self, action: #selector(MainViewController.aboutus(_:)), forControlEvents: UIControlEvents.TouchUpInside)

        Connection.delegate = self
        Connection.getInfo()
        self.rankUpdate(Connection.getUserRank())
        self.nicknameUpdate(Connection.getUserNickName())

    }
   
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if board.input != nil{
            board.input.resignFirstResponder()
        }
    }
    
    func feedback(but: UIButton){
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func aboutus(but: UIButton){
        UIApplication.sharedApplication().openURL(NSURL(string: "http://takefiveinteractive.com")!)
    }
    
    func changeNickName(but: UIButton){
        board.cleanBoard(board.inputNickName)
    }
    
    func rankUpdate(rank: String){
        self.rank.setTitle("World Rank: \(rank)", forState: UIControlState.Normal)
    }
    
    func nicknameUpdate(name: String){
        nickname.setTitle(name, forState: UIControlState.Normal)
    }
    
    override func viewDidAppear(animated: Bool) {
        
        Connection.getInfo()
        mpSocket = nil

        if view.frame.width < 350{
            enclosure.font = UIFont(name: "AvenirNext-Regular", size: 55.0)
            titleWidth.constant = 250
        }
        
        sudoGame.boardSize = 10
        sudoGame.buildGame()
        back.buildGame(sudoGame)
        board.board = back
        board.controller = self
        
        if let register = NSUserDefaults.standardUserDefaults().objectForKey("register"){
            board.drawMenu1()

        }else{
            board.inputNickName()
            Connection.register()
            NSUserDefaults.standardUserDefaults().setObject(true, forKey: "register")
        }
        
    }
    
    
    func createGameRoom(level: String){
        mpSocket = Socket(roomNumber: "", level: level)
        mpSocket.startDelegate = self
    }
    
    func searchGameRoom(room: String){
        if room != "" {
            mpSocket = Socket(roomNumber: room, level: "")
            mpSocket.startDelegate = self
        }
    }
    
    func gotRoomNumber(number: String) {
        
        board.roomNum.text = number
        
    }
        
    func playerSequence(player: Int, names: [String], ids: [String], level: String){

        self.onlinePlayer = player
        if names[0] == Connection.getUserNickName(){
            opponentName = names[1]
        }else{
            opponentName = names[0]
        }
        
        if ids[0] == Connection.getUserId(){
            opponentId = ids[1]
        }else{
            opponentId = ids[0]
        }
        
    }
    
    func joinSuccess(success: Bool) {
        if success{
            self.performSegueWithIdentifier("startMPGame", sender: self)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
            // Create a new variable to store the instance of PlayerTableViewController
        board.cleanBoard(board.drawMenu1)
        if segue.identifier == "startMPGame"{
            let destinationVC = segue.destinationViewController as! MPGame1ViewController
            destinationVC.currentPlayer = self.onlinePlayer
            destinationVC.opponentName = self.opponentName
            destinationVC.opponentId = self.opponentId
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["likedan5@icloud.com"])
        mailComposerVC.setSubject("Feedback for Enclosure")
        mailComposerVC.setMessageBody("Tell us your thoughts about the game! Enclosure is still in developement and your feedback is valuable for us.", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        board.cleanBoard(board.drawMenu1)
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
        board.cleanBoard(board.drawMenu1)
    }
    
    @IBAction func backToMain(segue:UIStoryboardSegue) {
        board.cleanBoard(board.drawMenu1)
        Connection.getInfo()
    }
    
}
