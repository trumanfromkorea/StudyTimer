//
//  HomeViewController.swift
//  StudyTimer
//
//  Created by 장재훈 on 2022/06/08.
//

import FirebaseAuth
import FirebaseFirestore
import UIKit

class HomeViewController: UIViewController {
    static let identifier = "HomeViewController"
    static let storyboard = "HomeView"

    @IBOutlet var studyTimeView: UIView!
    @IBOutlet var studyTimeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet var weeklyView: UIView!
    @IBOutlet var calendarView: UIView!

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "YYYY-MM-dd"

        return formatter
    }
    
    var koreanDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko")
        formatter.dateFormat = "YYYY년 M월 d일 (eee)"
        return formatter
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        studyTimeLabel.text = " "
        studyTimeView.layer.cornerRadius = 10
        weeklyView.layer.cornerRadius = 10
        calendarView.layer.cornerRadius = 10
        
        dateLabel.text = koreanDateFormatter.string(from: Date())

        configureTouchEvents()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        getStudyTime()
    }

    @IBAction func onTappedRightBarButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: SettingsViewController.storyboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: SettingsViewController.identifier) as! SettingsViewController
        
        navigationController?.pushViewController(vc, animated: true)
    }

    private func configureTouchEvents() {
        let studyViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapStudyView))
        let weeklyViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapWeeklyView))
        let calendarViewTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapCalendarView))

        studyTimeView.addGestureRecognizer(studyViewTapGesture)
        weeklyView.addGestureRecognizer(weeklyViewTapGesture)
        calendarView.addGestureRecognizer(calendarViewTapGesture)
    }

    @objc private func handleTapStudyView() {
        let storyboard = UIStoryboard(name: TimerViewController.storyboard, bundle: nil)

        let vc = storyboard.instantiateViewController(withIdentifier: TimerViewController.identifier) as! TimerViewController
        vc.title = "Timer"

        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func handleTapWeeklyView() {
        let storyboard = UIStoryboard(name: WeeklyViewController.storyboard, bundle: nil)

        let vc = storyboard.instantiateViewController(withIdentifier: WeeklyViewController.identifier) as! WeeklyViewController

        vc.title = "Weekly View"

        navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func handleTapCalendarView() {
        let storyboard = UIStoryboard(name: CalendarViewController.storyboard, bundle: nil)

        let vc = storyboard.instantiateViewController(withIdentifier: CalendarViewController.identifier) as! CalendarViewController

        vc.title = "Calendar View"

        navigationController?.pushViewController(vc, animated: true)
    }
}

extension HomeViewController {
    private func getStudyTime() {
        let db = Firestore.firestore()
        let uid = Auth.auth().currentUser!.uid
        let dateString = dateFormatter.string(from: Date())

        db.collection("users").document(uid)
            .collection("studies").document(dateString).getDocument { document, _ in
                if let document = document, document.exists {
                    let studyTime = document.data()!["totalTime"]! as! Int
                    self.studyTimeLabel.text = TimeModel.getTimeStringFromSeconds(seconds: studyTime)
                } else {
                    print("no studyTime")
                }
            }
    }
}
