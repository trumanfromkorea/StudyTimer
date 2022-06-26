//
//  WeeklyHeader.swift
//  StudyTimer
//
//  Created by 장재훈 on 2022/06/24.
//

import Charts
import UIKit

class WeeklyHeader: UICollectionReusableView {
    static let identifier = "WeeklyHeader"

    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var isEmptyLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(_ dateString: String, _ isEmpty: Bool) {
        let date = DateModel.commonFormatter.date(from: dateString)!
        dateLabel.text = DateModel.koreanMonthDayFormatter.string(from: date) + " 의 집중시간"

        isEmptyLabel.text = isEmpty ? "해당 날짜의 집중시간이 존재하지 않습니다." : " "
    }
}
