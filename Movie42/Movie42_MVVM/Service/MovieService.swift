//
//  MovieService.swift
//  Movie42_MVVM
//
//  Created by mirae on 1/18/24.
//

import Foundation

class MovieService {
    private let defaultUrl = "https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&"
    private let apiKey = "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIzMGQwNTAwNzJiOTdmZDU2OGZmNTRlN2NjMzM4YWQyNCIsInN1YiI6IjY1YTRmMWRkNjBiNThkMDEyZTExN2QzNSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.KxBWIhEv1j0CJpoygoRdsn6bz__Nie_RWFNFU49U9Lk"
    // 한국어 ko-KR, 영어 en-US
    private let defaultLanguage = "language=ko-KR&"
    private let defaultPage = "page=1&"
    
    // 날짜 포맷팅
    private func formattedDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    // Completion handler typealias 정의.
    // MovieCompletion은 클로저 타입 (Result<MovieResponse, Error>) -> Void에 대한 별칭.
    // 이 별칭은 특정 종류의 클로저를 나타내며, 이 클로저는 Result 타입을 매개변수로 받음.
    // Result는 정의된 열거형으로서, 성공 또는 실패의 결과를 나타냄. 성공한 경우 MovieResponse가 성공값으로 전달되고, 실패한 경우 에러(Error)가 전달.
    typealias MovieCompletion = (Result<MovieResponse, Error>) -> Void
    
    // API 호출을 위한 함수
    func fetchMovies(for category: MovieCategory, completion: @escaping MovieCompletion) {
        let url: URL
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 2, to: today)!
        let afterTomorrow = Calendar.current.date(byAdding: .day, value: 3, to: today)!
        let thirtyDays = Calendar.current.date(byAdding: .day, value: 30, to: today)!
        
        switch category {
        case .nowPlaying:
            url = URL(string: "\(defaultUrl)\(defaultLanguage)&sort_by=popularity.desc&with_release_type=2|3&release_date.gte=\(formattedDate(date: today))&release_date.lte=\(formattedDate(date: tomorrow))")!
        case .popular:
            url = URL(string: "\(defaultUrl)\(defaultLanguage)&sort_by=popularity.desc")!
        case .topRated:
            url = URL(string: "\(defaultUrl)\(defaultLanguage)&sort_by=vote_average.desc&without_genres=99,10755&vote_count.gte=200")!
        case .upcoming:
            url = URL(string: "\(defaultUrl)\(defaultLanguage)&sort_by=popularity.desc&with_release_type=2|3release_date.gte=\(formattedDate(date: afterTomorrow))&release_date.lte=\(formattedDate(date: thirtyDays))")!
        }
        
        fetchData(from: url, completion: completion)
    }
    
    // 공통으로 사용하는 데이터를 불러오는 함수
    private func fetchData(from url: URL, completion: @escaping MovieCompletion) {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // 헤더 정보 추가
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue(apiKey, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                // 더 자세한 에러 정보 출력
                print("Error MovieService fetchData: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                // 응답 코드가 범위를 벗어날 경우
                print("Invalid response. Status code: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
                completion(.failure(NSError(domain: "Invalid response", code: 0, userInfo: nil)))
                return
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    let movieResponse = try decoder.decode(MovieResponse.self, from: data)
                    completion(.success(movieResponse))
                } catch {
                    // JSON 디코딩 실패
                    print("Error decoding JSON: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
            
        }.resume()
    }
}

// enum을 사용해 어떤 목록인지 명확하게 하고 가독성을 높힘
enum MovieCategory {
    case nowPlaying
    case popular
    case topRated
    case upcoming
}
