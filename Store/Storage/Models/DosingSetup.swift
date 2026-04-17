//
//  DosingSetup.swift
//  Store
//

import Foundation

enum DosingFrequency: Int, CaseIterable, Identifiable {
    case once = 1
    case twice = 2
    case sixTimes = 6
    case twelveTimes = 12
    case twentyFourTimes = 24

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .once: return "1x / day"
        case .twice: return "2x / day"
        case .sixTimes: return "6x / day"
        case .twelveTimes: return "12x / day"
        case .twentyFourTimes: return "24x / day"
        }
    }
}

struct DosingSetup {
    var frequency: DosingFrequency = .once
    var startTime: Date = Calendar.current.startOfDay(for: Date())
    var autoDosingEnabled: Bool = false
    var maxDosingMl: Double = 0.01
}
