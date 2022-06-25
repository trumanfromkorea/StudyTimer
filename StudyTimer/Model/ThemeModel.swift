//
//  File.swift
//  StudyTimer
//
//  Created by 장재훈 on 2022/06/10.
//

import Foundation
import UIKit

struct Theme {
    static let mainColor = UIColor(hex: "#556EE6")
    static let supplementColor1 = UIColor(hex: "#778BEB")
    static let supplementColor2 = UIColor(hex: "#9DA9E3")
    static let supplementColor3 = UIColor(hex: "#5874FF")
    static let darkColor1 = UIColor(hex: "#2d47cc")

    static let circularBarColor1 = [Theme.darkColor1, Theme.supplementColor1, Theme.supplementColor2, Theme.mainColor, Theme.mainColor, Theme.darkColor1]
    static let circularBarColor2 = [UIColor.yellow, UIColor.orange, UIColor.red, UIColor.orange, UIColor.yellow]
}
