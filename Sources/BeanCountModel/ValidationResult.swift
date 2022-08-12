//
//  ValidationResult.swift
//  vWallet
//
//  Created by Liu Wei on 6/23/21.
//

import Foundation

/// Result of a validation
///
/// - valid: the tested object is valid
/// - invalid: the tested object is invalid, including an error message
enum ValidationResult {

    case valid
    case invalid(String)

}
