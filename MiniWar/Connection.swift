//
//  Connection.swift
//  Enclosure
//
//  Created by Kedan Li on 3/13/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit
import Alamofire

class Connection: NSObject {
    
    //request for the user id with UDID
    class func getUserId()->String{
        return UIDevice.currentDevice().identifierForVendor!.UUIDString
    }
    
    class func hasUserName()->Bool{
        if let name = NSUserDefaults.standardUserDefaults().objectForKey("nickName"){
            return true
        }else{
            return false
        }
    }
    
    class func getUserNickName()->String{
        return NSUserDefaults.standardUserDefaults().objectForKey("nickName") as! String
    }
    
    class func getInfo()->Bool{
        
        Alamofire.request(.POST, "http://o.hl0.co:3000/getInfo", parameters: ["userId": Connection.getUserId()])
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization

                if let JSON = response.result.value {
                    if JSON["name"] as! String != ""{
                        NSUserDefaults.standardUserDefaults().setObject(JSON["name"], forKey: "nickName")
                    }
                    print("JSON: \(JSON)")
                }
        }
        return true
    }
    
    class func setName(){
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
    
    
}
