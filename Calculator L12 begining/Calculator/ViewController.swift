//
//  ViewController.swift
//  Calculator
//
//  Created by CS193p Instructor. on 1/9/17
//  Copyright © 2017 Stanford University.
//  All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    var userInTheMiddleOfTyping = false
    
    // Lecture 12
    private func showSizeClasses() {
        if !userInTheMiddleOfTyping {
            display.textAlignment = .center
            display.text = "width " + traitCollection.horizontalSizeClass.description
                + " height " + traitCollection.verticalSizeClass.description
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showSizeClasses()
    }
    
    override func viewWillTransition(to size: CGSize,
                            with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { (coordinator) in
            self.showSizeClasses()
        }, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        brain.addUnaryOperation(named: "✅") {  [weak weakSelf = self] in
            weakSelf?.display.textColor = UIColor.green
            return sqrt ($0)
        }
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

// Lecture 12
extension UIUserInterfaceSizeClass: CustomStringConvertible {
    public var description: String {
        switch self {
        case .compact:
            return "Compact"
        case .regular:
            return "Regular"
        case .unspecified:
            return "??"
        }
    }
}
