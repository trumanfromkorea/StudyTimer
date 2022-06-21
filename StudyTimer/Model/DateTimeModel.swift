//
//  DateModel.swift
//  StudyTimer
//
//  Created by 장재훈 on 2022/06/10.
//

import Foundation

struct DateInfo {
    var dateString: String
    var studyTime: Double
}

struct TimeModel {
    static func getTimeStringFromSeconds(seconds: Int) -> String {
        
        let hour = seconds / 3600
        let min = (seconds % 3600) / 60
        
        let result = "\(min)분"
        return hour == 0 ? result : "\(hour)시간 \(result)"
    }

    static func getTimeFromSeconds(seconds: Int) -> String {
        let min = seconds / 60
        let sec = seconds % 60

        func getDigits(_ time: Int) -> String {
            return time < 10 ? "0\(time)" : "\(time)"
        }

        return getDigits(min) + ":" + getDigits(sec)
    }

    static func getSecondsFromTimeFormat(_ input: String) -> Int {
        let time = input.split(separator: ":").map { Int($0)! }
        let seconds = time[0] * 3600 + time[1] * 60 + time[2]
        return seconds
    }
}
