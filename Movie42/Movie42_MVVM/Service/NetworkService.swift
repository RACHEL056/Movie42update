import Foundation

final class NetworkService {
    static let shared = NetworkService()
    private let defaults = UserDefaultManager()
    
    private init() { }
    
    func login(id: String, password: String, completion: @escaping(Bool) -> Void) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if self.defaults.datas.first(where: { $0.userid == id && $0.pwd == password }) != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
