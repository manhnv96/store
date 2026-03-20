//
//  CodableKey.swift
//  LunarCalendar
//
//  Created by Mạnh Nguyễn Văn on 8/9/24.
//  Copyright © 2024 Manh Nguyen Van. All rights reserved.
//

import Foundation

struct CodableKey: CodingKey {
    var intValue: Int?
    var stringValue: String
    
    init(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        self.intValue = intValue
        stringValue = String(intValue)
    }
}
