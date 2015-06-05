//
//  ViewController.swift
//  Calculator
//
//  Created by Antonio081014 on 2/20/15.
//  Copyright (c) 2015 Antonio081014.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    @IBOutlet weak var history: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var userIsInTheMiddleOfTypingANumber: Bool = false
    var floatPointIsAdded: Bool = false
    
    var brain = CalculatorBrain()

    @IBAction func EnterDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            if (digit != ".") || !floatPointIsAdded {
                display.text = display.text! + digit
            } else {
                displayValue = nil
            }
        } else {
            if digit == "." { display.text = "0." }
            else { display.text = digit }
            userIsInTheMiddleOfTypingANumber = true
        }
        if digit == "." {
            floatPointIsAdded = true
        }
    }
    
    var displayValue: Double? {
        get {
            if let displayText = display.text{
                if let displayNumber = NSNumberFormatter().numberFromString(displayText) {
                    return displayNumber.doubleValue
                }
            }
            return nil
        }
        set {
            if newValue != nil {
                display.text = "\(newValue!)"
            } else {
                display.text = "0"
            }
            userIsInTheMiddleOfTypingANumber = false
            floatPointIsAdded = false
        }
    }
    
    private func addOperand() {
        userIsInTheMiddleOfTypingANumber = false
        floatPointIsAdded = false
        if let number = displayValue {
            displayValue = brain.performOperand(number)
        }
    }
    
    private func reset() {
        displayValue  = nil
        history.text = brain.history()
        brain.reset()
    }
    
    @IBAction func backspace() {
        if userIsInTheMiddleOfTypingANumber {
            if count(display.text!) > 0 {
                if display.text![display.text!.endIndex.predecessor()] == "." {
                    floatPointIsAdded = false
                }
                
                display.text = dropLast(display.text!)
                
                if count(display.text!) == 0 {
                    displayValue = nil
                }
            }
        } else {
            brain.dropLast()
            history.text = brain.history()
        }
    }
    
    @IBAction func changeSign(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            if display.text![display.text!.startIndex] == "-" {
                display.text = display.text!.substringFromIndex(advance(display.text!.startIndex, 1))
            } else {
                display.text = "-" + display.text!
            }
        } else {
            operate(sender)
        }
    }
    
    @IBAction func clear(sender: UIButton) {
        reset()
    }
    
    @IBAction func enter() {
        addOperand()
        history.text = brain.history()
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        if let operation = sender.currentTitle {
            displayValue = brain.performOperation(operation)
            display.text = "=" + display.text!
            history.text = brain.history()
        }
    }
    
    @IBAction func result(sender: UIButton) {
        displayValue = brain.evaluate()
        display.text = "=" + display.text!
    }
}

