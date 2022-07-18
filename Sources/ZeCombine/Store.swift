//
//  Store.swift
//

import SwiftUI
import Combine

public typealias Store<State> = CurrentValueSubject<State, Never>

extension Store {
    
    public subscript<T>(keyPath: WritableKeyPath<Output, T>) -> T where T: Equatable {
        get { value[keyPath: keyPath] }
        set {
            var value = self.value
            if value[keyPath: keyPath] != newValue {
                value[keyPath: keyPath] = newValue
                self.value = value
            }
        }
    }
    
    public func bulkUpdate(_ update: (inout Output) -> Void) {
        var value = self.value
        update(&value)
        self.value = value
    }
    
    public func updates<Value>(for keyPath: KeyPath<Output, Value>) -> AnyPublisher<Value, Failure> where Value: Equatable {
        map(keyPath).removeDuplicates().eraseToAnyPublisher()
    }
}

extension Binding where Value: Equatable {
    public func dispatched<State>(to state: Store<State>,
                           _ keyPath: WritableKeyPath<State, Value>) -> Self {
        onSet { state[keyPath] = $0 }
    }
}

extension Binding where Value: Equatable {
    public typealias ValueClosure = (Value) -> Void
    
    public func onSet(_ perform: @escaping ValueClosure) -> Self {
        .init(get: { () -> Value in
            self.wrappedValue
        }, set: { value in
            if self.wrappedValue != value {
                self.wrappedValue = value
            }
            perform(value)
        })
    }
}
