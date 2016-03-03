
import Foundation
import SocketIOClientSwift


public class Socket: NSObject {
    
    let socket:SocketIOClient
    var isCreator = false
    var roomNumber = "507279678"
    
    override init() {
        socket = SocketIOClient(socketURL: NSURL(string: "http://o.hl0.co:3000")!, options: [.Log(false), .ForcePolling(true)])
        super.init()
        self.addHandlers()
        socket.connect()
        print("init new sockect")
    }
    
    func createRoom() {
        self.socket.emit("createRoom","")
    }
    
    func searchRoom() {
        self.socket.emit("joinRoom", roomNumber)
    }
    
    func roomNotExist(){
        // delegate
        print("roomNotExist")
    }
    
    func addHandlers() {
        // Our socket handlers go here
        
        //connected
        self.socket.on("connect") { (data, ack) -> Void in
            if self.isCreator{
                self.createRoom()
            }else{
                self.searchRoom()
            }
        }
        
        self.socket.on("roomError") { (data, ack) -> Void in
            print(data)
        }
        // Using a shorthand parameter name for closures
        self.socket.on("roomCreated") { (data, ack) -> Void in
            print(data)
        }
        
        self.socket.on("gameCanStart") { (data, ack) -> Void in
            print(data)
            print("data")
        }
        
        self.socket.onAny {
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
        
        self.socket.emit("restart", [])
    }
    
}