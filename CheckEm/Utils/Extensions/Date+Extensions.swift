//
//  Date+Extensions.swift
//  CheckEm
//
//  Created by Jacob Bartlett on 24/01/2024.
//

import Foundation

extension Date {
    
    var timeLeftInThirtySeconds: TimeInterval {
        abs(30 - self.roundedDownToNearestThirtySeconds.timeIntervalSince(self))
    }
    
    var roundedDownToNearestThirtySeconds: Date {
        let startOfMinute = Calendar.current.dateInterval(of: .minute, for: self)?.start ?? self
        let thirtySeconds = TimeInterval(30)
        if self.timeIntervalSince(startOfMinute) < thirtySeconds {
            return startOfMinute
        } else {
            return startOfMinute.addingTimeInterval(thirtySeconds)
        }
    }
}

final class Formatters {
    
    static let shared = Formatters()
    
    private init() { }
    
    lazy var fullDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        df.dateFormat = "EEE d MMM h:mm:ss aa"
        return df
    }()
}
