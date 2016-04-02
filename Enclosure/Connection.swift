//
//  Connection.swift
//  Enclosure
//
//  Created by Kedan Li on 3/13/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit
import Alamofire

let Connection = UserData()

protocol UserDataDelegate{
    func rankUpdate(rank: String)
    func nicknameUpdate(name: String)
}

protocol RankUpdateDelegate{
    func rankUpdate(new: Int, old: Int)
}

let url = "http://o.hl0.co:8888"

class UserData: NSObject {
    
    var delegate: UserDataDelegate?
    
    var rankDelegate: RankUpdateDelegate?

    //request for the user id with UDID
    func getUserId()->String{
        return UIDevice.currentDevice().identifierForVendor!.UUIDString
    }
    
    func getUserRank()->String{
        if let rank = NSUserDefaults.standardUserDefaults().objectForKey("rank"){
            if "\(rank)" == "-1"{
                return "-"
            }else{
                return "\(rank)"
            }
        }else{
            return "-"
        }
    }
    
    func getUserNickName()->String{
        return NSUserDefaults.standardUserDefaults().objectForKey("nickName") as! String
    }
    
    func register(){
        
        Alamofire.request(.POST, url+"/register", parameters: ["userId": Connection.getUserId()])
            .responseJSON { response in
                
                if let JSON = response.result.value {
                    if let name = JSON["name"]{
                        NSUserDefaults.standardUserDefaults().setObject(name, forKey: "nickName")
                        self.delegate?.nicknameUpdate(self.getUserNickName())
                        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "register")
                    }
                    if let rank = JSON["rank"]{
                        NSUserDefaults.standardUserDefaults().setObject(rank, forKey: "rank")
                        self.delegate?.rankUpdate(self.getUserRank())
                        NSUserDefaults.standardUserDefaults().setObject(true, forKey: "register")
                    }
                    print("JSON: \(JSON)")
                }
        }
    }
    
    func getInfo()->Bool{
        
        Alamofire.request(.GET, url+"/info", parameters: ["userId": Connection.getUserId()])
            .responseJSON { response in

                if let JSON = response.result.value {
                    if let name = JSON["name"]{
                        if name != nil{
                            NSUserDefaults.standardUserDefaults().setObject(name, forKey: "nickName")
                            self.delegate?.nicknameUpdate(self.getUserNickName())
                        }
                    }
                    if let rank = JSON["rank"]{
                        if rank != nil{
                            NSUserDefaults.standardUserDefaults().setObject(rank, forKey: "rank")
                            self.delegate?.rankUpdate(self.getUserRank())
                        }
                    }
                    print("JSON: \(JSON)")
                }
        }
        return true
    }
    
    func setName(name: String){
        NSUserDefaults.standardUserDefaults().setObject(name, forKey: "nickName")
        self.delegate?.nicknameUpdate(name)
        Alamofire.request(.POST, url+"/setName", parameters: ["userId": Connection.getUserId(), "name": Connection.getUserNickName()])
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                }
        }
    }
    
    func getTop100(completion: [String] -> ()) {
        Alamofire.request(.GET, url+"/top100")
            .responseJSON { response in
                if let res = response.result.value {
                    let json = res as? [String] ?? []
                    completion(json)
                }
        }
    }
    
    func uploadGame(playerNames: [String], playerIds: [String], isOffLine: Bool, move: [[[[Int]]]], winId: String, gameID: String, isRanking: Bool){
        
        Alamofire.request(.POST, url+"/report", parameters: ["playerNames": playerNames, "playerIds": playerIds, "gameID": gameID, "move" :move, "winId": winId, "selfId": Connection.getUserId(), "isOffLine": isOffLine, "isRanking":isRanking], encoding: ParameterEncoding.JSON)
            .responseJSON { response in
                
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization
                
                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    if isRanking {
                        self.rankDelegate?.rankUpdate(JSON["new"] as! Int, old: JSON["old"] as! Int)
                    }
                }
        }
    }
    
}
