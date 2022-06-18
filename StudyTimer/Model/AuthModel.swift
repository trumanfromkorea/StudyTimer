//
//  AuthModel.swift
//  StudyTimer
//
//  Created by 장재훈 on 2022/06/18.
//

import Foundation
import UIKit

// Root ViewController 설정 바꿔주는 메소드
class RootInfo {
    static let global = RootInfo()

    func rootToHomeView() -> HomeViewController {
        let mainStoryboard = UIStoryboard(name: HomeViewController.storyboard, bundle: nil)
        let protectedPage = mainStoryboard.instantiateViewController(withIdentifier: HomeViewController.identifier) as! HomeViewController
        return protectedPage
    }

    func rootToSignInView() -> SignInViewController {
        let mainStoryboard = UIStoryboard(name: SignInViewController.storyboard, bundle: nil)
        let protectedPage = mainStoryboard.instantiateViewController(withIdentifier: SignInViewController.identifier) as! SignInViewController
        return protectedPage
    }
    
    private init () {}
}
