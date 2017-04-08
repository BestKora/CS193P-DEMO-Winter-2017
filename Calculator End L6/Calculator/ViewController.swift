//
//  ViewController.swift
//  Calculator
//
//  Created by CS193p Instructor. on 1/9/17
//  Copyright © 2017 Stanford University.
//  All rights reserved.
//

import UIKit

var calculatorCount = 0

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    var userInTheMiddleOfTyping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calculatorCount += 1
        print ("Load up a new Calculator (count = \(calculatorCount))")
        
        brain.addUnaryOperation(named: "✅") {  [weak weakSelf = self] in
            weakSelf?.display.textColor = UIColor.green
            return sqrt ($0)
        }
    }
    
    deinit {
         calculatorCount -= 1
         print ("Calculator left the heap (count = \(calculatorCount))")
    }
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        } else {
            display.text = digit
            userInTheMiddleOfTyping = true
        }
    }

    var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String (newValue)
        }
    }
    /*    brain.addUnaryOperation(named: "✅") { /* [weak weakSelf = self] in*/
     self.display.textColor = UIColor.green
     //          weakSelf?.display.textColor = UIColor.green
     return sqrt ($0)
     }
     */ 
    private var brain = CalculatorBrain ()
    
    @IBAction func performOPeration(_ sender: UIButton) {
        if userInTheMiddleOfTyping {
            brain.setOperand(displayValue)
            userInTheMiddleOfTyping = false
        }
        if  let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
    }
}
