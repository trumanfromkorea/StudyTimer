//
//  SignInViewController.swift
//  StudyTimer
//
//  Created by 장재훈 on 2022/06/16.
//

import FirebaseAuth
import UIKit

class SignInViewController: UIViewController {
    static let identifier = "SignInViewController"
    static let storyboard = "AuthView"

    let invalidPassword = "The password is invalid or the user does not have a password."
    let invalidUser = "There is no user record corresponding to this identifier. The user may have been deleted."

    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var signInButton: UIButton!
    @IBOutlet var signUpButton: UIButton!

    @IBOutlet var confirmEmailLabel: UILabel!
    @IBOutlet var confirmPasswordLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.tintColor = Theme.mainColor
        signUpButton.tintColor = Theme.mainColor

        confirmEmailLabel.text = " "
        confirmPasswordLabel.text = " "
    }

    @IBAction func onTappedSignInButton(_ sender: Any) {
        trySignIn()
    }

    @IBAction func onTappedSignUpButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: SignUpViewController.storyboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: SignUpViewController.identifier) as! SignUpViewController

        present(vc, animated: true)
    }

    private func trySignIn() {
        confirmEmailLabel.text = " "
        confirmPasswordLabel.text = " "

        if !Validation.email(emailField.text) {
            confirmEmailLabel.text = "이메일 형식이 올바르지 않습니다"
        } else if !Validation.password(passwordField.text) {
            confirmPasswordLabel.text = "비밀번호는 8자리 이상 영어, 숫자 조합입니다"
        } else {
            Auth.auth().signIn(withEmail: emailField.text!, password: passwordField.text!) { _, error in
                if let error = error {
                    print(">> FB Sign In Error : \(error)")
                    
                    if error.localizedDescription == self.invalidUser {
                        self.confirmEmailLabel.text = "존재하지 않거나 탈퇴한 사용자입니다"
                    } else if error.localizedDescription == self.invalidPassword {
                        self.confirmPasswordLabel.text = "잘못된 비밀번호입니다"
                    }

                    return
                }

                // home view 로 root 재설정
                let window = self.view.window
                let protectedPage = RootInfo.global.rootToHomeView()
                let vc = UINavigationController(rootViewController: protectedPage)
                window?.rootViewController = vc
                window?.makeKeyAndVisible()
            }
        }
    }
}
