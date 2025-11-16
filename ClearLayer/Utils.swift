//
//  Utils.swift
//  ClearLayer
//
//  Created by 中里祐希 on 2025/10/05.
//

import Foundation

extension Bundle {
    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }
}
