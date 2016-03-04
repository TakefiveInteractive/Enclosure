
import Foundation
import SocketIOClientSwift


protocol SocketGameDelegate{
    func gotMove(move: String)
}

protocol SocketSuccessDelegate{
    func joinSuccess(success: Bool)
    func gotRoomNumber(number: String)
    func playerSequence(player: Int)
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
        self.socketClient.emit("createRoom","")
    }

    func gameEnd() {
        self.socketClient.emit("gameEnd","")
    }
    
    func searchRoom() {
        self.socketClient.emit("joinRoom", roomNumber)
    }
    
    func playerMove(move: String) {
        self.socketClient.emit("gameMove", move)
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
            print(data)
            self.startDelegate?.playerSequence(Int(data[0] as! NSNumber))
            self.startDelegate?.joinSuccess(true)
        }
        
        self.socketClient.on("gameMove") { (data, ack) -> Void in
            print(data)
            self.gameDelegate?.gotMove(String(data[0]))
        }
        
        self.socketClient.onAny {
            print("test \($0.event)  \($0.items)")
        }
        
    }
    
}