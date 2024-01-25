import Foundation

class MovieScreenVM {
    private let movieService = MovieService()
    
    // 화면 업데이트를 위한 클로저타입 프로퍼티
    var updateMovie: (() -> Void)?
    
    // 전체 영화목록을 저장하는 배열
    private var allMovies: [Movie] = [] {
        didSet {
            // 전체 영화목록이 업데이트되면 화면을 업데이트하는 클로저 호출
            updateMovie?()
            //print("All Movies Updated: \(allMovies)")
        }
    }
    
    // 현재 화면에 표시할 데이터를 저장하는 배열
    private var currentData: [Movie] = [] {
        didSet {
            // 현재 데이터가 업데이트되면 화면을 업데이트하는 클로저 호출
            updateMovie?()
            //print("Current Data Updated: \(currentData)")
        }
    }
    
    // 초기화
    init() {
        // 페이지 진입 NowPlay 영화데이터 불러옴
        fetchData()
    }
    
    // nowPlaying을 불러오는 API 호출
    func fetchData() {
        movieService.fetchMovies(for: .nowPlaying) { [weak self] result in
            switch result {
            case .success(let movieResponse):
                // 전체 영화 목록을 저장
                self?.allMovies = movieResponse.results
                // 초기에는 상영중인 데이터를 화면에 표시
                self?.currentData = movieResponse.results
                //print(movieResponse.results)
            case .failure(let error):
                // 에러 처리
                print("Error MovieSearchVM fetchData: \(error.localizedDescription)")
            }
        }
    }

    // 현재 데이터의 개수를 반환
    func itemsCount() -> Int {
        return currentData.count
    }
    
    // 특정 인덱스의 값을 반환
    func item(at index: Int) -> Movie {
        return currentData[index]
    }
}
