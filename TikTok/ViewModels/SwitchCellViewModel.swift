//
//  SwitchCellViewModel.swift
//  TikTok
//
//  Created by mnash29 on 12/18/23.
//

import Foundation

struct SwitchCellViewModel {
    let title: String
    var isOn: Bool

    mutating func setOn(_ on: Bool) {
        self.isOn = on
    }
}
