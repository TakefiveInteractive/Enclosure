
import Foundation
import SocketIOClientSwift


public class Socket {
    let socket = SocketIOClient(socketURL: NSURL(string: "http://o.hl0.co:3000")!, options: [.Log(true), .ForcePolling(true)])
    
    init() {
        self.addHandlers()
        self.socket.connect()
        print("init new sockect")
        
    }
    
    func addHandlers() {
        // Our socket handlers go here
        
        // Using a shorthand parameter name for closures
        self.socket.onAny {
            print("Got event: \($0.event), with items: \($0.items)")
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
    
    func sendReady() {
        self.socket.emit("ready","Ted")
    }
    
    func sendRestrat() {
        
        self.socket.emit("restart", [])
    }
    
}