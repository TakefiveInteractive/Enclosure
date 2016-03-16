
import Foundation
import SocketIOClientSwift
import SwiftyJSON

protocol SocketGameDelegate{
    func gotMove(move: String)
    func restartGame(player: Int)
    func requestRestart()
}

protocol SocketSuccessDelegate{
    func joinSuccess(success: Bool)
    func gotRoomNumber(number: String)
    func playerSequence(player: Int, names: [String])
}

public class Socket: NSObject {
    
    let socketClient:SocketIOClient
    var roomNumber = ""
    
    var startDelegate: SocketSuccessDelegate?
    var gameDelegate: SocketGameDelegate?
    
    init(roomNumber: String) {
        self.roomNumber = roomNumber
        socketClient = SocketIOClient(socketURL: NSURL(string: "http://o.hl0.co:3000")!, options: [.Log(false), .ForcePolling(true)])
        super.init()
        self.addHandlers()
        socketClient.connect()
        print("init new sockect")
    }
    
    func createRoom() {
        let json: JSON = ["id":Connection.getUserId(), "level": "1"]
        print(json.rawString()!)

        self.socketClient.emit("createRoom",json.rawString()!)
    }
    
    func searchRoom() {
        let json: JSON = ["id":Connection.getUserId(), "room": roomNumber]
        self.socketClient.emit("joinRoom", json.rawString()!)
    }
    
    func gameEnd() {
        self.socketClient.emit("gameEnd","")
    }
    
    func playerMove(move: String) {
        self.socketClient.emit("gameMove", move)
    }
    
    func requestRestart(){
        self.socketClient.emit("gameRestart","")
    }

    func refuseRestart(){
        self.socketClient.emit("refuseRestart","")
    }
    
    func addHandlers() {
        // Our socket handlers go here
        
        //connected
        self.socketClient.on("connect") { (data, ack) -> Void in
            if self.roomNumber == ""{
                self.createRoom()
            }else{
                self.searchRoom()
            }
        }
        
        self.socketClient.on("roomNotFound") { (data, ack) -> Void in
            print(data)
            self.startDelegate?.joinSuccess(false)
        }
        
        // Using a shorthand parameter name for closures
        self.socketClient.on("roomCreated") { (data, ack) -> Void in
            print(data)
            self.roomNumber = String(data[0])
            self.startDelegate?.gotRoomNumber(String(data[0]))
        }
        
        self.socketClient.on("gameCanStart") { (data, ack) -> Void in
            let str = data[0]
           
            let data = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
            var namesArr = [String]()
            var num = 0
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String: AnyObject]
                if let names = json["names"] as? [String] {
                    namesArr = names
                }
                if let index = json["index"] as? Int {
                    num = index
                }
            } catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            self.startDelegate?.playerSequence(num, names:[namesArr[0],namesArr[1]])
            self.startDelegate?.joinSuccess(true)
        }

        self.socketClient.on("inviteToRestart") { (data, ack) -> Void in
            print(data)
            self.gameDelegate?.requestRestart()
        }
        
        self.socketClient.on("gameCanRestart") { (data, ack) -> Void in
            print(data)
            self.gameDelegate?.restartGame(Int(data[0] as! NSNumber))
        }
        
        self.socketClient.on("gameMove") { (data, ack) -> Void in
            print(data)
            self.gameDelegate?.gotMove(String(data[0]))
        }
        self.socketClient.on("mapUpdate") { (data, ack) -> Void in
            print(data)
//            self.gameDelegate?.gotMove(String(data[0]))
        }
        self.socketClient.on("userDisconnect") { (data, ack) -> Void in
            print(data)
        }
        
        self.socketClient.onAny {
            print("test \($0.event)  \($0.items)")
        }
        
    }
    
}