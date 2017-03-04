//: Playground - noun: a place where people can play

import UIKit

let i = 27

var f: (Double) -> Double

f = sqrt
let x = f(81)

f = cos
let y = f(Double.pi)

func changeSign(operand: Double) -> Double {
    return -operand
}

f = changeSign
let z = f(81)
