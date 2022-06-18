//
//  SignUpViewController.swift
//  StudyTimer
//
//  Created by 장재훈 on 2022/06/16.
//

import FirebaseAuth
import FirebaseFirestore
import UIKit

class SignUpViewController: UIViewController {
    static let identifier = "SignUpViewController"
    static let storyboard = "AuthView"

    var handle: AuthStateDidChangeListenerHandle?

    @IBOutlet var userNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var confirmPasswordField: UITextField!

    @IBOutlet var confirmUserNameLabel: UILabel!
    @IBOutlet var confirmEmailLabel: UILabel!
    @IBOutlet var confirmPasswordLabel: UILabel!

    @IBOutlet var signUpButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        confirmUserNameLabel.text = " "
        confirmEmailLabel.text = " "
        confirmPasswordLabel.text = " "

        signUpButton.tintColor = Theme.mainColor

        addListener()
    }

    @IBAction func onTappedDoneButton(_ sender: Any) {
        trySignUp()
    }

    // 입력 항목 유효성검사 listener
    @objc func userNameFieldListener(_ sender: Any?) {
        if userNameField.text!.count > 8 {
            confirmUserNameLabel.text = "이름은 최대 8자 입니다"
        } else {
            confirmUserNameLabel.text = " "
        }
    }

    @objc func emailFieldListener(_ sender: Any?) {
        if !Validation.email(emailField.text) {
            confirmEmailLabel.text = "이메일 형식이 올바르지 않습니다"
        } else {
            confirmEmailLabel.text = " "
        }
    }

    @objc func passwordFieldListener(_ sender: Any?) {
        if passwordField.text != confirmPasswordField.text {
            confirmPasswordLabel.text = "비밀번호가 일치하지 않습니다"
        } else {
            confirmPasswordLabel.text = " "
        }
    }

    private func addListener() {
        userNameField.addTarget(self, action: #selector(userNameFieldListener(_:)), for: .editingChanged)
        emailField.addTarget(self, action: #selector(emailFieldListener(_:)), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(passwordFieldListener(_:)), for: .editingChanged)
        confirmPasswordField.addTarget(self, action: #selector(passwordFieldListener(_:)), for: .editingChanged)
    }

    // 입력항목 유효성 검사 후 alert
    // or 회원가입 시도
    private func trySignUp() {
        if userNameField.text == nil
            || userNameField.text!.isEmpty
            || userNameField.text!.count > 8
            || !Validation.email(emailField.text)
            || !Validation.password(passwordField.text)
            || passwordField.text != confirmPasswordField.text {
            failureAlert()
            return
        }

        // 회원가입
        Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!) { result, error in
            if let error = error {
                print(">> FB Sign Up Error : \(error)")
                return
            }

            // FireStore 에 저장하기
            self.addUserInfoToFireStore(result)

            // UserDefaults 에 저장하기
            UserDefaults.standard.set(self.userNameField!.text!, forKey: "userName")
            UserDefaults.standard.set(result!.user.email!, forKey: "userEmail")
            
            // 완료 팝업
            self.signUpCompleteAlert()

            print("회원가입 성공")
        }
    }

    private func addUserInfoToFireStore(_ result: AuthDataResult?) {
        let db = Firestore.firestore()
        let params: [String: String] = [
            "userName": userNameField!.text!,
            "userEmail": result!.user.email!,
            "uid": result!.user.uid,
        ]

        db.collection("users")
            .document(result!.user.uid)
            .setData(params) { error in
                if let error = error {
                    print(">> Add User Firestore Error : \(error)")
                } else {
                    print("Add User")
                }
            }
    }

    private func failureAlert() {
        let sheet = UIAlertController(title: "회원가입 실패", message: "입력 항목을 다시 한번 확인해주세요.", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "뒤로", style: .default))
        present(sheet, animated: true)
    }
    
    private func signUpCompleteAlert() {
        let sheet = UIAlertController(title: "회원가입 완료", message: "회원가입이 완료되었습니다! 로그인을 진행해주세요.", preferredStyle: .alert)
        sheet.addAction(UIAlertAction(title: "확인", style: .default){ _ in
            self.dismiss(animated: true)
        })
        present(sheet, animated: true)
    }
}
