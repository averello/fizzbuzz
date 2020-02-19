//
//  typealias.swift
//  fizzbuzz3
//
//  Created by Georges Boumis on 19/2/20.
//  Copyright © 2020 Georges Boumis. All rights reserved.
//

import Foundation

public struct Typealias {
    
    typealias Program = (String) -> String
    //typealias Context = (Program) -> Program
    static let SKIP: Program = { s in s }
    static let HALT: Program = { _ in "" }
    static let PRINT = { (s: String) -> Program in
        return { r in s + r }
    }

    static let fizz = { (n: Int) in
        return n % 3 == 0
            ? { x in PRINT("fizz") ◦ x ◦ HALT }
            : { x in x }
    }
    static let buzz = { (n: Int) in
        return n % 5 == 0
            ? { x in PRINT("buzz") ◦ x ◦ HALT }
            : { x in x }
    }
    static let base = { (n: Int) in
        return { (x: @escaping Program) in x ◦ PRINT(n.description)  }
    }

    public static var fizzBuzz: (Int) -> String {
        get {
            return { (n: Int) -> String in
                return (base(n)(fizz(n)(buzz(n)(SKIP))))("")
            }
        }
    }
}
