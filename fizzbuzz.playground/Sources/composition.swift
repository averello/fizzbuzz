import Foundation

precedencegroup CompositionPrecedence { associativity: left }
infix operator ◦: CompositionPrecedence

public func ◦<T, U, V>(lhs: @escaping (U) -> V, rhs: @escaping (T) -> U) -> (T) -> V {
    return { x in lhs(rhs(x)) }
}
