//
//  TimerViewController.swift
//  StudyTimer
//
//  Created by 장재훈 on 2022/06/07.
//

import UIKit

class TimerViewController: UIViewController {
    static let identifier = "TimerViewController"
    static let storyboard = "TimerView"

    var timer: Timer?
    var seconds: Int = 0

    var startTime: Date?
    var endTime: Date?
    var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "KR")
        formatter.dateFormat = "HH:mm:ss"

        return formatter
    }

    let enabledButtonColor = Theme.mainColor
    let disabledButtonColor = Theme.supplementColor2

    @IBOutlet var timerLabel: UILabel!
    @IBOutlet var timerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never

        configureButtonState()
    }

    @IBAction func onTappedButton(_ sender: Any) {
        if timer != nil {
            stopAlert()
        } else {
            startTimer()
        }
    }

    func configureButtonState() {
        timerButton.layer.cornerRadius = 15
        timerButton.backgroundColor = enabledButtonColor
    }

    func startTimer() {
        startTime = Date()
        navigationItem.hidesBackButton = true

        timerButton.setTitle("Stop", for: .normal)
        timerButton.backgroundColor = disabledButtonColor

        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(onTimeFires), userInfo: nil, repeats: true)
    }

    func stopAlert() {
        let sheet = UIAlertController(title: "정지", message: "정말 정지하시겠습니까?", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "아니오", style: .default))
        sheet.addAction(UIAlertAction(title: "예", style: .default, handler: { _ in
            self.endTime = Date()
            self.timer?.invalidate()
            self.setTimeLabel()
            self.navigateStopTimerView()
        }))

        present(sheet, animated: true)
    }

    @objc func onTimeFires() {
        seconds += 1
        setTimeLabel()
    }

    func setTimeLabel() {
        timerLabel.text = TimeModel.getTimeFromSeconds(seconds: seconds)
    }

    func navigateStopTimerView() {
        let storyboard = UIStoryboard(name: TimerViewController.storyboard, bundle: nil)

        let vc = storyboard.instantiateViewController(withIdentifier: StopTimerViewController.identifier) as! StopTimerViewController
        
        vc.studyTime = seconds
        vc.startTime = TimeModel.getSecondsFromTimeFormat(timeFormatter.string(from: startTime!))
        vc.endTime = TimeModel.getSecondsFromTimeFormat(timeFormatter.string(from: endTime!))

        navigationController?.pushViewController(vc, animated: true)
    }
}
