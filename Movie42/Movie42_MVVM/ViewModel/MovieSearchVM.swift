//
//  MovieSearchVM.swift
//  Movie42_MVVM
//
//  Created by mirae on 1/17/24.
//

import Foundation

class MovieSearchViewModel {
    private let movieService = MovieService()
    
    // 화면 업데이트를 위한 클로저 타입 프로퍼티
    var updateMovie: (() -> Void)?
    
    // 연관검색어 업데이트를 위한 클로저 타입 프로퍼티
    var updatePreviewTableCell: (() -> Void)?
    
    // 전체 영화 목록을 저장하는 Set
    private var allMovies: Set<Movie> = [] {
        didSet {
            // 전체 영화 목록이 업데이트되면 화면을 업데이트하는 클로저 호출
            updateMovie?()
        }
    }
    
    // 현재 화면에 표시할 데이터를 저장하는 배열
    private var currentData: [Movie] = [] {
        didSet {
            // 현재 데이터가 업데이트되면 화면을 업데이트하는 클로저 호출
            updateMovie?()
        }
    }
    
    // 현재 검색어에 대한 연관검색어 텍스트를 저장하는 배열
    private var previewTitles: [String] = [] {
        didSet {
            // 연관검색어 텍스트가 업데이트되면 클로저 호출
            updatePreviewTableCell?()
        }
    }
    
    // 초기화
    init() {
        // 페이지 진입 topRated 데이터 불러옴
        fetchData(for: .topRated) {}
    }
    
    // currentData가 private이기때문에 외부에서 접근하기위해 메서드 추가
    // 현재 데이터에 접근할 수 있는 메서드 추가
    func getCurrentData() -> [Movie] {
        print("+++++++++++++++++++++++getCurrentData++++++++ \(currentData)")
        return currentData
    }
    
    // 현재 데이터를 설정하는 메서드
    func setCurrentData(_ data: [Movie]) {
        currentData = data
        // updateMovie 클로저 호출
        updateMovie?()
        print("+++++++++++++++++++++++setCurrentData++++++++ \(currentData)")
    }
    
    // 특정 카테고리에 대한 데이터를 불러오는 메서드
    func fetchData(for category: MovieCategory, completion: @escaping () -> Void) {
        movieService.fetchMovies(for: category) { [weak self] result in
            switch result {
            case .success(let movieResponse):
                // 가져온 데이터를 전체 영화목록에 추가
                // Set에 insert 메서드를 사용하여 중복을 허용하지 않게 추가
                self?.allMovies.formUnion(movieResponse.results)
                // 현재 화면에 표시할 데이터 업데이트
                self?.currentData = Array(self?.allMovies ?? [])
            case .failure(let error):
                // 에러 처리
                print("Error MovieSearchVM fetchData: \(error.localizedDescription)")
            }
            // 비동기 작업이 완료되면 completion 클로저 호출
            completion()
        }
    }

    // 검색 메서드
    func performSearch(query: String) {
        if query.isEmpty {
            // 검색어가 비어있으면 topRated 데이터만 가져옴
            fetchData(for: .topRated) {
                // 검색 미리보기 라벨 업데이트
                self.updatePreviewTitles(with: query)
                // 이전 미리보기 텍스트 초기화
                self.previewTitles = []
                // 현재 데이터를 설정하는 메서드 호출
                self.setCurrentData(Array(self.allMovies))
            }
        } else {
            // 검색어가 있을 경우 모든 카테고리의 데이터를 가져옴
            let categories: [MovieCategory] = [.nowPlaying, .popular, .topRated, .upcoming]
            let group = DispatchGroup()

            categories.forEach { category in
                group.enter()
                fetchData(for: category) {
                    group.leave()
                }
            }

            // 모든 데이터를 가져온 후에 필터링 및 업데이트
            group.notify(queue: .main) {
                self.currentData = self.allMovies.filter { movie in
                    let titleMatch = movie.title.localizedCaseInsensitiveContains(query)
                    let originalTitleMatch = movie.originalTitle.localizedCaseInsensitiveContains(query)

                    // 한글인 경우 title로, 그 외의 경우 originalTitle로 검색
                    return titleMatch || originalTitleMatch
                }

                // 검색 미리보기 라벨 업데이트
                self.updatePreviewTitles(with: query)
                // 이전 미리보기 텍스트 초기화
                self.previewTitles = []

                // 현재 데이터를 설정하는 메서드 호출
                self.setCurrentData(self.currentData)
            }
        }
    }
    
    // 현재 검색어에 대한 연관검색어 텍스트를 가져오는 메서드
    func getPreviewTitles() -> [String] {
        return previewTitles
    }
    
    // 검색 연관검색어 업데이트
    func updatePreviewTitles(with searchText: String) {
        if searchText.isEmpty {
            // 검색어가 비어있다면 연관검색어 제거
            previewTitles = []
        } else {
            // 검색어가 있을 경우 해당 검색어에 대한 연관검색어 텍스트 생성 및 업데이트
            previewTitles = generatePreviewText(for: searchText)
        }
        // 연관검색어 업데이트 클로저 호출
        updatePreviewTableCell?()
    }
    
    // 검색어에 대한 연관검색어 텍스트를 생성하는 메서드
    private func generatePreviewText(for searchText: String) -> [String] {
        // 검색어에 대한 연관검색어 텍스트를 생성하고 반환하는 로직
        let filteredTitles = allMovies
            .compactMap { movie -> String? in
                if searchText.isEmpty {
                    // 검색어가 비어있다면 모든 제목 반환
                    return movie.title
                } else if searchText.isKorean {
                    // 한글 입력일 때는 title 사용
                    return movie.title.localizedCaseInsensitiveContains(searchText) ? movie.title : nil
                } else {
                    // 영어 입력일 때는 originalTitle 사용
                    return movie.originalTitle.localizedCaseInsensitiveContains(searchText) ? movie.originalTitle : nil
                }
            }

        return filteredTitles
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

// 컬렉션에서 중복된 값을 제거하는 extension
extension Array where Element: Equatable {
    func unique(by keyPath: (Element) -> String) -> [Element] {
        var uniqueElements: [Element] = []
        for element in self {
            if !uniqueElements.contains(where: { keyPath($0) == keyPath(element) }) {
                uniqueElements.append(element)
            }
        }
        return uniqueElements
    }
}

extension String {
    // 문자열이 한글을 포함하는지 확인하는 확장 프로퍼티
    var isKorean: Bool {
        return !self.isEmpty && self.range(of: "\\p{Hangul}", options: .regularExpression) != nil
    }
}
