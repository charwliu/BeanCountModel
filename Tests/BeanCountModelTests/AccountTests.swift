//
//  AccountTests.swift
//  
//
//  Created by Liu Wei on 8/12/22.
//

@testable import BeanCountModel
import XCTest

class AccountTests: XCTestCase {
    
    
    func testBookingMethod() {
        let defaultAccount = Account(name: TestUtils.cash)
        XCTAssertEqual(defaultAccount.bookingMethod, .strict)
        
        let fifoAccount = Account(name: TestUtils.cash, bookingMethod: .fifo)
        XCTAssertEqual(fifoAccount.bookingMethod, .fifo)
        
        let lifoAccount = Account(name: TestUtils.cash, bookingMethod: .lifo)
        XCTAssertEqual(lifoAccount.bookingMethod, .lifo)
    }
    
    func testDescription() {
        var accout = Account(name: TestUtils.cash)
        XCTAssertEqual(String(describing: accout), "")
        accout = Account(name: TestUtils.cash, opening: TestUtils.date20170608)
        XCTAssertEqual(String(describing: accout), "2017-06-08 open \(TestUtils.cash)")
        accout = Account(name: TestUtils.cash, commoditySymbol: TestUtils.eur, opening: TestUtils.date20170608)
        XCTAssertEqual(String(describing: accout), "2017-06-08 open \(TestUtils.cash) \(TestUtils.eur)")
        accout = Account(name: TestUtils.cash, commoditySymbol: TestUtils.eur, opening: TestUtils.date20170608, closing: TestUtils.date20170609)
        XCTAssertEqual(String(describing: accout), "2017-06-08 open \(TestUtils.cash) \(TestUtils.eur)\n2017-06-09 close \(TestUtils.cash)")
        accout = Account(name: TestUtils.cash, commoditySymbol: TestUtils.eur, opening: TestUtils.date20170608, closing: TestUtils.date20170609, metaData: ["A": "B"])
        XCTAssertEqual(String(describing: accout), "2017-06-08 open \(TestUtils.cash) \(TestUtils.eur)\n  A: \"B\"\n2017-06-09 close \(TestUtils.cash)")
    }
    
    func testDescriptionBookingMethod() {
        for bookingMethod in [BookingMethod.fifo, BookingMethod.lifo] {
            var accout = Account(name: TestUtils.cash, bookingMethod: bookingMethod)
            XCTAssertEqual(String(describing: accout), "")
            accout = Account(name: TestUtils.cash, bookingMethod: bookingMethod, opening: TestUtils.date20170608)
            XCTAssertEqual(String(describing: accout), "2017-06-08 open \(TestUtils.cash) \"\(bookingMethod)\"")
            accout = Account(name: TestUtils.cash, bookingMethod: bookingMethod, commoditySymbol: TestUtils.eur, opening: TestUtils.date20170608)
            XCTAssertEqual(String(describing: accout), "2017-06-08 open \(TestUtils.cash) \(TestUtils.eur) \"\(bookingMethod)\"")
            accout = Account(name: TestUtils.cash,
                             bookingMethod: bookingMethod,
                             commoditySymbol: TestUtils.eur,
                             opening: TestUtils.date20170608,
                             closing: TestUtils.date20170609)
            XCTAssertEqual(String(describing: accout), "2017-06-08 open \(TestUtils.cash) \(TestUtils.eur) \"\(bookingMethod)\"\n2017-06-09 close \(TestUtils.cash)")
        }
    }
    
    func testDescriptionSpecialCharacters() throws {
        let accountNameSpecial = try AccountName("Assets:????")
        
        var accout = Account(name: accountNameSpecial)
        XCTAssertEqual(String(describing: accout), "")
        accout = Account(name: accountNameSpecial, opening: TestUtils.date20170608)
        XCTAssertEqual(String(describing: accout), "2017-06-08 open \(accountNameSpecial)")
        let symbol = "????"
        accout = Account(name: accountNameSpecial, commoditySymbol: symbol, opening: TestUtils.date20170608)
        XCTAssertEqual(String(describing: accout), "2017-06-08 open \(accountNameSpecial) \(symbol)")
        accout = Account(name: accountNameSpecial, commoditySymbol: symbol, opening: TestUtils.date20170608, closing: TestUtils.date20170609)
        XCTAssertEqual(String(describing: accout), "2017-06-08 open \(accountNameSpecial) \(symbol)\n2017-06-09 close \(accountNameSpecial)")
    }
    
