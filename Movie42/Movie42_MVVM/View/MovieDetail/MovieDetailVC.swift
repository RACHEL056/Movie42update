//
//  MovieDetailVC.swift
//  Movie42_MVVM
//
//  Created by 김우경 on 1/20/24.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var moviePosterImage: UIImageView!
    @IBOutlet weak var movieText: UITextView!
    @IBOutlet weak var movieTiceting: UIButton!
    @IBOutlet weak var heartButton: UIButton!
    
    // MovieDetailViewModel 인스턴스 생성
    private let movieDetailViewModel = MovieDetailViewModel()
    
    // 선택된 영화의 ID
    var selectedMovieID: Int = 0
    
    var heartMovie: Movie?
    
    //선택, 즉 이전 컬렉션에서 선택한 영화
    var selectedMovie: Movie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let selectedMovie = selectedMovie else {
            // selectedMovie가 nil인 경우 처리
            return
        }
        
        // 초기 설정: 빈 하트 이미지 설정
        let emptyHeartImage = UIImage(systemName: "heart")
        let filledHeartImage = UIImage(systemName: "heart.fill")
        
        // 버튼의 이미지 설정
        heartButton.setImage(emptyHeartImage, for: .normal)
        heartButton.setImage(filledHeartImage, for: .selected)
        
        // 버튼의 초기 상태 설정
        let isHeartSelected = movieDetailViewModel.getHeartSelectedState(for: selectedMovie)
        heartButton.isSelected = isHeartSelected
        
        // 영화 정보 가져오기
        movieDetailViewModel.fetchMovieDetails(for: selectedMovieID)
        
        // 영화 정보 변경 시 화면 업데이트
        movieDetailViewModel.change.bind { [weak self] _ in
            self?.updateUI()
        }
    }
    
    // 화면 업데이트 메서드
    private func updateUI() {
        // 영화 제목 설정
        movieTitleLabel.text = selectedMovie?.title
        // 영화 포스터 이미지 설정
        if let posterURL = selectedMovie?.posterURL {
            // 비동기적으로 이미지를 로드하여 설정
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: posterURL),
                   let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.moviePosterImage.image = image
                    }
                }
            }
        }
        
        // 영화 줄거리 설정
        movieText.text = selectedMovie?.overview
    }
    
    @IBAction func heartButtonTapped(_ sender: UIButton) {
        guard let selectedMovie = selectedMovie else {
            // selectedMovie가 nil인 경우 처리
            return
        }
        
        // 버튼의 isSelected 상태를 토글
        sender.isSelected.toggle()
        print("heartButtonTapped - isSelected: \(sender.isSelected)") // 디버깅 출력
        // MovieDetailViewModel에게 하트 버튼 상태 업데이트 요청
        movieDetailViewModel.setHeartSelectedState(sender.isSelected, movie: selectedMovie)
    }
    
    @IBAction func registerBtnTapped() {
        let select = self.selectedMovie
        let storyboard = UIStoryboard(name: "RegisterView", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ReservationViewController") as? RegisterViewController {
            vc.selectedMovie = select
            
            // 화면을 modal로 표시
            vc.modalPresentationStyle = .automatic
            present(vc, animated: false, completion: nil)
        }
    }
}
