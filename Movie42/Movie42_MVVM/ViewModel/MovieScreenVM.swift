//
//  MovieScreenVM.swift
//  Movie42_MVVM
//
//  Created by mirae on 1/21/24.
//
import Foundation

class MovieScreenViewModel {
    // 각 카테고리에 대한 영화를 저장하는 딕셔너리
    private var movieDict: [MovieCategory: [Movie]] = [:]
    
    // 영화 데이터가 업데이트될 때 알림을 위한 클로저
    var updateMovie: (() -> Void)?
    
    // 특정 카테고리에 대한 영화 데이터를 가져오는 함수
    func fetchData(for category: MovieCategory) {
        MovieService().fetchMovies(for: category) { [weak self] result in
            switch result {
            case .success(let movieResponse):
                // 가져온 영화를 딕셔너리에 저장
                self?.movieDict[category] = movieResponse.results
                if let movies = self?.movieDict[category] {}
                // 업데이트가 필요한 경우 클로저 호출
                self?.updateMovie?()
            case .failure(let error):
                print("\(category) MovieScreenViewModel fetchData error: \(error.localizedDescription)")
            }
        }
    }
    
    // 카테고리에 대한 영화 아이템 개수 반환 함수
    func itemsCount(for category: MovieCategory) -> Int {
        return movieDict[category]?.count ?? 0
    }
    
    // 카테고리와 인덱스에 대한 영화 아이템 반환 함수
    func item(at index: Int, for category: MovieCategory) -> Movie? {
        return movieDict[category]?[index]
    }
    
    // 카테고리에 대한 영화 리스트 반환 함수
    func movies(for category: MovieCategory) -> [Movie]? {
        return movieDict[category]
    }
    
    
}
