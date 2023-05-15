//
//  Localize+Extension.swift
//  Challenge04LGBB
//
//  Created by Luciano Uchoa on 09/09/22.
//

import Foundation

extension String {
    func localize() -> String {
        return NSLocalizedString(
            self,
            tableName: "Localizable",
            bundle: .main,
            value: self,
            comment: self)
    }
}
