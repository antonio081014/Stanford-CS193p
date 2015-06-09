//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Antonio081014 on 6/2/15.
//  Copyright (c) 2015 Antonio081014.com. All rights reserved.
//

import Foundation

class CalculatorBrain : Printable
{
    private enum Op : Printable {
        case Operand(Double)
        case UnaryOperation(String, Double ->Double)
        case BinaryOperation(String, (Double, Double) ->Double)
        case ConstantOperation(String, () ->Double)
        case Variable(String, () ->Double?)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand): return "\(operand)"
                case .UnaryOperation(let symbol, _): return symbol
                case .BinaryOperation(let symbol, _): return symbol
                case .ConstantOperation(let symbol, _): return symbol
                case .Variable(let symbol, _): return symbol
                }
            }
        }
    }
    
    private var knownOps = [String:Op]()
    
    private var opStack = [Op]()
    
    init() {
        variableValues = [String:Double]()
        
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("+", +))
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.BinaryOperation("×", *))
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.UnaryOperation("√") { $0 >= 0 ? sqrt($0) : 0 })
        learnOp(Op.UnaryOperation("sin", sin))
        learnOp(Op.UnaryOperation("cos", cos))
        learnOp(Op.UnaryOperation("±") {-1 * $0})
        learnOp(Op.ConstantOperation("π") {M_PI})
        
        
    }
    
    private func evalute(ops: [Op]) ->(result: Double?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .UnaryOperation(_, let operation):
                let operandEvaluation = evalute(remainingOps)
                if let operand = operandEvaluation.result {
                    return (operation(operand), operandEvaluation.remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let operand1Eval = evalute(remainingOps)
                if let operand1 = operand1Eval.result {
                    let operand2Eval = evalute(operand1Eval.remainingOps)
                    if let operand2 = operand2Eval.result {
                        return (operation(operand1, operand2), operand2Eval.remainingOps)
                    }
                }
            case .ConstantOperation(_, let operation):
                return (operation(), remainingOps)
            case .Variable(let variable, let operation):
                if contains(variableStack, variable) {
                    if let number = variableValues[variable] {
                        return (number, remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    func reset() {
        opStack.removeAll(keepCapacity: false)
    }
    
    func isEmpty() ->Bool {
        return opStack.isEmpty
    }
    
    func dropLast() {
        if !opStack.isEmpty {
            opStack.removeLast()
        }
    }
    
    func history() ->String {
        var retString = "History:"
        for op in opStack {
            retString += " " + op.description
        }
        return retString
    }
    
    func evaluate() ->Double? {
        let (result, remainder) = evalute(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func performOperation(symbol: String) ->Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        } else {
        }
        return evaluate()
    }
    
    func performOperand(operand: Double) ->Double? {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) ->Double? {
        variableStack.append(symbol)
        return evaluate()
    }
    
    var variableValues: Dictionary<String,Double>
    private var variableStack = [String]()
    // brain.variableValues[“x”] = 35.0
    
    var description: String {
        get {
            var contentDescription = descriptionOfEvaluation(opStack)
            var ret = contentDescription.result!
            
            while !contentDescription.remainingOps.isEmpty {
                contentDescription = descriptionOfEvaluation(contentDescription.remainingOps)
                ret = contentDescription.result! + "," + ret
            }
            
            return ret
        }
    }
    
    private func descriptionOfEvaluation(ops: [Op]) ->(result: String?, remainingOps: [Op]) {
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            switch op {
            case .Operand(let operand):
                return (op.description, remainingOps)
            case .UnaryOperation(let symbol, _):
                let operandDescription = descriptionOfEvaluation(remainingOps)
                if let result = operandDescription.result {
                    return (op.description + "(" + result + ")", operandDescription.remainingOps)
                }
            case .BinaryOperation(let symbol, _):
                let op1Description = descriptionOfEvaluation(remainingOps)
                if let description1 = op1Description.result {
                    let op2Description = descriptionOfEvaluation(op1Description.remainingOps)
                    if let description2 = op2Description.result {
                        return ("(" + description2 + " " + op.description + " " + description1 + ")", op2Description.remainingOps)
                    }
                }
            case .Variable(let symbol, _):
                return (op.description, remainingOps)
            case .ConstantOperation(let symbol, _):
                return (op.description, remainingOps)
            }
        }
        return ("?", ops)
    }
}