//
//  structures.swift
//  fizzbuzz3
//
//  Created by Georges Boumis on 19/2/20.
//  Copyright © 2020 Georges Boumis. All rights reserved.
//

import Foundation

/*:
 ## Commands
 */

public struct Structures {

    /// The Supported commands of the DSL.
    enum Command {
        /// Nop.
        case skip
        /// Stops the execution of the current program.
        case halt
        /// Prints the given argument.
        case print(String)
    }


    static let baseN = { (n: String) -> Structures.Program.Context in
        Structures.Program.Context(tail: .print(n))
    }

    static let fizzN = { (n: String) -> Structures.Program.Context in
        if Int(n)!.quotientAndRemainder(dividingBy: 3).remainder == 0 {
            return Structures.Program.Context(.print("fizz"), .halt)
        } else {
            return Structures.Program.Context()
        }
    }

    static let buzzN = { (n: String) -> Structures.Program.Context in
        if Int(n)!.quotientAndRemainder(dividingBy: 5).remainder == 0 {
            return Structures.Program.Context(.print("buzz"), .halt)
        } else {
            return Structures.Program.Context()
        }
    }

    public static let fizzBuzz = { (n: String) -> String in
        return (baseN(n) ◦ fizzN(n) ◦ buzzN(n))(.skip)()

        // OR

        //    let base = baseN(n)
        //    let fizz = fizzN(n)
        //    let buzz = buzzN(n)
        //
        //    let comp1 = base.compose(fizz)
        //    let final = comp1.compose(buzz)
        //    let prog = final(.skip)
        //    return prog
    }
}

/*:
 ## Programs
 */

public extension Structures {
    /// A program is a sequence of commands.
    ///
    /// Acts like a linked list of commands.
    @dynamicCallable
    class Program {
        /// The current command.
        private let c: Command?
        /// The rest of the program.
        private let p: Program?

        /// Creates a one-command program.
        init(_ c: Command) {
            self.c = c
            self.p = .none
        }

        private init(_ c: Command, _ p: Program? = .none) {
            self.c = c
            self.p = p
        }

        private init() {
            self.c = .none
            self.p = .none
        }

        private init(commands: [Command]) {
            switch commands.count {
            case 1:
                self.c = commands[0]
                self.p = .none
            default:
                let cmd = commands[0]
                self.c = cmd
                let p = commands.suffix(from: 1).reduce(.ε) { (p: Program, c: Command) -> Program in
                    let p2 = p.append(c)
                    return p2
                }
                self.p = p
            }
        }

        /// Creates a Program from a sequence of Commands.
        convenience init(_ commands: Command...) {
            self.init(commands: commands)
        }

        /// The empty program.
        fileprivate static let ε: Program = Program()

        /// Executes a program.
        @discardableResult
        func dynamicallyCall(withArguments arguments: [String]) -> String {
            guard let cmd = c else {
                fatalError("can't execute an empty program")
            }
            switch cmd {
            case .skip:
                return p?() ?? ""
            case .halt:
                return ""
            case .print(let s):
                return s + (p?() ?? "")
            }
        }

        /// Append a Command at the end of the receiver.
        ///
        /// - parameter c: The command that will execute after the receiver.
        func append(_ c: Command) -> Program {
            return self.concat(Program(c))
        }

        fileprivate func concat(_ p: Program?) -> Program {
            guard let program = p else { return self }
            return self.concat(program)
        }

        /// Appends the given's program commands at the end of the receiver.
        ///
        /// - parameter p: The program that will execute after the receiver.
        func concat(_ p: Program) -> Program {
            func extractCommands(ofProgram p: Program?) -> [Command] {
                guard let program = p, let cmd = program.c else { return [] }
                return [cmd] + extractCommands(ofProgram: program.p)
            }
            let head = extractCommands(ofProgram: self)
            let tail = extractCommands(ofProgram: p)
            return Program(commands: head + tail)
        }

        /// Concatenates two optional programs.
        ///
        /// - parameters:
        ///   - lhs: An optional program.
        ///   - rhs: Another optional program.
        fileprivate static func concat(_ lhs: Program?, _ rhs: Program?) -> Program? {
            switch (lhs, rhs) {
            case (.some(let a), .some(let b)):
                return a.concat(b)
            case (.none, .some(let p)),
                 (.some(let p), .none):
                return p
            case (.none, .none):
                return .none
            }
        }
    }
}

