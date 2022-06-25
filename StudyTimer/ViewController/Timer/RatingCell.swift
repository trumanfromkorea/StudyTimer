//
//  RatingCell.swift
//  StudyTimer
//
//  Created by 장재훈 on 2022/06/11.
//

import UIKit

class RatingCell: UICollectionViewCell {
    static let identifier = "RatingCell"

    @IBOutlet var ratingImageView: UIImageView!

    override var isSelected: Bool {
        didSet {
            if isSelected {
                contentView.backgroundColor = UIColor(hex: "#dedede")
            } else {
                contentView.backgroundColor = .white
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(_ imageName: String, _ width: CGFloat) {
        ratingImageView.image = UIImage(named: imageName)
        layer.cornerRadius = width / 2
    }
}
