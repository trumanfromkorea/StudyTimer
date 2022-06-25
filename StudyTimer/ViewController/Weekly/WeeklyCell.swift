//
//  WeeklyCell.swift
//  StudyTimer
//
//  Created by 장재훈 on 2022/06/23.
//

import UIKit

class WeeklyCell: UICollectionViewCell {
    static let identifier = "WeeklyCell"

    @IBOutlet var contents: UILabel!
    @IBOutlet var contentsLabel: UILabel!
    @IBOutlet var studyTime: UILabel!
    @IBOutlet var studyTimeLabel: UILabel!
    @IBOutlet var studyPeriodLabel: UILabel!
    @IBOutlet var ratingImage: UIImageView!

    @IBOutlet var stackView: UIStackView!

    override func awakeFromNib() {
        layer.cornerRadius = 10
        
        stackView.setCustomSpacing(5, after: contents)
        stackView.setCustomSpacing(15, after: contentsLabel)
        stackView.setCustomSpacing(5, after: studyTime)
        stackView.setCustomSpacing(5, after: studyTimeLabel)
    }

    func configure(_ item: StudyDetails) {
        contentsLabel.text = item.contents
        studyTimeLabel.text = TimeModel.getTimeStringFromSeconds(seconds: item.studyTime)
        studyPeriodLabel.text = item.periodString()
        ratingImage.image = UIImage(named: "rating_\(item.rating)")
    }
}