extension Structures.Program: CustomStringConvertible {
    public var description: String {
        guard let cmd = c else {
            return ""
        }
        return "\(cmd)" + (p != nil ? "; " + p!.description : "")
    }
}

extension Structures.Command: Equatable {}

extension Structures.Program: Equatable {
    public static func ==(lhs: Structures.Program, rhs: Structures.Program) -> Bool {
        switch (lhs.c, rhs.c) {
        case (.none, .none):
            return lhs.p == rhs.p
        case (.some(_), .none),
             (.none, .some(_)):
            return false
        case (.some(let a), .some(let b)):
            return a == b && lhs.p == rhs.p
        }
    }
}

/*:
 ## Contexts
 - Example: Possible contexts:
 * empty: `〈•〉`
 * head hole: `〈 •; Print "tail" 〉`
 * tail hole: `〈 Print "head"; •; 〉`
 * middle hole: `〈 Print "keep"; •; Print "calm" 〉`
 */

public extension Structures.Program {
    /// A Program with holes.
    ///
    /// Example of possible contexts:
    /// - `〈•〉`
    /// - `〈 •; Print "tail" 〉`
    /// - `〈 Print "head"; •; 〉`
    /// - `〈 Print "keep"; •; Print "calm" 〉`
    @dynamicCallable
    class Context {
        private let head: Structures.Program?
        private let tail: Structures.Program?

        private init(head: Structures.Program?, tail: Structures.Program?) {
            self.head = head
            self.tail = tail
        }

        /// The empty context.
        convenience init() {
            self.init(head: .none, tail: .none)
        }

        /// The middle-hole context.
        convenience init(_ head: Structures.Program, _ tail: Structures.Program) {
            self.init(head: head, tail: tail)
        }

        /// The tail-hole context.
        convenience init(head: Structures.Program) {
            self.init(head: head, tail: .none)
        }

        /// The head-hole context.
        convenience init(tail: Structures.Program) {
            self.init(head: .none, tail: tail)
        }

        /// The middle-hole context.
        convenience init(_ head: Structures.Command, _ tail: Structures.Command) {
            self.init(head: Structures.Program(head),
                      tail: Structures.Program(tail))
        }

        /// The tail-hole context.
        convenience init(head: Structures.Command) {
            self.init(head: Structures.Program(head), tail: .none)
        }

        /// The head-hole context.
        convenience init(tail: Structures.Command) {
            self.init(head: .none, tail: Structures.Program(tail))
        }

        /// filling a hole.
        func dynamicallyCall(withArguments arguments: [Structures.Program]) -> Structures.Program {
            return fill(arguments[0])
        }

        /// filling a hole.
        func dynamicallyCall(withArguments arguments: [Structures.Command]) -> Structures.Program {
            return self(Structures.Program(arguments[0]))
        }

        /// Fills a hole with the given program.
        ///
        /// - parameter p: The program that will fill the receiver's hole.
        private func fill(_ p: Structures.Program) -> Structures.Program {
            switch (head, tail) {
            case (.some(let h), .none):
                return h.concat(p)
            case (.none, .some(let t)):
                return p.concat(t)
            case (.none, .none):
                return p
            case (.some(let h), .some(let t)):
                return h.concat(p).concat(t)
            }
        }

        /// Composes the receiver with another context.
        ///
        /// - parameter other: The context to compose the receiver with.
        func compose(_ other: Context) -> Context {
            let head = Structures.Program.concat(self.head, other.head)
            let tail = Structures.Program.concat(other.tail, self.tail)
            let composition = Context(head: head,
                                      tail: tail)
            return composition
        }
    }
}

extension Structures.Program.Context: CustomStringConvertible {
    public var description: String {
        switch (head, tail) {
        case (.some(let h), .none):
            return "〈\(h); •〉"
        case (.none, .some(let t)):
            return "〈•; \(t)〉"
        case (.none, .none):
            return "〈•〉"
        case (.some(let h), .some(let t)):
            return "〈\(h); •; \(t)〉"
        }
    }
}

extension Structures.Program.Context {
    public static func ◦(lhs: Structures.Program.Context, rhs: Structures.Program.Context) -> Structures.Program.Context {
        return lhs.compose(rhs)
    }
}
