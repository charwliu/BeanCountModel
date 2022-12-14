//
//  Price.swift
//  vWallet
//
//  Created by Liu Wei on 6/23/21.
//

import Foundation


/// Errors a price can throw
public enum PriceError: Error {
    /// the price is listed in its own commodity
    case sameCommodity(String)
}

/// Price of a commodity in another commodity on a given date
public struct Price {

    /// Date of the Price
    public let date: Date

    /// `CommoditySymbol` of the Price
    public let commoditySymbol: CommoditySymbol

    /// `Amount` of the Price
    public let amount: Amount

    /// MetaData of the Price
    public let metaData: [String: String]

    /// Create a price
    ///
    /// - Parameters:
    ///   - date: date of the price
    ///   - commodity: commodity
    ///   - amount: amount
    /// - Throws: PriceError.sameCommodity if the commodity and the commodity of the amount are the same
    public init(date: Date, commoditySymbol: CommoditySymbol, amount: Amount, metaData: [String: String] = [:]) throws {
        self.date = date
        self.commoditySymbol = commoditySymbol
        self.amount = amount
        self.metaData = metaData
        guard commoditySymbol != amount.commoditySymbol else {
            throw PriceError.sameCommodity(commoditySymbol)
        }
    }

}

extension Price: CustomStringConvertible {

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter
    }()

    /// Returns the price string for the ledger.
    public var description: String {
        var result = "\(Self.dateFormatter.string(from: date)) price \(commoditySymbol) \(amount)"
        if !metaData.isEmpty {
            result += "\n\(metaData.map { "  \($0): \"\($1)\"" }.joined(separator: "\n"))"
        }
        return result
    }

}

extension PriceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .sameCommodity(error):
            return "Invalid Price, using same commodity: \(error)"
        }
    }
}

extension Price: Equatable {

    /// Retuns if the two prices are equal
    ///
    /// - Parameters:
    ///   - lhs: price 1
    ///   - rhs: price 2
    /// - Returns: true if the prices are equal, false otherwise
    public static func == (lhs: Price, rhs: Price) -> Bool {
        lhs.date == rhs.date && lhs.commoditySymbol == rhs.commoditySymbol && lhs.amount == rhs.amount && lhs.metaData == rhs.metaData
    }

}

