//
//  TransactionMetaData.swift
//  vWallet
//
//  Created by Liu Wei on 6/23/21.
//

import Foundation


/// TransactionMetaData is data which is or can be attatched to an `Transaction`.
///
/// It consists of date, payee, narration as well as a flag and tags.
public struct TransactionMetaData {

    /// Date of the `Transaction`
    public let date: Date

    /// `String` describing the payee
    public let payee: String

    /// `String` with a comment for the `Transaction`
    public let narration: String

    /// `Flag` of the `Transaction`
    public let flag: Flag

    /// Array of `Tag`s, can be empty
    public let tags: [Tag]

    /// MetaData of the Transaction
    public let metaData: [String: String]

    /// Creates an transaction with the given parameters
    ///
    /// - Parameters:
    ///   - date: date of the transaction
    ///   - payee: `String` describing the payee
    ///   - narration: `String` with a comment for the `Transaction`
    ///   - flag: `Flag`
    ///   - tags: Array of `Tag`s, can be empty
    public init(date: Date, payee: String = "", narration: String = "", flag: Flag = .complete, tags: [Tag] = [], metaData: [String: String] = [:]) {
        self.date = date
        self.payee = payee
        self.narration = narration
        self.flag = flag
        self.tags = tags
        self.metaData = metaData
    }

}

extension TransactionMetaData: CustomStringConvertible {

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    /// `String` to represent the meta data of the `Transaction` in the ledger file (e.g. the first line above the `Posting`s
    public var description: String {
        var tagString = ""
        tags.forEach { tagString += " \(String(describing: $0))" }
        var result = "\(self.dateString) \(String(describing: flag)) \"\(payee)\" \"\(narration)\"\(tagString)"
        if !metaData.isEmpty {
            result += "\n\(metaData.map { "  \($0): \"\($1)\"" }.joined(separator: "\n"))"
        }
        return result
    }

    private var dateString: String { Self.dateFormatter.string(from: date) }

}

extension TransactionMetaData: Equatable {

    /// Compares two TransactionMetaData
    ///
    /// - Parameters:
    ///   - lhs: first TransactionMetaData
    ///   - rhs: second TransactionMetaData
    /// - Returns: true if all properties are the same, false otherwise
    public static func == (lhs: TransactionMetaData, rhs: TransactionMetaData) -> Bool {
        lhs.date == rhs.date && lhs.payee == rhs.payee && lhs.narration == rhs.narration && lhs.flag == rhs.flag && lhs.tags == rhs.tags && lhs.metaData == rhs.metaData
    }

}

extension TransactionMetaData: Hashable {

    public func hash(into hasher: inout Hasher) {
        hasher.combine(date)
        hasher.combine(payee)
        hasher.combine(narration)
        hasher.combine(flag)
        hasher.combine(tags)
        hasher.combine(metaData)
    }

}
