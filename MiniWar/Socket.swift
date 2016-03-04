
import Foundation
import SocketIOClientSwift


protocol SocketSuccessDelegate{
    func joinSuccess(success: Bool)
    func gotRoomNumber(number: String)
}

public class Socket: NSObject {
    
    let socketClient:SocketIOClient
    var roomNumber = ""
    
    var startDelegate: SocketSuccessDelegate?
    
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
    
    func searchRoom() {
        self.socketClient.emit("joinRoom", roomNumber)
    }
    
    func roomNotExist(){
        // delegate
        print("roomNotExist")
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
            self.roomNumber = String(data)
            self.startDelegate?.gotRoomNumber(String(data))
        }
        
        self.socketClient.on("gameCanStart") { (data, ack) -> Void in
            self.startDelegate?.joinSuccess(true)
            print(data)
            print("data")
        }
        
        self.socketClient.onAny {
            print("test \($0.event)  \($0.items)")
        }
        //gameReset
        
        //gameDisconnect
        
        //gameMove
        
    }
    
    func handleStart() {
        
    }
    
    func handleWin(name:String) {
        
    }
    
    func sendRestrat() {
        
        self.socketClient.emit("restart", [])
    }
    
}