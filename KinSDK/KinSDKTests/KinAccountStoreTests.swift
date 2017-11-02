//
//  KinAccountStoreTests.swift
//  KinWalletTests
//
//  Created by Elazar Yifrach on 19/10/2017.
//  Copyright © 2017 Kik Interactive. All rights reserved.
//

import XCTest
import Geth

// todo add to readme https://github.com/ethereum/go-ethereum/issues/14369#issuecomment-318823725
class KinAccountStoreTests: XCTestCase {

    static let url = URL(string:"https://ropsten.infura.io/ciS27F9JQYk8MaJd8Fbu")!
    static let networkId: Int64 = 3

    let store = KinAccountStore(url: KinAccountStoreTests.url, networkId: 3)
    let creationPass = UUID().uuidString
    let exportPass = UUID().uuidString
    var account: GethAccount!

    
    override func setUp() {
        account = try! store.createAccount(passphrase: creationPass)
    }
    
    override func tearDown() {
        super.tearDown()

        let accountStore = KinAccountStore(url: KinAccountStoreTests.url,
                                           networkId: KinAccountStoreTests.networkId)
        try? accountStore.deleteKeystore()
    }
    
    func testKeyStoreCreated() {
        XCTAssertNotNil(store)
    }
    
    func testCreateAccount() {
        XCTAssertTrue(account.isKind(of: GethAccount.self))
    }
    
    func testDeleteWithBadPassFailes() {
        do {
            try store.delete(account: account, passphrase: "HiImWrongPass")
            XCTAssertTrue(false, "A delete should fail if using worng password")
        }
        catch {
            XCTAssertTrue(true, "A delete should fail if using worng password")
        }
    }
    
    func testUpdateAccoun() {
        let newPass = UUID().uuidString
        var result = store.update(account: account, passphrase: creationPass,
                                  newPassphrase: newPass)
        XCTAssertTrue(result, "Failed updating account with creation password")
        result = store.update(account: account, passphrase: creationPass,
                              newPassphrase: newPass)
        XCTAssertFalse(result, "Account should not be able to open with old password")
        result = store.update(account: account, passphrase: newPass,
                              newPassphrase: "nevermind")
        XCTAssertTrue(result, "Account should have been accessible with new password")
        // just letting teardown delete this account
        _ = store.update(account: account, passphrase: "nevermind",
                         newPassphrase: creationPass)
    }
    
    func testExportDeleteAndImportAccount() {
        
        let numberOfStores = store.accounts.size()
        XCTAssertTrue(numberOfStores > 0, "Number of files at test's start should be at least 1, Check setup func.")
        let data = try? store.export(account: account,
                                     passphrase: creationPass,
                                     exportPassphrase: creationPass)
        XCTAssertTrue(data != nil, "Account failed to export")

        do {
            try store.delete(account: account, passphrase: creationPass)

            XCTAssertTrue(store.accounts.size() == numberOfStores - 1)
            _ = store.importAccount(keystoreData: data!, passphrase: creationPass,
                                    newPassphrase: creationPass)
            XCTAssertTrue(store.accounts.size() == numberOfStores)
        }
        catch {
            XCTAssertTrue(false, "Unable to delete account: \(error)")
        }
    }
    
    func testCreateTransaction() {
        let toAddress = "0x818fc6c2ec5986bc6e2cbf00939d90556ab12ce5"
        let transaction = store.createTransactionETH(from: account, amount: 10,
                                                  to: GethNewAddressFromHex(toAddress,
                                                                            nil))
        XCTAssertNotNil(transaction)
    }
    
    func testSignTransactionsETH() {
        let toAddress = "0x818fc6c2ec5986bc6e2cbf00939d90556ab12ce5"
        var transaction = store.createTransactionETH(from: account, amount: 10,
                                                  to: GethNewAddressFromHex(toAddress,
                                                                            nil))
        XCTAssertNotNil(transaction)
        var signedTransaction = store.signTransactionETH(from: account,
                                                      transaction: transaction!,
                                                      passphrase: creationPass)
        XCTAssertNotNil(signedTransaction, "Failed to sign a transaction")
        
        transaction = store.createTransactionETH(from: account, amount: 10,
                                                  to: GethNewAddressFromHex(toAddress,
                                                                            nil))
        XCTAssertNotNil(transaction)
        signedTransaction = store.signTransactionETH(from: account,
                                                      transaction: transaction!,
                                                      passphrase: "notThePassphrase")
        XCTAssertNil(signedTransaction, "Somehow signed a transaction with wrong password")
    }
    
}
