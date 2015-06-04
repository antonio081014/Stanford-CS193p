//
//  HappinessViewController.swift
//  Happiness
//
//  Created by Antonio081014 on 6/3/15.
//  Copyright (c) 2015 Antonio081014.com. All rights reserved.
//

import UIKit

class HappinessViewController: UIViewController {

    var happiness: Int = 50 {
        didSet {
            happiness = min(max(happiness, 0), 100)
            println("\(happiness)")
            updateUI()
        }
    }
    
    func updateUI() {
    }
}
