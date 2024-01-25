

import Foundation

class MovieDetailViewModel {
    private let movieService = MovieService()
    private let userSettings = UserSettings()
    var change: ObservableObject<String?> = ObservableObject<String?>("Nothing Changed")
    // 영화 상세 정보를 저장하는 속성
    private var movie: Movie?
    
    // 영화 정보를 가져오는 메서드
    func fetchMovieDetails(for movieID: Int) {
        movieService.fetchMovies(for: .nowPlaying) { [weak self] (result: Result<MovieResponse, Error>) in
            switch result {
            case .success(let movieResponse):
                if let movie = movieResponse.results.first {
                    self?.movie = movie
                    // 변경 사항 알림
                    self?.change.value = "영화 정보가 업데이트되었습니다."
                } else {
                    // 해당 ID에 대한 영화가 없는 경우 처리
                    print("Error MovieDetailViewModel fetchMovieDetails: Movie not found for ID \(movieID)")
                }
            case .failure(let error):
                // 에러 처리
                print("Error MovieDetailViewModel fetchMovieDetails: \(error.localizedDescription)")
            }
        }
    }
    
    
    // 영화 포스터 URL을 반환하는 계산된 속성
    var moviePosterURL: URL? {
        return movie?.posterURL
    }
    
    // 영화 제목을 반환하는 계산된 속성
    var movieTitle: String? {
        return movie?.title
    }
    
    // 영화 줄거리를 반환하는 계산된 속성
    var movieOverview: String? {
        return movie?.overview
    }
    
    
    func setHeartSelectedState(_ isSelected: Bool, movie: Movie) {
        userSettings.saveHeartSelectedState(isSelected, for: movie)
        
        if var loggedInUser = UserDefaultManager.shared.getLoggedInUser() {
            var updatedUser = loggedInUser
            
            if isSelected {
                if !updatedUser.favoriteMovies.contains(where: { $0.title == movie.title }) {
                    updatedUser.favoriteMovies.append(movie)
                }
            } else {
                updatedUser.favoriteMovies.removeAll { $0.title == movie.title }
            }
            
            UserDefaultManager.shared.updateLoggedInUser(updatedUser)
            
            change.value = "사용자 정보가 업데이트되었습니다."
        }
    }
    
    func getHeartSelectedState(for movie: Movie) -> Bool {
        return userSettings.loadHeartSelectedState(for: movie)
    }
}
