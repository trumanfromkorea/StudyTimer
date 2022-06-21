//
//  StopTimerViewController.swift
//  StudyTimer
//
//  Created by 장재훈 on 2022/06/09.
//

import FirebaseAuth
import FirebaseFirestore
import UIKit

class StopTimerViewController: UIViewController {
    static let identifier = "StopTimerViewController"
    static let storyboard = "StopTimerView"

    let ratingList = ["😞", "😊", "😆"]

    var ratingIndex: Int?
    var studyTime = 0
    var startTime = 0
    var endTime = 0
    var studyContents = ""

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "KR")
        formatter.dateFormat = "YYYY-MM-dd"

        return formatter
    }

    var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
    typealias Item = String
    enum Section {
        case main
    }

    @IBOutlet var studyTimeLabel: UILabel!
    @IBOutlet var studyContentsTextView: UITextField!
    @IBOutlet var fromListButton: UIButton!
    @IBOutlet var ratingCollectionView: UICollectionView!
    @IBOutlet var studyContentsField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        ratingCollectionView.delegate = self

        configureStates()
        configureCollectionView()
    }

    @IBAction func onTappedFromList(_ sender: Any) {
        print("목록에서 선택하기")
    }

    @IBAction func onTappedDoneButton(_ sender: Any) {
        if studyContentsField.text == nil || ratingIndex == nil {
            print("미입력 항목 있음")
            return
        }
        if endTime < startTime {
            whenDateIsDifferent()
        } else {
            let dateString = dateFormatter.string(from: Date())
            storeStudyInfo(dateString: dateString, startTime: startTime, endTime: endTime, studyTime: studyTime, showPopup: true)
        }
    }

    // 날짜 넘어가는 부분
    private func whenDateIsDifferent() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())
        let dateA = dateFormatter.string(from: yesterday!)
        let dateB = dateFormatter.string(from: Date())

        let startTimeA = startTime
        let endTimeA = 86399
        let studyTimeA = endTimeA - startTimeA

        let startTimeB = 0
        let endTimeB = endTime
        let studyTimeB = endTime

        storeStudyInfo(dateString: dateA, startTime: startTimeA, endTime: endTimeA, studyTime: studyTimeA, showPopup: false)
        storeStudyInfo(dateString: dateB, startTime: startTimeB, endTime: endTimeB, studyTime: studyTimeB, showPopup: true)
    }

    private func storeStudyInfo(dateString: String, startTime: Int, endTime: Int, studyTime: Int, showPopup: Bool) {
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser!.uid

        db.collection("users").document(uid)
            .collection("studies").document(dateString).getDocument { document, _ in

                let details: Array<Any> = [[
                    "contents": self.studyContentsField.text!,
                    "startTime": startTime,
                    "endTime": endTime,
                    "studyTime": studyTime,
                    "rating": self.ratingIndex!,
                ]]

                if let document = document, document.exists {
                    document.reference.updateData([
                        "totalTime": FieldValue.increment(Int64(studyTime)),
                        "details": FieldValue.arrayUnion(details),
                    ]) { error in
                        if error != nil {
                            print("Firestore error : \(String(describing: error))")
                            return
                        }
                        if showPopup { self.completePopUp() }
                    }
                } else {
                    document?.reference.setData([
                        "totalTime": studyTime,
                        "details": details,
                    ]) { error in
                        if error != nil {
                            print("Firestore error : \(String(describing: error))")
                            return
                        }
                        if showPopup { self.completePopUp() }
                    }
                }
            }

    }

    private func completePopUp() {
        let sheet = UIAlertController(title: "완료", message: "정말 고생했어요!", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            self.popToHomeView()
        }))
        present(sheet, animated: true)
    }

    private func popToHomeView() {
        let viewControllers: [UIViewController] = navigationController!.viewControllers as [UIViewController]

        navigationController?.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }

    private func configureStates() {
        navigationItem.hidesBackButton = true

        fromListButton.layer.cornerRadius = 15
        fromListButton.backgroundColor = Theme.supplementColor2.withAlphaComponent(0.5)
        fromListButton.titleLabel?.textColor = Theme.mainColor
        fromListButton.tintColor = Theme.mainColor

        studyTimeLabel.text = TimeModel.getTimeFromSeconds(seconds: studyTime)
    }
}

extension StopTimerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ratingIndex = indexPath.item
    }

    private func configureCollectionView() {
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: ratingCollectionView, cellProvider: { _, indexPath, itemIdentifier in
            guard let cell = self.ratingCollectionView.dequeueReusableCell(withReuseIdentifier: RatingCell.identifier, for: indexPath) as? RatingCell else {
                return nil
            }
            cell.configure(itemIdentifier)
            return cell
        })

        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections([.main])
        snapshot.appendItems(ratingList, toSection: .main)
        dataSource.apply(snapshot)

        ratingCollectionView.collectionViewLayout = layout()
    }

    private func layout() -> UICollectionViewCompositionalLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(0.33))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)

        let section = NSCollectionLayoutSection(group: group)

        let layout = UICollectionViewCompositionalLayout(section: section)

        return layout
    }
}