    func testIsPostingValid_NotOpenPast() {
        let account = Account(name: TestUtils.cash)
        let posting = Posting(accountName: TestUtils.cash, amount: Amount(number: Decimal(1), commoditySymbol: TestUtils.eur))
        let transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170608, payee: "Payee", narration: "Narration", flag: Flag.complete, tags: []),
                                      postings: [posting])
        if case .invalid(let error) = account.validate(transaction.postings[0]) {
            XCTAssertEqual(error, """
                    2017-06-08 * "Payee" "Narration"
                      Assets:Cash 1 EUR was posted while the accout Assets:Cash was closed
                    """)
        } else {
            XCTFail("\(posting) is valid on \(account)")
        }
    }
    
    func testIsPostingValid_NoOpenPresent() {
        let account = Account(name: TestUtils.cash)
        let posting = Posting(accountName: TestUtils.cash, amount: Amount(number: Decimal(1), commoditySymbol: TestUtils.eur))
        let transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170608, payee: "Payee", narration: "Narration", flag: Flag.complete, tags: []),
                                      postings: [posting])
        if case .invalid(let error) = account.validate(transaction.postings[0]) {
            XCTAssertEqual(error, """
                    2017-06-08 * "Payee" "Narration"
                      Assets:Cash 1 EUR was posted while the accout Assets:Cash was closed
                    """)
        } else {
            XCTFail("\(posting) is valid on \(account)")
        }
    }
    
    func testIsPostingValid_BeforeOpening() {
        let account = Account(name: TestUtils.cash, opening: TestUtils.date20170609)
        let posting = Posting(accountName: TestUtils.cash, amount: Amount(number: Decimal(1), commoditySymbol: TestUtils.eur))
        let transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170608, payee: "Payee", narration: "Narration", flag: Flag.complete, tags: []),
                                      postings: [posting])
        if case .invalid(let error) = account.validate(transaction.postings[0]) {
            XCTAssertEqual(error, """
                    2017-06-08 * "Payee" "Narration"
                      Assets:Cash 1 EUR was posted while the accout Assets:Cash was closed
                    """)
        } else {
            XCTFail("\(posting) is valid on \(account)")
        }
    }
    
    func testIsPostingValid_AfterOpening() {
        let account = Account(name: TestUtils.cash, opening: TestUtils.date20170609)
        let posting1 = Posting(accountName: TestUtils.cash, amount: TestUtils.amount)
        let transaction1 = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170609, payee: "Payee", narration: "Narration", flag: Flag.complete, tags: []),
                                       postings: [posting1])
        guard case .valid = account.validate(transaction1.postings[0]) else {
            XCTFail("\(posting1) is not valid on \(account)")
            return
        }
        
        let posting2 = Posting(accountName: TestUtils.cash, amount: TestUtils.amount)
        let transaction2 = Transaction(metaData: TransactionMetaData(date: Date(), payee: "Payee", narration: "Narration", flag: Flag.complete, tags: []),
                                       postings: [posting2])
        guard case .valid = account.validate(transaction2.postings[0]) else {
            XCTFail("\(posting2) is not valid on \(account)")
            return
        }
    }
    
    func testIsPostingValid_BeforeClosing() {
        let account = Account(name: TestUtils.cash, opening: TestUtils.date20170609, closing: TestUtils.date20170609)
        let posting = Posting(accountName: TestUtils.cash, amount: TestUtils.amount)
        let transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170609, payee: "Payee", narration: "Narration", flag: Flag.complete, tags: []),
                                      postings: [posting])
        guard case .valid = account.validate(transaction.postings[0]) else {
            XCTFail("\(posting) is not valid on \(account)")
            return
        }
    }
    
    func testIsPostingValid_AfterClosing() {
        let account = Account(name: TestUtils.cash, opening: TestUtils.date20170609, closing: TestUtils.date20170609)
        let posting = Posting(accountName: TestUtils.cash, amount: TestUtils.amount)
        let transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170610, payee: "Payee", narration: "Narration", flag: Flag.complete, tags: []),
                                      postings: [posting])
        if case .invalid(let error) = account.validate(transaction.postings[0]) {
            XCTAssertEqual(error, """
                    2017-06-10 * "Payee" "Narration"
                      Assets:Cash 1 CAD was posted while the accout Assets:Cash was closed
                    """)
        } else {
            XCTFail("\(posting) is valid on \(account)")
        }
    }
    
    func testIsPostingValid_WithoutCommodity() {
        let account = Account(name: TestUtils.cash, opening: TestUtils.date20170608)
        let posting1 = Posting(accountName: TestUtils.cash, amount: TestUtils.amount)
        let transaction1 = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170609, payee: "Payee", narration: "Narration", flag: Flag.complete, tags: []),
                                       postings: [posting1])
        guard case .valid = account.validate(transaction1.postings[0]) else {
            XCTFail("\(posting1) is not valid on \(account)")
            return
        }
        
        let posting2 = Posting(accountName: TestUtils.cash, amount: TestUtils.amount)
        let transaction2 = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170609, payee: "Payee", narration: "Narration", flag: Flag.complete, tags: []),
                                       postings: [posting2])
        guard case .valid = account.validate(transaction2.postings[0]) else {
            XCTFail("\(posting2) is not valid on \(account)")
            return
        }
    }
    
    func testIsPostingValid_CorrectCommodity() {
        let account = Account(name: TestUtils.cash, commoditySymbol: TestUtils.amount.commoditySymbol, opening: TestUtils.date20170608)
        let posting = Posting(accountName: TestUtils.cash, amount: TestUtils.amount)
        let transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170609, payee: "Payee", narration: "Narration", flag: Flag.complete, tags: []),
                                      postings: [posting])
        guard case .valid = account.validate(transaction.postings[0]) else {
            XCTFail("\(posting) is not valid on \(account)")
            return
        }
    }
    
    func testIsPostingValid_WrongCommodity() {
        let account = Account(name: TestUtils.cash, commoditySymbol: "\(TestUtils.amount.commoditySymbol)1", opening: TestUtils.date20170608)
        let posting = Posting(accountName: TestUtils.cash, amount: TestUtils.amount)
        let transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170609, payee: "Payee", narration: "Narration", flag: Flag.complete, tags: []),
                                      postings: [posting])
        if case .invalid(let error) = account.validate(transaction.postings[0]) {
            XCTAssertEqual(error, """
                    2017-06-09 * "Payee" "Narration"
                      Assets:Cash 1 CAD uses a wrong commodiy for account Assets:Cash - Only CAD1 is allowed
                    """)
        } else {
            XCTFail("\(posting) is valid on \(account)")
        }
    }
    
    func testIsValid() {
        var account = Account(name: TestUtils.cash)
        
        // neither closing nor opening
        guard case .valid = account.validate() else {
            XCTFail("\(account) is not valid")
            return
        }
        
        // only opening
        account = Account(name: TestUtils.cash, opening: TestUtils.date20170608)
        guard case .valid = account.validate() else {
            XCTFail("\(account) is not valid")
            return
        }
        
        // Closing == opening
        account = Account(name: TestUtils.cash, opening: TestUtils.date20170608, closing: TestUtils.date20170608)
        guard case .valid = account.validate() else {
            XCTFail("\(account) is not valid")
            return
        }
        
        // Closing > opening
        account = Account(name: TestUtils.cash, opening: TestUtils.date20170608, closing: TestUtils.date20170609)
        guard case .valid = account.validate() else {
            XCTFail("\(account) is not valid")
            return
        }
        
        // Closing < opening
        account = Account(name: TestUtils.cash, opening: TestUtils.date20170609, closing: TestUtils.date20170608)
        if case .invalid(let error) = account.validate() {
            XCTAssertEqual(error, "Account Assets:Cash was closed on 2017-06-08 before it was opened on 2017-06-09")
        } else {
            XCTFail("\(account) is valid")
        }
        
        // only closing
        account = Account(name: TestUtils.cash, closing: TestUtils.date20170608)
        if case .invalid(let error) = account.validate() {
            XCTAssertEqual(error, "Account Assets:Cash has a closing date but no opening")
        } else {
            XCTFail("\(account) is valid")
        }
    }
    
    func testValidateBalance() throws {
        let ledger = Ledger()
        let account = Account(name: TestUtils.cash, commoditySymbol: TestUtils.cad)
        try ledger.add(account)
        
        account.balances.append(Balance(date: TestUtils.date20170608, accountName: TestUtils.cash, amount: Amount(number: 0, commoditySymbol: TestUtils.cad)))
        guard case .valid = account.validateBalance(in: ledger) else {
            XCTFail("\(account) is not valid")
            return
        }
        
        account.balances.append(Balance(date: TestUtils.date20170609, accountName: TestUtils.cash, amount: Amount(number: 1, commoditySymbol: TestUtils.cad)))
        if case .invalid(let error) = account.validateBalance(in: ledger) {
            XCTAssertEqual(error, "Balance failed for 2017-06-09 balance Assets:Cash 1 CAD - 1 CAD too much (0 tolerance)")
        } else {
            XCTFail("\(account) is valid")
        }
        
        var posting = Posting(accountName: TestUtils.cash, amount: Amount(number: 1, commoditySymbol: TestUtils.cad))
        var transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170608, payee: "", narration: "", flag: .complete, tags: []), postings: [posting])
        ledger.add(transaction)
        
        guard case .valid = account.validateBalance(in: ledger) else {
            XCTFail("\(account) is not valid")
            return
        }
        
        posting = Posting(accountName: TestUtils.cash, amount: Amount(number: 10, commoditySymbol: TestUtils.cad))
        transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170609, payee: "", narration: "", flag: .complete, tags: []), postings: [posting])
        ledger.add(transaction)
        account.balances.append(Balance(date: TestUtils.date20170610, accountName: TestUtils.cash, amount: Amount(number: 11, commoditySymbol: TestUtils.cad)))
        guard case .valid = account.validateBalance(in: ledger) else {
            XCTFail("\(account) is not valid")
            return
        }
    }
    
    func testValidateBalanceEmpty() throws {
        let ledger = Ledger()
        let account = Account(name: TestUtils.cash, commoditySymbol: TestUtils.cad)
        try ledger.add(account)
        
        guard case .valid = account.validateBalance(in: ledger) else {
            XCTFail("\(account) is not valid")
            return
        }
        
        let posting = Posting(accountName: TestUtils.cash, amount: Amount(number: 1, commoditySymbol: TestUtils.cad))
        let transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170609, payee: "", narration: "", flag: .complete, tags: []), postings: [posting])
        ledger.add(transaction)
        
        guard case .valid = account.validateBalance(in: ledger) else {
            XCTFail("\(account) is not valid")
            return
        }
    }
    
    func testValidateBalanceDifferentCommodity() throws {
        let ledger = Ledger()
        let account = Account(name: TestUtils.cash)
        try ledger.add(account)
        
        account.balances.append(Balance(date: TestUtils.date20170608, accountName: TestUtils.cash, amount: Amount(number: 0, commoditySymbol: TestUtils.eur)))
        
        account.balances.append(Balance(date: TestUtils.date20170609, accountName: TestUtils.cash, amount: Amount(number: 1, commoditySymbol: TestUtils.cad)))
        if case .invalid(let error) = account.validateBalance(in: ledger) {
            XCTAssertEqual(error, "Balance failed for 2017-06-09 balance Assets:Cash 1 CAD - 1 CAD too much (0 tolerance)")
        } else {
            XCTFail("\(account) is valid")
        }
        
        var posting = Posting(accountName: TestUtils.cash, amount: Amount(number: 1, commoditySymbol: TestUtils.cad))
        var transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170608, payee: "", narration: "", flag: .complete, tags: []), postings: [posting])
        ledger.add(transaction)
        
        guard case .valid = account.validateBalance(in: ledger) else {
            XCTFail("\(account) is not valid")
            return
        }
        
        // Ignores other commodity without currency
        posting = Posting(accountName: TestUtils.cash, amount: Amount(number: 1, commoditySymbol: TestUtils.usd))
        transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170608, payee: "", narration: "", flag: .complete, tags: []), postings: [posting])
        ledger.add(transaction)
        guard case .valid = account.validateBalance(in: ledger) else {
            XCTFail("\(account) is not valid")
            return
        }
        
        account.balances.append(Balance(date: TestUtils.date20170609, accountName: TestUtils.cash, amount: Amount(number: 1, commoditySymbol: TestUtils.eur)))
        posting = Posting(accountName: TestUtils.cash, amount: Amount(number: 1, commoditySymbol: TestUtils.eur))
        transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170608, payee: "", narration: "", flag: .complete, tags: []), postings: [posting])
        ledger.add(transaction)
        guard case .valid = account.validateBalance(in: ledger) else {
            XCTFail("\(account) is not valid")
            return
        }
    }
    
    func testValidateBalanceTolerance() throws {
        let ledger = Ledger()
        let account = Account(name: TestUtils.cash, commoditySymbol: TestUtils.cad)
        try ledger.add(account)
        
        var posting = Posting(accountName: TestUtils.cash, amount: Amount(number: 1.1, commoditySymbol: TestUtils.cad, decimalDigits: 1))
        var transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170608, payee: "", narration: "", flag: .complete, tags: []), postings: [posting])
        ledger.add(transaction)
        
        account.balances = [Balance(date: TestUtils.date20170609, accountName: TestUtils.cash, amount: Amount(number: 1.15, commoditySymbol: TestUtils.cad, decimalDigits: 2))]
        if case .invalid(let error) = account.validateBalance(in: ledger) {
            XCTAssertEqual(error, "Balance failed for 2017-06-09 balance Assets:Cash 1.15 CAD - 0.05 CAD too much (0.005 tolerance)")
        } else {
            XCTFail("\(account) is valid")
        }
        
        account.balances = [Balance(date: TestUtils.date20170609, accountName: TestUtils.cash, amount: Amount(number: 1.15, commoditySymbol: TestUtils.cad, decimalDigits: 1))]
        guard case .valid = account.validateBalance(in: ledger) else {
            XCTFail("\(account) is not valid")
            return
        }
        
        posting = Posting(accountName: TestUtils.cash, amount: Amount(number: 0.055, commoditySymbol: TestUtils.cad, decimalDigits: 3))
        transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170608, payee: "", narration: "", flag: .complete, tags: []), postings: [posting])
        ledger.add(transaction)
        
        account.balances = [Balance(date: TestUtils.date20170609, accountName: TestUtils.cash, amount: Amount(number: 1.16, commoditySymbol: TestUtils.cad, decimalDigits: 2))]
        if case .invalid(let error) = account.validateBalance(in: ledger) {
            XCTAssertEqual(error, "Balance failed for 2017-06-09 balance Assets:Cash 1.16 CAD - 0.005 CAD too much (0.0005 tolerance)")
        } else {
            XCTFail("\(account) is valid")
        }
        
        account.balances = [
            Balance(date: TestUtils.date20170609, accountName: TestUtils.cash, amount: Amount(number: 1.155_5, commoditySymbol: TestUtils.cad, decimalDigits: 3))
        ]
        guard case .valid = account.validateBalance(in: ledger) else {
            XCTFail("\(account) is not valid")
            print(account.validateBalance(in: ledger))
            return
        }
    }
    
    func testValidateInventoryEmpty() throws {
        let ledger = Ledger()
        let account = Account(name: TestUtils.cash, commoditySymbol: TestUtils.cad)
        try ledger.add(account)
        
        guard case .valid = account.validateInventory(in: ledger) else {
            XCTFail("\(account) is not valid")
            return
        }
    }
    
    func testValidateInventory() throws {
        let ledger = Ledger()
        let account = Account(name: TestUtils.cash, commoditySymbol: TestUtils.cad)
        try ledger.add(account)
        
        var posting = Posting(accountName: TestUtils.cash,
                              amount: Amount(number: 1.1, commoditySymbol: TestUtils.cad, decimalDigits: 1),
                              price: nil,
                              cost: try Cost(amount: Amount(number: 5, commoditySymbol: TestUtils.cad), date: nil, label: "1"))
        var transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170608, payee: "", narration: "", flag: .complete, tags: []), postings: [posting])
        ledger.add(transaction)
        
        posting = Posting(accountName: TestUtils.cash,
                          amount: Amount(number: 1.1, commoditySymbol: TestUtils.cad, decimalDigits: 1),
                          price: nil,
                          cost: try Cost(amount: Amount(number: 5, commoditySymbol: TestUtils.cad), date: nil, label: nil))
        transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170609, payee: "", narration: "", flag: .complete, tags: []), postings: [posting])
        ledger.add(transaction)
        
        posting = Posting(accountName: TestUtils.cash,
                          amount: Amount(number: -1, commoditySymbol: TestUtils.cad, decimalDigits: 0),
                          price: nil,
                          cost: try Cost(amount: Amount(number: 5, commoditySymbol: TestUtils.cad), date: nil, label: "1"))
        transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170609, payee: "", narration: "", flag: .complete, tags: []), postings: [posting])
        ledger.add(transaction)
        
        guard case .valid = account.validateInventory(in: ledger) else {
            XCTFail("\(account) is not valid")
            return
        }
    }
    
    func testValidateInvalidInventory() throws {
        let ledger = Ledger()
        let account = Account(name: TestUtils.cash, commoditySymbol: TestUtils.cad)
        let amount = Amount(number: 1.1, commoditySymbol: TestUtils.cad, decimalDigits: 1)
        let cost = try Cost(amount: Amount(number: 5, commoditySymbol: TestUtils.cad), date: nil, label: "1")
        try ledger.add(account)
        
        var posting = Posting(accountName: TestUtils.cash, amount: amount, price: nil, cost: cost)
        var transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170608, payee: "", narration: "", flag: .complete, tags: []), postings: [posting])
        ledger.add(transaction)
        
        posting = Posting(accountName: TestUtils.cash, amount: amount, price: nil, cost: cost)
        transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170609, payee: "", narration: "", flag: .complete, tags: []), postings: [posting])
        ledger.add(transaction)
        
        posting = Posting(accountName: TestUtils.cash,
                          amount: Amount(number: -1.0, commoditySymbol: TestUtils.cad, decimalDigits: 0),
                          price: nil,
                          cost: try Cost(amount: Amount(number: 5, commoditySymbol: TestUtils.cad), date: nil, label: nil))
        transaction = Transaction(metaData: TransactionMetaData(date: TestUtils.date20170610, payee: "", narration: "", flag: .complete, tags: []), postings: [posting])
        ledger.add(transaction)
        
        if case .invalid(let error) = account.validateInventory(in: ledger) {
            XCTAssertEqual(error, """
                    Ambigious Booking: -1 CAD {5 CAD}, matches: 1.1 CAD {2017-06-08, 5 CAD, "1"}
                    1.1 CAD {2017-06-09, 5 CAD, "1"}, inventory: 1.1 CAD {2017-06-08, 5 CAD, "1"}
                    1.1 CAD {2017-06-09, 5 CAD, "1"}
                    """)
        } else {
            XCTFail("\(account) is valid")
        }
    }
    
    func testEqualGroup() {
        let accgrp1 = AccountGroup(nameItem: "Chequing", accountType: .asset)
        let accgrp2 = AccountGroup(nameItem: "Chequing", accountType: .asset)
        
        XCTAssertEqual(accgrp1, accgrp2)
    }
    
    func testEqualName() {
        let account1 = Account(name: TestUtils.cash)
        let account2 = Account(name: TestUtils.chequing)
        XCTAssertNotEqual(account1, account2)
    }
    
    func testEqualProperties() {
        let date1 = TestUtils.date20170608
        let date2 = TestUtils.date20170609
        
        var account1 = Account(name: TestUtils.cash)
        var account2 = Account(name: TestUtils.cash)
        
        // equal
        XCTAssertEqual(account1, account2)
        
        account1 = Account(name: TestUtils.cash, commoditySymbol: TestUtils.eur, opening: date1, closing: date1)
        account2 = Account(name: TestUtils.cash, commoditySymbol: TestUtils.eur, opening: date1, closing: date1)
        
        // equal
        XCTAssertEqual(account1, account2)
        // different meta data
        account1 = Account(name: TestUtils.cash, commoditySymbol: TestUtils.eur, opening: date1, metaData: ["A": "B"])
        account2 = Account(name: TestUtils.cash, commoditySymbol: TestUtils.eur, opening: date1, metaData: ["A": "C"])
        XCTAssertNotEqual(account1, account2)
        // same meta data
        account2 = Account(name: TestUtils.cash, commoditySymbol: TestUtils.eur, opening: date1, metaData: ["A": "B"])
        XCTAssertEqual(account1, account2)
        // different commodity
        account1 = Account(name: TestUtils.cash, commoditySymbol: TestUtils.eur)
        account2 = Account(name: TestUtils.cash, commoditySymbol: TestUtils.cad)
        XCTAssertNotEqual(account1, account2)
        // different opening
        account1 = Account(name: TestUtils.cash, commoditySymbol: TestUtils.eur, opening: date1)
        account2 = Account(name: TestUtils.cash, commoditySymbol: TestUtils.eur, opening: date2)
        XCTAssertNotEqual(account1, account2)
        // different closing
        account2 = Account(name: TestUtils.cash, commoditySymbol: TestUtils.eur, opening: date2, closing: date2)
        XCTAssertNotEqual(account1, account2)
        account1 = Account(name: TestUtils.cash, commoditySymbol: TestUtils.eur, opening: date1, closing: date1)
        XCTAssertNotEqual(account1, account2)
    }
    
}
