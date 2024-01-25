import Foundation

final class SignupViewModel {
    
    var error: ObservableObject<String?> = ObservableObject("")
    
    func signup(name: String, nickname: String, id: String, password: String) {
        // 가상의 회원가입 로직
        let newUser = User(name: name, nickname: nickname, userid: id, pwd: password)
        
        // 기존의 저장된 유저 목록을 불러옴
        var users = UserDefaultManager.shared.datas
        users.append(newUser)
        UserDefaultManager.shared.datas = users

        print("Signup successful")

        // 회원가입 성공 시 error를 nil로 업데이트
        self.error.value = nil
    }
}
