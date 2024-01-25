//
//  MovieListVM.swift
//  Movie42_MVVM
//
//  Created by 박민정 on 1/25/24.
//

import UIKit

class MovieListViewModel {
    //테이블 뷰 업데이트 위한 클로저 타입 프로퍼티
    var updateList: (() -> Void)?
    
    //전체 리스트 저장하는 배열
    var allList: [Reservation] = [] {
        didSet {
            updateList?()
        }
    }
    
    //초기화
    init() {
        //페이지 진입 시 유저의 reservation 정보 가져옴
        fetchList(with: UserDefaultManager.shared.getLoggedInUser()!)
    }
    
    //로그인한 유저의 예약 목록을 가져와서 배열에 넣는 함수
    func fetchList(with user: User) {
        self.allList = Array(UserDefaultManager.shared.getLoggedInUser()!.reservations)
    }
}
