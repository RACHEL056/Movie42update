//
//  MovieListVC.swift
//  Movie42_MVVM
//
//  Created by Bae on 1/17/24.
//

import UIKit

//영화 탭바 뷰 reference로 연결하는 화면
class MovieTabViewController : UITabBarController, UITabBarControllerDelegate {
    
    //private let mypage = MyPageViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //원하는 index 설정
        self.selectedIndex = 0
        self.delegate = self
    
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if let selectedViewController = viewController as? MyPageViewController {
            handleTabSelection(selectedViewController)
        }
    }
    
    func handleTabSelection(_ myPageViewController: MyPageViewController) {
        //mypage.movieTV.reloadData()
        print(#function)
        myPageViewController.movieTV.reloadData()
    }
}
