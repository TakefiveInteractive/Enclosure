//
//  Tool.swift
//  Enclosure
//
//  Created by Kedan Li on 2/27/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class Tool: NSObject {

    
    class func profile(function: (()->()))->Double{
        let start = NSDate()
        function()
        let end = NSDate()
        
        let timeInterval: Double = end.timeIntervalSinceDate(start)
        return timeInterval
    }

}
