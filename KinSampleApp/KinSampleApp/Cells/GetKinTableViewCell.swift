//
//  GetKinTableViewCell.swift
//  KinSampleApp
//
//  Created by Kin Foundation
//  Copyright © 2017 Kin Foundation. All rights reserved.
//

import UIKit
import KinSDK

let GetKinSucceededOnce = "GetKinSucceededOnce"

class GetKinTableViewCell: KinClientCell {
    @IBOutlet weak var getKinButton: UIButton!

    override func tintColorDidChange() {
        super.tintColorDidChange()

        getKinButton.fill(with: tintColor)
    }

    override var kinClient: KinClient! {
        didSet {
            verifyGetKinButtonAvailability()
        }
    }

    @IBAction func getKinTapped(_ sender: Any) {
        kinClientCellDelegate?.getTestKin(cell: self)
    }

    func verifyGetKinButtonAvailability() {
        let gotKin = UserDefaults.standard.bool(forKey: GetKinSucceededOnce)
        let isTestNet = kinClient.networkId != NetworkIdMain

        getKinButton.isEnabled = isTestNet && !gotKin
    }
}
