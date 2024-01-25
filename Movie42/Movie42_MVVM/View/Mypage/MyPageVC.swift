import UIKit

class MyPageViewController : UIViewController {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var nickname: UILabel!
    @IBOutlet weak var id: UILabel!
    @IBOutlet weak var movieTV: UITableView!
    
    //MyPageViewModel 인스턴스 생성
    private let viewModel = MyPageViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userImage.image = UIImage(named: "cat")
        setUpBinders()
        updateUI()
        
        movieTV.dataSource = self
        movieTV.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        movieTV.reloadData()
    }
    
    private func setUpBinders() {
        viewModel.change.bind { [weak self] change in
            if change != change {
                self?.updateUI()
            }
        }
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            if let loggedInUser = UserDefaultManager.shared.getLoggedInUser() {
                self.id.text = "ID: \(loggedInUser.userid)"
                self.nickname.text = "닉네임: \(loggedInUser.nickname)"
            }
        }
    }
    
    //개인정보 수정하는 버튼 눌렀을때
    @IBAction func changeUserInfoBtntapped(_ sender: Any) {
        showChangeUserInfoAlert()
    }
    
    private func showChangeUserInfoAlert() {
        let alert = UIAlertController(title: "사용자 정보 수정", message: "새로운 ID와 닉네임을 입력하세요", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "새로운 ID"
        }
        
        alert.addTextField { textField in
            textField.placeholder = "새로운 닉네임"
        }
        
        let saveAction = UIAlertAction(title: "저장", style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            if let newID = alert.textFields?.first?.text,
               let newNickname = alert.textFields?.last?.text {
                // 뷰 모델에 업데이트 요청
                self.viewModel.updateUser(newID: newID, newNickname: newNickname)
                self.nickname.text = "닉네임: \(newNickname)"
                self.id.text = "ID: \(newID)"
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //새로고침 버튼으로 테이블 데이터 리로드 가능하게 만듬
    @IBAction func refreshTableBtntapped(_ sender: UIButton) {
        self.movieTV.reloadData()
    }
}

//예매 영화 목록 및 찜한 목록 테이블 뷰
extension MyPageViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var user = UserDefaultManager.shared.getLoggedInUser()
        if section == 0 {
            return user?.reservations.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reservationCell", for: indexPath)
        var user = UserDefaultManager.shared.getLoggedInUser()
        if indexPath.section == 0 {
            let reservation = user?.reservations[indexPath.row]
            cell.textLabel?.text = "\(reservation?.movieTitle) | \(reservation?.numberOfTickets)명"
        } else if indexPath.section == 1 {
            // 찜한 영화 표시
            if let favoriteMovie = user?.favoriteMovies[indexPath.row] {
                cell.textLabel?.text = favoriteMovie.title
            }
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // 두 섹션: 0은 예매 정보, 1은 찜한 영화
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "내가 예매한 영화" : "내가 찜한 영화"
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var user = UserDefaultManager.shared.getLoggedInUser()
        if let reservation = user?.reservations[indexPath.row] {
            showReservationDetailsAlert(for: reservation)
        }
    }
    
    private func showReservationDetailsAlert(for reservation: Reservation) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월d일 h:mm a"
        
        let dateString = formatter.string(from: reservation.date)
        
        let message = """
        
        \(dateString)
        \(reservation.numberOfTickets)명
        
        - 영화 예매는 Move 42 -
        """
        
        let alert = UIAlertController(title: "\(reservation.movieTitle)", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}
