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

struct StudyDetails: Codable {
    var contents: String
    var startTime: Int
    var endTime: Int
    var studyTime: Int
    var rating: Int
}
