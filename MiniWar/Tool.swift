//
//  Tool.swift
//  Enclosure
//
//  Created by Kedan Li on 2/27/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class Tool: NSObject {

    // test the speed of a funciton
    class func profile(function: (()->()))->Double{
        let start = NSDate()
        function()
        let end = NSDate()
        
        let timeInterval: Double = end.timeIntervalSinceDate(start)
        return timeInterval
    }

    // get random element from a set
    class func randomElementFromSet<T>(s: Set<T>) -> T {
        let n = Int(arc4random_uniform(UInt32(s.count)))
        let l = Array(s)
        return l[n]
    }

    class func randomElementFromArray<T>(l: Array<T>) -> T {
        let n = Int(arc4random_uniform(UInt32(l.count)))
        return l[n]
    }
    
    class func mergeSet<T>(bigset: Set<T>, smallset: Set<T>) -> Set<T> {
        var result = bigset
        for element in smallset{
            result.insert(element)
        }
        return result
    }
    
    class func subtractSet<T>(set: Set<T>, subset: Set<T>) -> Set<T> {
        var result = set
        for element in subset{
            result.remove(element)
        }
        return result
    }

}
