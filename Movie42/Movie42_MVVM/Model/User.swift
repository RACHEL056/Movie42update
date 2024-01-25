import Foundation

//회원가입 된 유저의 구조체
struct User : Codable {
    var name : String
    var nickname : String
    var userid : String
    var pwd : String
    var reservations: [Reservation] = []
    var favoriteMovies: [Movie] = []
    
}

//userdefault로 저장하게 하는 manager
class UserDefaultManager {
    static let shared = UserDefaultManager()
    private let userDefaults: UserDefaults
    
    init() {
        self.userDefaults = UserDefaults.standard
    }
    
    var datas: [User] {
        get {
            if let savedData = userDefaults.data(forKey: "users"),
               let decodedData = try? JSONDecoder().decode([User].self, from: savedData) {
                return decodedData
            }
            return []
        }
        set {
            if let encodedData = try? JSONEncoder().encode(newValue) {
                self.userDefaults.set(encodedData, forKey: "users")
            }
        }
    }
    
    //로그인 화면에서 loggedInUserId로 저장된 유저값 가져옴
    //현재 로그인한 사용자 정보를 가져오는 함수
    func getLoggedInUser() -> User? {
        if let loggedInUserId = UserDefaults.standard.string(forKey: "loggedInUserId") {
            return UserDefaultManager.shared.datas.first { $0.userid == loggedInUserId }
        }
        return nil
    }
    
    //사용자 정보 변경 시 사용자 정보 업데이트
    func updateLoggedInUser(_ user: User) {
        if let users = userDefaults.data(forKey: "users"),
           var decodedData = try? JSONDecoder().decode([User].self, from: users) {
            
            if let index = decodedData.firstIndex(where: { $0.userid == user.userid }) {
                decodedData[index] = user
                if let encodedData = try? JSONEncoder().encode(decodedData) {
                    userDefaults.set(encodedData, forKey: "users")
                }
            }
        }
    }
}

