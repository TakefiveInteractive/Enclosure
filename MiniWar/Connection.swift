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

class UserData: NSObject {
    
    var delegate: UserDataDelegate?
    
    //request for the user id with UDID
    func getUserId()->String{
        return UIDevice.currentDevice().identifierForVendor!.UUIDString
    }
    
    func getUserRank()->String{
        if let rank = NSUserDefaults.standardUserDefaults().objectForKey("rank"){
            return "\(rank)"
        }else{
            return "-"
        }
    }
    
    func getUserNickName()->String{
        return NSUserDefaults.standardUserDefaults().objectForKey("nickName") as! String
    }
    
    //getrank
    
    func getInfo()->Bool{
        
        Alamofire.request(.POST, "http://o.hl0.co:3000/getInfo", parameters: ["userId": Connection.getUserId()])
            .responseJSON { response in

                if let JSON = response.result.value {
                    if JSON["name"] as! String != ""{
                        NSUserDefaults.standardUserDefaults().setObject(JSON["name"], forKey: "nickName")
                        NSUserDefaults.standardUserDefaults().setObject(JSON["rank"], forKey: "rank")
                        self.delegate?.rankUpdate(self.getUserRank())
                        self.delegate?.nicknameUpdate(self.getUserNickName())
                    }
                    print("JSON: \(JSON)")
                }
        }
        return true
    }
    
    func setName(name: String){
        NSUserDefaults.standardUserDefaults().setObject(name, forKey: "nickName")
        self.delegate?.nicknameUpdate(name)
        Alamofire.request(.POST, "http://o.hl0.co:3000/setName", parameters: ["userId": Connection.getUserId(), "name": Connection.getUserNickName()])
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
        Alamofire.request(.GET, "http://o.hl0.co:3000/top100")
            .responseJSON { response in
                if let res = response.result.value {
                    let json = res as? [String] ?? []
                    completion(json)
                }
        }
    }
    
}
