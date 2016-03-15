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
        return NSUUID().UUIDString
    }
    
    class func hasRegistered()->Bool{
        return NSUserDefaults.standardUserDefaults().objectForKey("registered")! as! Bool
    }
    
    class func register(name: String)->Bool{
        
        Alamofire.request(.POST, "http://o.hl0.co:3000/register", parameters: ["userId": Connection.getUserId(), "nickName": name])
            .responseJSON { response in
                print(response.request)  // original URL request
                print(response.response) // URL response
                print(response.data)     // server data
                print(response.result)   // result of response serialization

                if let JSON = response.result.value {
                    print("JSON: \(JSON)")
                    NSUserDefaults.standardUserDefaults().setObject(true, forKey: "registered")
                }
        }
        return true
    }
    
}
