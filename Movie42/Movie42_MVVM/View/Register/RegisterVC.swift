import UIKit

class RegisterViewController: UIViewController {
    
    var Mypage = MyPageViewController()
    var reservationViewModel = RegisterViewModel()
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var dateDatePicker: UIDatePicker!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var numberOfTickets: UILabel!
    @IBOutlet weak var TicketsStepper: UIStepper!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    var selectedMovie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 초기화 및 필요한 설정
        updateUI()
        // timePicker의 값이 변경될 때 호출되는 액션 메서드를 설정
        timePicker.addTarget(self, action: #selector(timePickerValueChanged), for: .valueChanged)
        
    }
    // timePicker의 값이 변경될 때 호출되는 메서드
    @objc func timePickerValueChanged() {
        reservationViewModel.selectedTime = getTimeStringFromDatePicker(datePicker: timePicker)
        updateUI()
    }
    
    // 결제 버튼을 눌렀을 때 호출되는 메서드
    @IBAction func ticketingButtonTapped(_ sender: UIButton) {
        reservationViewModel.saveReservation(with: UserDefaultManager.shared.getLoggedInUser(), with: selectedMovie, with: dateDatePicker.date)
        updateUI()
        print(UserDefaultManager.shared.getLoggedInUser()?.reservations)
        // 예매 완료 알림창 표시
        showReservationCompletionAlert()
    }
    
    @IBAction func stepperValueChanged(_ sender: UIStepper) {
        // UIStepper의 값이 변경되었을 때 호출되는 메서드
        reservationViewModel.selectedNumberOfTickets = Int(sender.value)
        updateUI()
    }
    
    func getTimeStringFromDatePicker(datePicker: UIDatePicker) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: datePicker.date)
    }
    
    func updateUI() {
        movieTitleLabel.text = selectedMovie?.title
        reservationViewModel.selectedDate = dateDatePicker.date
        numberOfTickets.text = "\(reservationViewModel.selectedNumberOfTickets ?? 0) 명"
        let totalPrice = calculateTotalPrice(using: reservationViewModel)
        totalPriceLabel.text = "\(totalPrice) 원"
        let currentDate = Date()
        // 당일을 기준으로 이전 날짜를 선택하지 못하도록 설정
        dateDatePicker.minimumDate = currentDate
    }
    
    //총 결제 금액 함수
    func calculateTotalPrice(using viewModel: RegisterViewModel) -> Int {
        if let numberOfTickets = viewModel.selectedNumberOfTickets {
            // 여기에 총 가격 계산 로직을 추가할 수 있습니다.
            // 간단하게 1인당 12,000원으로 가정
            return numberOfTickets * 12000
        } else {
            // numberOfTickets이 nil인 경우에 대한 예외 처리
            print("예매된 티켓 수가 없습니다.")
            return 0
        }
    }
    
    //예매 완료 시 보이는 화면
    func showReservationCompletionAlert() {
        if let movieTitle = selectedMovie?.title,
           let date = reservationViewModel.selectedDate,
           let time = reservationViewModel.selectedTime {
            
            let numberOfTickets = reservationViewModel.selectedNumberOfTickets ?? 0
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy년 M월d일"
            
            let dateString = formatter.string(from: date)
            let message = """
            
            \(dateString)
            \(time)
            \(numberOfTickets)명
            
            Movie 42
            이용해 주셔서 감사합니다.
            """
            
            let alert = UIAlertController(title: """
                                            \(movieTitle)
                                            예매 완료
                                            """,
                                          message: message, preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                // 경고 확인 버튼을 눌렀을 때 예매하기 페이지를 닫기
                self?.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            
        } else {
            // 예외 처리: 필요한 값이 없는 경우
            print("예매 정보가 부족합니다.")
            
            // 사용자에게 경고 표시
            let alert = UIAlertController(title: "경고", message: "예매 정보가 부족합니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
}
