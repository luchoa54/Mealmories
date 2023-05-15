//
//  UserDefaults+withConfigType.swift
//  Mealmories
//
//  Created by Luciano Uchoa on 11/10/22.
//

import Foundation
import UIKit

extension UserDefaults {
    func bool (forConfigKey configKey: ConfigKey) -> Bool {
        return self.bool(forKey: configKey.rawValue)
    }
    
    func set(_ value: Any?, forConfigKey configKey: ConfigKey){
        self.set(value, forKey: configKey.rawValue)
    }
}
