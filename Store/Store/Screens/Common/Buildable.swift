//
//  Buildable.swift
//  Store
//
//  Created by Mạnh Nguyễn Văn on 23/3/26.
//
import Foundation

protocol Buildable {}

extension Buildable {
    /// The "Generic Property Setter"
    func set<Value>(_ keyPath: WritableKeyPath<Self, Value>, to value: Value) -> Self {
        var copy = self
        copy[keyPath: keyPath] = value
        return copy
    }
}

public func debug<Target>(
    _ items: Any...,
    separator: String = " ",
    terminator: String = "\n",
    to output: inout Target
) where Target : TextOutputStream {
#if DEBUG || DEBUGGING
    debugPrint(items, separator: separator, terminator: terminator, to: &output)
#endif
}

public func debug(
    _ items: Any...,
    separator: String = " ",
    terminator: String = "\n"
) {
#if DEBUG || DEBUGGING
    debugPrint(items, separator: separator, terminator: terminator)
#endif
}


public func debug(
    _ items: Any...,
    separator: String = " "
) {
#if DEBUG || DEBUGGING
    debugPrint(items, separator: separator)
#endif
}
