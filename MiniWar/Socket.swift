
import Foundation
import SocketIOClientSwift


public class Socket: NSObject {
    
    let socket:SocketIOClient
    var isCreator = false
    var roomNumber = "325879943"
    
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
            
        }
        // Using a shorthand parameter name for closures
        self.socket.on("roomCreated") { (data, ack) -> Void in
            print(data)
        }
        
        self.socket.on("gameCanStart") { (data, ack) -> Void in
            print(data)
        }
        
        self.socket.onAny {
            print("test \($0.event)  \($0.items)")
        }
        
        self.socket.on("connect") {data, ack in
            print("socket connected")
        }
        
        self.socket.on("startGame") {[weak self] data, ack in
            self?.handleStart()
            return
        }
        
        self.socket.on("win") {[weak self] data, ack in
            if let name = data[0] as? String {                self?.handleWin(name)
            }//TODO
        }
        self.socket.on("gameReset") {data, ack in
            
        }
    }
    
    func handleStart() {
        
    }
    
    func handleWin(name:String) {
        
    }
    

    func sendRestrat() {
        
        self.socket.emit("restart", [])
    }
    
}