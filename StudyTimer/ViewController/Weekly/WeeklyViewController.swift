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
    var collectionIndex = 6
    
    let sampleData = [
        [1],
        [1,2],
        [1,2,3],
        [1,2,3,4],
        [1,2,3,4,5],
        [1,2,3,4,5,6],
        [1,2,3,4,5,6,7]
    ]

    typealias Item = Int
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
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView, cellProvider: { collectionView, indexPath, _ in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeeklyCell.identifier, for: indexPath) as? WeeklyCell else {
                return nil
            }

            return cell
        })

        // header
        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            if kind == UICollectionView.elementKindSectionHeader {
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: WeeklyHeader.identifier, for: indexPath) as? WeeklyHeader else {
                    return UICollectionReusableView()
                }

                header.setChart(dataPoints: self.xAxisLabels, values: self.chartDataList)
                header.delegate = self

                return header
            } else {
                return UICollectionReusableView()
            }
        }

        // snapshot
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(sampleData[collectionIndex], toSection: .main)
        dataSource.apply(snapshot)

        // layout
        collectionView.collectionViewLayout = configureLayout()
    }

    // CollectionView Layout
    private func configureLayout() -> UICollectionViewCompositionalLayout {
        // item
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let itemSpacing: CGFloat = 5
        item.contentInsets = NSDirectionalEdgeInsets(top: itemSpacing, leading: itemSpacing, bottom: itemSpacing, trailing: itemSpacing)

        // group
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.5))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)

        // section
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 20, trailing: 0)

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
                    self.chartDataList.append(nil)
                } else {
                    self.chartDataList += result
                }
            }

            self.configureCollectionView()
//            self.setChart(dataPoints: self.xAxisLabels, values: self.chartDataList)
        }
    }
}


extension WeeklyViewController: WeeklyHeaderDelegate {
    func changeIndex(index: Int) {
        print(index)
        collectionIndex = index

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(sampleData[index], toSection: .main)
        dataSource.apply(snapshot)
    }
}
