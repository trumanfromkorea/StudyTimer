//
//  WeeklyViewController.swift
//  StudyTimer
//
//  Created by 장재훈 on 2022/06/10.
//

import Charts
import FirebaseAuth
import FirebaseFirestore
import UIKit

class WeeklyViewController: UIViewController {
    static let identifier = "WeeklyViewController"
    static let storyboard = "WeeklyView"

    @IBOutlet var barChartView: BarChartView!

    var chartDataList = [StudyModel?]()
    var xAxisLabels: [String] = []
    var weekdays: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setWeekDays()
        getWeeklyData()

        barChartView.delegate = self

        barChartView.noDataText = "데이터가 없습니다."
        barChartView.noDataFont = .systemFont(ofSize: 20)
        barChartView.noDataTextColor = .lightGray
    }

    func setWeekDays() {
        let today = DateModel.KST

        let startDate = Calendar.current.date(byAdding: .day, value: -6, to: today)!

        for i in 0 ..< 7 {
            let incrementDate = Calendar.current.date(byAdding: .day, value: i, to: startDate)
            weekdays.append(DateModel.commonFormatter.string(from: incrementDate!))
            xAxisLabels.append(DateModel.monthDayFormatter.string(from: incrementDate!))
        }
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
        // 가로선 없애기
        barChartView.xAxis.drawGridLinesEnabled = false

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

extension WeeklyViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let index = Int(highlight.x) // index to Int
        
        print(chartDataList[index])
    }
}

extension WeeklyViewController {
    func getWeeklyData() {
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser!.uid

        db.collection("users").document(uid).collection("studies").order(by: .documentID()).limit(to: 7).getDocuments { snapshot, error in
            if let error = error {
                print("get weekly data error: \(error)")
                return
            }

            let decoder = JSONDecoder()
            var dataList = [StudyModel]()

            snapshot?.documents.forEach({ document in
                do {
                    let jsonData = try? JSONSerialization.data(withJSONObject: document.data())
                    let decodedData = try decoder.decode(StudyModel.self, from: jsonData!)

                    if self.weekdays.contains(decodedData.dateString) {
                        dataList.append(decodedData)
                    }

                } catch {
                }
            })

            for weekday in self.weekdays {
                let result = dataList.filter { data in
                    data.dateString == weekday
                }

                if result.isEmpty {
                    self.chartDataList.append(nil)
                } else {
                    self.chartDataList += result
                }
            }

            self.setChart(dataPoints: self.xAxisLabels, values: self.chartDataList)
        }
    }
}
