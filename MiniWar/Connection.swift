//
//  Connection.swift
//  Enclosure
//
//  Created by Kedan Li on 3/13/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class Connection: NSObject {
    
    //request for the user id with UDID
    class func getUserId()->String{
        
        return NSUUID().UUIDString
    }
}
