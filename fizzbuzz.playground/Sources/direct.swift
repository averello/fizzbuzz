//
//  direct.swift
//  fizzbuzz3
//
//  Created by Georges Boumis on 19/2/20.
//  Copyright © 2020 Georges Boumis. All rights reserved.
//

import Foundation

public struct Direct {

    enum Command {
        /// Nop.
        case skip
        /// Stops the execution of the current program.
        case halt
        /// Prints the given argument.
        case print(String)
    }

    typealias Program = [Command]
    typealias Context = (Program) -> Program

    static func interpret(_ p: Program) -> String {
        func foldr<A : Sequence, B>(xs: A,
                                    y: B,
                                    f: @escaping (A.Iterator.Element, () -> B) -> B) -> B {
            var g = xs.makeIterator()
            var next: () -> B = {y}
            next = { return g.next().map {x in f(x, next)} ?? y }
            return next()
        }
        func step(_ c: Command, _ r: () -> String) -> String {
            switch c {
            case .skip:
                return r()
            case .halt:
                return ""
            case .print(let s):
                return s + r()
            }
        }
        return foldr(xs: p, y: "", f: step)
    }


    static let fizz = { (n: Int) -> Context in
        return n % 3 == 0
            ? { x in [Command.print("fizz")] + x + [Command.halt] }
            : { x in x }
    }
    static let buzz = { (n: Int) -> Context in
        return n % 5 == 0
            ? { x in [Command.print("buzz")] + x + [Command.halt] }
            : { x in x }
    }
    static let base = { (n: Int) -> Context in
        return { x in
            x + [Command.print("\(n)")]
        }
    }
    static let fb = { (n: Int) -> Program in
        return (base(n) ◦ fizz(n) ◦ buzz(n))([Command.skip])
        //    return base(n)(fizz(n)(buzz(n)([Command.skip])))
    }
    public static let fizzbuzz = { (n: Int) -> String in
        interpret(fb(n))
    }
}
