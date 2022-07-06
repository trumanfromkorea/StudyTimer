//
//  WeeklyViewController.swift
//  StudyTimer
//
//  Created by 장재훈 on 2022/06/10.
//

import Charts
import Combine
import FirebaseAuth
import FirebaseFirestore
import UIKit

class WeeklyViewController: UIViewController {
    static let identifier = "WeeklyViewController"
    static let storyboard = "WeeklyView"

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var barChartView: BarChartView!

    @IBOutlet var collectionViewHeight: NSLayoutConstraint!

    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    var header: WeeklyHeader!
    var collectionIndex = 6

    typealias Item = StudyDetails
    enum Section {
        case main
    }

    var chartDataList = [StudyModel?]()
    var xAxisLabels: [String] = []
    var weekdays: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        barChartView.delegate = self

        barChartView.noDataText = "데이터가 없습니다."
        barChartView.noDataFont = .systemFont(ofSize: 20)
        barChartView.noDataTextColor = .lightGray
        collectionView.isScrollEnabled = false
        setWeekDays()
        getWeeklyData()
//        configureCollectionView()
//        setChart(dataPoints: xAxisLabels, values: chartDataList)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let height = collectionView.collectionViewLayout.collectionViewContentSize.height

        print(height)

        if height != CGFloat(0.0) {
            collectionViewHeight.constant = height
            view.layoutIfNeeded()
        }
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
}

extension WeeklyViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let index = Int(highlight.x) // index to Int
        collectionIndex = index

        header.configure(chartDataList[collectionIndex]!.dateString, chartDataList[collectionIndex]!.details.isEmpty)
        configureSnapshot()

        viewDidLayoutSubviews()
    }

    private func setChart(dataPoints: [String], values: [StudyModel?]) {
        // 데이터 생성
        var dataEntries: [BarChartDataEntry] = []

        for i in 0 ..< dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: Double(values[i]?.totalTime ?? 0) / 60)

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

extension WeeklyViewController {
    private func configureCollectionView() {
        // ui
        collectionView.showsVerticalScrollIndicator = false

        // dataSource
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeeklyCell.identifier, for: indexPath) as? WeeklyCell else {
                return nil
            }

            cell.configure(item)

            return cell
        })

        // header
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: WeeklyHeader.identifier, for: indexPath) as? WeeklyHeader else {
                    return UICollectionReusableView()
                }

                self.header = header

                self.header.configure(self.chartDataList[self.collectionIndex]!.dateString, self.chartDataList[self.collectionIndex]!.details.isEmpty)

                return self.header
            } else {
                return UICollectionReusableView()
            }
        }

        // snapshot
        configureSnapshot()

        // layout
        collectionView.collectionViewLayout = configureLayout()

        // scroll to top
        collectionView.setContentOffset(.zero, animated: true)
    }

    private func configureSnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(chartDataList[collectionIndex]?.details ?? [StudyDetails](), toSection: .main)
        dataSource.apply(snapshot)
    }

    // CollectionView Layout
    private func configureLayout() -> UICollectionViewCompositionalLayout {
        // item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)

        // section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0)
        section.interGroupSpacing = 10

        // header
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50.0))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        section.boundarySupplementaryItems = [header]

        return UICollectionViewCompositionalLayout(section: section)
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
                    self.chartDataList.append(
                        StudyModel(dateString: weekday, totalTime: 0, details: [])
                    )
                } else {
                    self.chartDataList += result
                }
            }

            self.configureCollectionView()
            self.setChart(dataPoints: self.xAxisLabels, values: self.chartDataList)
        }
    }
}
