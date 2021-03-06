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
    let minimumSeconds: Int = 0
    let maximumSeconds: Int = 3600 * 2
    let hourInterval = 3600

    var progressBarA: CircularProgressBarView!
    var progressBarB: CircularProgressBarView!
    var circularViewDuration: TimeInterval = 3600

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

        setProgressBarA()
        configureButtonState()
    }

    @IBAction func onTappedButton(_ sender: Any) {
        if timer != nil {
            seconds < minimumSeconds ? unreachedMinimumTime() : stopAlert()
        } else {
            startTimer()
            progressBarA.progressAnimation(duration: circularViewDuration)
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

    // 10분 이내 종료 시 기록 불가능
    func unreachedMinimumTime() {
        let sheet = UIAlertController(title: "정지", message: "10분 이내 종료 시 집중시간이 기록되지 않습니다. 정말로 종료하시겠습니까?", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "아니오", style: .default))
        sheet.addAction(UIAlertAction(title: "예", style: .default, handler: { _ in
            self.timer?.invalidate()
            self.navigationController?.popViewController(animated: true)
        }))

        present(sheet, animated: true)
    }

    func reachedMaximumTime() {
        let sheet = UIAlertController(title: "기록 종료", message: "1회 최대 기록시간인 2시간동안 집중하셨습니다. 고생했어요!", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
            self.navigateStopTimerView()
        }))

        present(sheet, animated: true)
    }

    @objc func onTimeFires() {
        seconds += 1
        setTimeLabel()

        if seconds == hourInterval {
            setProgressBarB()
        }

        if seconds == maximumSeconds {
            endTime = Date()
            timer?.invalidate()
            setTimeLabel()
            reachedMaximumTime()
        }
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

// MARK: - Progress Bar

extension TimerViewController {
    func setProgressBarA() {
        // set view
        progressBarA = CircularProgressBarView(frame: view.frame)
        progressBarA.createCircularPath(gradientColors: Theme.circularBarColor1, backLayerColor: UIColor.black.withAlphaComponent(0.9))
        // align to the center of the screen
        progressBarA.center = view.center
        // add this view to the view controller
        view.addSubview(progressBarA)
        view.bringSubviewToFront(timerButton)
    }

    func setProgressBarB() {
        // set view
        progressBarB = CircularProgressBarView(frame: view.frame)
        progressBarB.createCircularPath(gradientColors: Theme.circularBarColor2, backLayerColor: UIColor.black.withAlphaComponent(0))
        // align to the center of the screen
        progressBarB.center = view.center
        // call the animation with circularViewDuration
        progressBarB.progressAnimation(duration: circularViewDuration)
        // add this view to the view controller
        view.addSubview(progressBarB)
        view.bringSubviewToFront(timerButton)
    }
}
