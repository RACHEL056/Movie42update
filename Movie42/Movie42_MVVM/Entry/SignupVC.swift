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
            if let success = success {
                print(success)
            } else {
                // 회원가입 성공 시 처리 다시 로그인페이지로(error=nil이므로)
                self?.goToEntryPage()
            }
        }
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
