import Foundation

class RegisterViewModel {
    
    var selectedMovie: Movie?
    var selectedDate: Date?
    var selectedTime: String?
    var selectedNumberOfTickets: Int? = 0
    
    // 예매 정보를 저장하고 현재 로그인된 유저에 연결하는 메서드
    func saveReservation(with user : User?, with movie: Movie?, with date: Date? ) {
        print(#function)
        guard var currentUser = user,
              let selectedMovie = movie,
              let selectedDate = date else {
            // 필요한 값이 없으면 리턴
            print("currentUser, selectedMovie, or selectedDate is nil")
            return
        }
        
        // 예매 정보 생성
        let reservation = Reservation(movieTitle: selectedMovie.title, date: selectedDate, time: selectedTime ?? "12:00 PM", // 선택된 시간이 없을 경우 기본값 설정
            numberOfTickets: selectedNumberOfTickets ?? 0) // 선택된 티켓 수가 없을 경우 기본값 설정
        
        // 유저 정보 업데이트
        currentUser.reservations.append(reservation)
        
        // UserDefaultManager를 활용하여 유저 정보 업데이트
        UserDefaultManager.shared.updateLoggedInUser(currentUser)
    }
}
