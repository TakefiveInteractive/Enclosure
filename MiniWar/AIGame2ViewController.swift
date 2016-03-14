//
//  AIGame2ViewController.swift
//  Enclosure
//
//  Created by Kedan Li on 3/7/16.
//  Copyright © 2016 TakeFive Interactive. All rights reserved.
//

import UIKit

class AIGame2ViewController: GameViewController {
    
    override func viewDidAppear(animated: Bool) {
        game = EnclosureGame2()
        board.buildGame(game)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
