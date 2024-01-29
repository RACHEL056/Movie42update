import UIKit

class SignupViewController: UIViewController {
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var idField: UITextField!
    @IBOutlet weak var pwdField: UITextField!
    @IBOutlet weak var nnField: UITextField!
    
    private let viewModel = SignupViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpBinders()
    }

    private func setUpBinders() {
        viewModel.success.bind { [weak self] success in
            guard let self = self else { return }
            
            switch success {
            case "빈칸 존재":
                print("")
            case "중복 아이디":
                print("")
            case nil:
                goToEntryPage()
            default:
                print(success ?? "")
            }
        }
    }
    
    //빈칸존재 알람
    private func showblankexistAlert() {
        let title = "필요한 정보가 부족합니다!"
        let message = "회원가입을 완료하시려면 정보를 더 입력해주세요."
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title:"확인", style: .default)
        alert.addAction(okAction)
    }
    //중복 아이디 존재 알람
    private func showexistidAlert() {
        let title = "이미 존재하는 아이디입니다!"
        let message = "회원가입을 완료하시려면 아이디를 변경해주세요."
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title:"확인", style: .default)
        alert.addAction(okAction)
    }

    // 회원가입 버튼 클릭 시
    @IBAction func signupBtnClicked(_ sender: Any) {
        guard let name = nameField.text,
              let id = idField.text,
              let pwd = pwdField.text,
              let nickname = nnField.text
        else { return }
        viewModel.signup(name: name, nickname: nickname, id: id, password: pwd)
    }

    // entry 페이지로 이동
    private func goToEntryPage() {
        dismiss(animated: true)
    }
}


