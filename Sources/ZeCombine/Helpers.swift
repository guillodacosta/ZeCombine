//
//  Helpers.swift
//

import SwiftUI
import Combine


extension ProcessInfo {
    public var isRunningTests: Bool {
        environment["XCTestConfigurationFilePath"] != nil
    }
}

extension String {
    func localized(_ locale: Locale) -> String {
        let localeId = locale.shortIdentifier
        guard let path = Bundle.main.path(forResource: localeId, ofType: "lproj"),
            let bundle = Bundle(path: path) else {
            return NSLocalizedString(self, comment: "")
        }
        return bundle.localizedString(forKey: self, value: nil, table: nil)
    }
}

extension Result {
    public var isSuccess: Bool {
        switch self {
        case .success: return true
        case .failure: return false
        }
    }
}

public final class Inspection<V> {
    var callbacks = [UInt: (V) -> Void]()
    let notice = PassthroughSubject<UInt, Never>()
    
    func visit(_ view: V, _ line: UInt) {
        if let callback = callbacks.removeValue(forKey: line) {
            callback(view)
        }
    }
}

extension Locale {
    
    public var shortIdentifier: String {
        return String(identifier.prefix(2))
    }
}
