import Foundation

final class EntryViewModel {
    
    var error: ObservableObject<String?> = ObservableObject("")
    
    func login(id: String, password: String) {
        NetworkService.shared.login(id: id, password: password) {
            [weak self] success in
            print("NetworkService에 대한 completion 값", success)
            if success {
                print("Login successful")
                //로그인에 성공한 유저를 로그인 유저로 Userdefault에 저장해둠
                let loggedInUser = UserDefaultManager.shared.datas.first { $0.userid == id }
                UserDefaults.standard.set(loggedInUser?.userid, forKey: "loggedInUserId")
                self?.error.value = nil
            } else {
                print("Login failed")
                self?.error.value = "로그인에 실패했습니다."
            }
        }
    }
}
