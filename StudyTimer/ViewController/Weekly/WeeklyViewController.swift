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

        setWeekDays()
        getWeeklyData()
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
                self.header.setChart(dataPoints: self.xAxisLabels, values: self.chartDataList)
                self.header.delegate = self

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
        }
    }
}

extension WeeklyViewController: WeeklyHeaderDelegate {
    func changeIndex(index: Int) {
        collectionIndex = index

        header.configure(chartDataList[collectionIndex]!.dateString, chartDataList[collectionIndex]!.details.isEmpty)
        // snapshot
        configureSnapshot()
    }
}
