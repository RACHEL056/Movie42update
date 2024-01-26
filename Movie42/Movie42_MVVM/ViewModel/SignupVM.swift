import Foundation

final class SignupViewModel {
    
    var success: ObservableObject<String?> = ObservableObject("")
    
    func signup(name: String, nickname: String, id: String, password: String) {
        
        var users = UserDefaultManager.shared.datas
        
        //중복된 아이디가 있을 경우 경고창 띄우기
        if users.contains(where: { $0.userid == id }) {
            self.success.value = "중복 아이디"
            return
        }
        
        // 가상의 회원가입 로직
        let newUser = User(name: name, nickname: nickname, userid: id, pwd: password)
        
        users.append(newUser)
        UserDefaultManager.shared.datas = users

        print("로그인 성공")

        // 회원가입 성공 시 error를 nil로 업데이트
        self.success.value = nil
    }
}
