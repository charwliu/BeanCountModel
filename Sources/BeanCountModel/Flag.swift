//
//  File.swift
//  vWallet
//
//  Created by Liu Wei on 6/23/21.
//

import Foundation

/// A Flag represents the state of a `Transaction`
public enum Flag: String {

    /// complete to mark that the transaction was checked
    case complete = "*"

    /// incomplete to mark that the transaction requires further attantion
    case incomplete = "!"
}

extension Flag: CustomStringConvertible {

    /// Retuns the `String` which represents the flag in the ledger file
    public var description: String { self.rawValue }

}
