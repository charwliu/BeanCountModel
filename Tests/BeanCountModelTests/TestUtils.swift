//
//  TestUtils.swift
//  
//
//  Created by Liu Wei on 8/12/22.
//

import Foundation
import BeanCountModel


enum TestUtils {

    static var date20170610: Date = {
        Date(timeIntervalSince1970: 1_497_078_000)
    }()

    static var date20170609: Date = {
        Date(timeIntervalSince1970: 1_496_991_600)
    }()

    static var date20170608: Date = {
        Date(timeIntervalSince1970: 1_496_905_200)
    }()

    static let cad: CommoditySymbol = "CAD"
    static let eur: CommoditySymbol = "EUR"
    static let usd: CommoditySymbol = "USD"

    static var cadCommodity: Commodity = {
        Commodity(symbol: cad)
    }()

    static var eurCommodity: Commodity = {
        Commodity(symbol: eur)
    }()

    static var usdCommodity: Commodity = {
        Commodity(symbol: usd)
    }()

    static var chequing: AccountName = {
        try! AccountName("Assets:Chequing") // swiftlint:disable:this force_try
    }()

    static var cash: AccountName = {
        try! AccountName("Assets:Cash") // swiftlint:disable:this force_try
    }()

    static var income: AccountName = {
        try! AccountName("Income:Test") // swiftlint:disable:this force_try
    }()

    static var amount: Amount = {
        Amount(number: Decimal(1), commoditySymbol: cad)
    }()

    static var amount2: Amount = {
        Amount(number: Decimal(1), commoditySymbol: eur)
    }()

}
