//
//  Date+Convenient.swift
//  ifanr
//
//  Created by luhe liu on 2018/6/25.
//  Copyright © 2018年 com.ifanr. All rights reserved.
//

import Foundation

public extension Date {
    
    public enum TimeScale {
        case secondsAgo(Int)
        case minutesAgo(Int)
        case hoursAgo(Int)
        case daysAgo(Int)
        case weeksAgo(Int)
        case monthAgo(Int)
        case yearsAgo(Int)
    }
    
    public func calculateTimeScale() -> Date.TimeScale {
        let now = Date()
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: now)
        if let year = dateComponents.year, year > 0 {
            return .yearsAgo(year)
        } else if let month = dateComponents.month, month > 0 {
            return .monthAgo(month)
        } else if let day = dateComponents.day, day > 0 {
            let week = day / 7
            if week > 0 {
                return .weeksAgo(week)
            }
            return .daysAgo(day)
        } else if let hour = dateComponents.hour, hour > 0 {
            return .hoursAgo(hour)
        } else if let minute = dateComponents.minute, minute > 0 {
            return .minutesAgo(minute)
        } else if let second = dateComponents.second, second > 0 {
            return .secondsAgo(second)
        }
        return .secondsAgo(0)
    }
}
