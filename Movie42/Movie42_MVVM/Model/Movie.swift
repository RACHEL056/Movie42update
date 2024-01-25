//
//  Movie.swift
//  Movie42_MVVM
//
//  Created by mirae on 1/16/24.
//

import Foundation

struct MovieResponse: Codable {
    let results: [Movie]
}

// Equatable - Swift에서 프로토콜 중 하나로, 이를 채택한 타입들은 서로 같은지 비교할 수 있도록 해주는 프로토콜
// Hashable - Swift에서 제공하는 프로토콜 중 하나로, 어떤 타입이 해시(Hash) 값을 생성할 수 있도록 해주는 프로토콜 (Set이나 Dictionary)
struct Movie: Codable, Equatable, Hashable {
    let id: Int                 // 영화의 고유 식별자
    let originalLanguage: String // 원본 언어
    let originalTitle: String   // 원본 제목
    let overview: String        // 영화 개요
    let popularity: Float       // 인기도
    let posterPath: String      // 포스터 이미지 경로
    let releaseDate: String     // 개봉일
    let title: String           // 제목
    let video: Bool             // 비디오 포함 여부
    let voteAverage: Float      // 평균 평점
    let voteCount: Int          // 투표 수
    
    // posterURL을 posterPath 기반으로 생성하는 계산된 속성
    var posterURL: URL? {
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }
    
    // Equatable 프로토콜을 따르기 위한 == 연산자 구현
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        // 영화의 고유 식별자(id)를 비교하여 같은지 여부를 반환
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
