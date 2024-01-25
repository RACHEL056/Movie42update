import UIKit

class MyPageViewModel {
    var change: ObservableObject<String?> = ObservableObject("Nothing Changed")
    var update: ObservableObject<String?> = ObservableObject("Nothing to Update")
    
    //사용자 정보 관련 유저 업데이트 함수
    func updateUser(newID: String, newNickname: String) {
        if var loggedInUser = UserDefaultManager.shared.getLoggedInUser() {
            // 기존 값 유지하면서 업데이트
            loggedInUser.userid = newID
            loggedInUser.nickname = newNickname
            
            // 여기에서 유저디폴트에 저장
            UserDefaultManager.shared.updateLoggedInUser(loggedInUser)
            
            // 변경 사항 알림
            change.value = "사용자 정보가 업데이트되었습니다."
        }
    }
    
    //사용자 예매 내역 업데이트 함수
    func updateList() {
        
    }
}
