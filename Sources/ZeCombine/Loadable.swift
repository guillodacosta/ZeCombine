//
//  Loadable.swift
//

import Foundation
import SwiftUI

public typealias LoadableSubject<Value> = Binding<Loadable<Value>>

public enum Loadable<T> {

    case notRequested
    case isLoading(last: T?, cancelBag: CancelBag)
    case loaded(T)
    case failed(Error)

    var value: T? {
        switch self {
        case let .loaded(value): return value
        case let .isLoading(last, _): return last
        default: return nil
        }
    }
    
    public var wrappedValue: T? {
        value
    }
    
    var error: Error? {
        switch self {
        case let .failed(error): return error
        default: return nil
        }
    }
}

extension Loadable {
    
    public mutating func setIsLoading(cancelBag: CancelBag) {
        self = .isLoading(last: value, cancelBag: cancelBag)
    }
    
    public mutating func cancelLoading() {
        switch self {
        case let .isLoading(last, cancelBag):
            cancelBag.cancel()
            if let last = last {
                self = .loaded(last)
            } else {
                let error = NSError(
                    domain: NSCocoaErrorDomain, code: NSUserCancelledError,
                    userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Canceled by user", comment: "")])
                self = .failed(error)
            }
        default: break
        }
    }
    
    public func rawMap<V>(_ transform: (T?) throws -> V) -> V? {
        do {
            let val = try transform(value)
            return val
        } catch {
            return nil
        }
    }
    
    public func map<V>(_ transform: (T) throws -> V) -> Loadable<V> {
        do {
            switch self {
            case .notRequested: return .notRequested
            case let .failed(error): return .failed(error)
            case let .isLoading(value, cancelBag):
                return .isLoading(last: try value.map { try transform($0) }, cancelBag: cancelBag)
            case let .loaded(value):
                return .loaded(try transform(value))
            }
        } catch {
            return .failed(error)
        }
    }

}

public protocol SomeOptional {
    associatedtype Wrapped
    func unwrap() throws -> Wrapped
}

struct ValueIsMissingError: Error {
    var localizedDescription: String {
        NSLocalizedString("Data is missing", comment: "")
    }
}

extension Optional: SomeOptional {
    public func unwrap() throws -> Wrapped {
        switch self {
        case let .some(value): return value
        case .none: throw ValueIsMissingError()
        }
    }
}

extension Loadable where T: SomeOptional {
    public func unwrap() -> Loadable<T.Wrapped> {
        map { try $0.unwrap() }
    }
}

extension Loadable: Equatable where T: Equatable {
    public static func == (lhs: Loadable<T>, rhs: Loadable<T>) -> Bool {
        var equatable: Bool = false
        switch (lhs, rhs) {
        case (.notRequested, .notRequested):
            equatable = true
        case let (.isLoading(lhsV, _), .isLoading(rhsV, _)):
            equatable = lhsV == rhsV
        case let (.loaded(lhsV), .loaded(rhsV)):
            equatable = lhsV == rhsV
        case let (.failed(lhsE), .failed(rhsE)):
            equatable = lhsE.localizedDescription == rhsE.localizedDescription
        default: break
        }
        return equatable
    }
}
