//
//  WeeklyHeader.swift
//  StudyTimer
//
//  Created by 장재훈 on 2022/06/24.
//

import Charts
import UIKit

protocol WeeklyHeaderDelegate: AnyObject {
    func changeIndex(index: Int)
}

class WeeklyHeader: UICollectionReusableView {
    static let identifier = "WeeklyHeader"

    @IBOutlet var barChartView: BarChartView!

    weak var delegate: WeeklyHeaderDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()

        barChartView.delegate = self

        barChartView.noDataText = "데이터가 없습니다."
        barChartView.noDataFont = .systemFont(ofSize: 20)
        barChartView.noDataTextColor = .lightGray
    }

    func setChart(dataPoints: [String], values: [StudyModel?]) {
        // 데이터 생성
        var dataEntries: [BarChartDataEntry] = []

        for i in 0 ..< dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]?.totalTime ?? 0))

            dataEntries.append(dataEntry)
        }

        let chartDataSet = BarChartDataSet(entries: dataEntries, label: "분")

        // 차트 컬러
        chartDataSet.colors = [Theme.mainColor]

        // 데이터 삽입
        let chartData = BarChartData(dataSet: chartDataSet)
        barChartView.data = chartData

        chartData.barWidth = Double(0.65)

        // 선택 안되게
//        chartDataSet.highlightEnabled = false
        // 줌 안되게
        barChartView.doubleTapToZoomEnabled = false

        barChartView.xAxis.drawGridLinesEnabled = false

        barChartView.leftAxis.gridColor = Theme.supplementColor1.withAlphaComponent(0.7)
        barChartView.leftAxis.drawAxisLineEnabled = false
        barChartView.leftAxis.drawLabelsEnabled = false

        // X축 레이블 위치 조정
        barChartView.xAxis.labelPosition = .bottom
        // X축 레이블 포맷 지정
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dataPoints)

        // X축 레이블 갯수 최대로 설정 (이 코드 안쓸 시 Jan Mar May 이런식으로 띄엄띄엄 조금만 나옴)
        barChartView.xAxis.setLabelCount(dataPoints.count, force: false)

        // 오른쪽 레이블 제거
        barChartView.rightAxis.enabled = false

        // 기본 애니메이션
        barChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0)
    }
}

extension WeeklyHeader: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let index = Int(highlight.x) // index to Int

        delegate?.changeIndex(index: index)
    }
}
