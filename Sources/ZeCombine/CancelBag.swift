//
//  CancelBag.swift
//

import Combine

public final class CancelBag {
    fileprivate(set) var subscriptions = Set<AnyCancellable>()
    
    public func cancel() {
        subscriptions.removeAll()
    }
}

public extension AnyCancellable {
    
    public func store(in cancelBag: CancelBag) {
        cancelBag.subscriptions.insert(self)
    }
}
