//
//  Custom.swift
//  vWallet
//
//  Created by Liu Wei on 6/23/21.
//

import Foundation


/// Custom directive
public struct Custom {

    /// Date of the directive
    public let date: Date

    /// Name of the custom directive
    public let name: String

    /// Values of the custom directive
    public let values: [String]

    /// MetaData of the custom directive
    public let metaData: [String: String]

    /// Create a Custom directive
    ///
    /// - Parameters:
    ///   - date: date
    ///   - name: name
    ///   - values: values
    public init(date: Date, name: String, values: [String], metaData: [String: String] = [:]) {
        self.date = date
        self.name = name
        self.values = values
        self.metaData = metaData
    }

}

extension Custom: CustomStringConvertible {

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    /// Returns the custom directive string for the ledger.
    public var description: String {
        var result = "\(Self.dateFormatter.string(from: date)) custom \"\(name)\" \(values.map { "\"\($0)\"" }.joined(separator: " "))"
        if !metaData.isEmpty {
            result += "\n\(metaData.map { "  \($0): \"\($1)\"" }.joined(separator: "\n"))"
        }
        return result
    }

}

extension Custom: Equatable {

    /// Retuns if the two Custom directives are equal
    ///
    /// - Parameters:
    ///   - lhs: custom 1
    ///   - rhs: custom 2
    /// - Returns: true if the custom directives are equal, false otherwise
    public static func == (lhs: Custom, rhs: Custom) -> Bool {
        lhs.date == rhs.date && lhs.name == rhs.name && lhs.values == rhs.values && lhs.metaData == rhs.metaData
    }

}

extension Custom: Comparable {

    public static func < (lhs: Custom, rhs: Custom) -> Bool {
        String(describing: lhs) < String(describing: rhs)
    }

}
