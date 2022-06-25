//
//  StudyModel.swift
//  StudyTimer
//
//  Created by 장재훈 on 2022/06/22.
//

import Foundation

struct StudyModel: Codable {
    var dateString: String
    var totalTime: Int
    var details: [StudyDetails]
}

struct StudyDetails: Codable, Hashable {
    var contents: String
    var startTime: Int
    var endTime: Int
    var studyTime: Int
    var rating: Int

    func secondsToTime(_ seconds: Int) -> String {
        var result = ""
        
        let hour = seconds / 3600
        let min = (seconds % 3600) / 60
        
        result += hour < 10 ? "0\(hour):" : "\(hour):"
        result += min < 10 ? "0\(min)" : "\(min)"

        return result
    }
    
    func periodString() -> String {
        let start = secondsToTime(startTime)
        let end = secondsToTime(endTime)
        
        return "\(start) ~ \(end)"
    }
}
