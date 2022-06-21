//
//  SettingsViewController.swift
//  StudyTimer
//
//  Created by 장재훈 on 2022/06/22.
//

import FirebaseAuth
import UIKit

class SettingsViewController: UIViewController {
    static let identifier = "SettingsViewController"
    static let storyboard = "SettingsView"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func onTappedSignOutButton(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            let window = self.view.window
            let protectedPage = RootInfo.global.rootToSignInView()
            let vc = UINavigationController(rootViewController: protectedPage)
            window?.rootViewController = vc
            window?.makeKeyAndVisible()
        } catch {}
    }
}
