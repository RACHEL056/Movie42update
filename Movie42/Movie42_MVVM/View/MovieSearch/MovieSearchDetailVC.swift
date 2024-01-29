//
//  MovieSearchDetailView.swift
//  Movie42_MVVM
//
//  Created by mirae on 1/26/24.
//

import Foundation
import UIKit

// MovieSearchDetailDelegate 프로토콜 정의
protocol MovieSearchDetailDelegate: AnyObject {
    func didDismiss(with searchResults: [Movie])
    func didPerformSearch(with query: String)
}

class MovieSearchDetailViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBAction func searchButtonTapped(_ sender: Any) {
        performSearch(with: searchBar.text)
    }
    
    // MovieSearchViewModel 인스턴스 생성
    private let movieSearchVM = MovieSearchViewModel()
    
    // 프로토콜을 사용하기 위한 델리게이트
    weak var delegate: MovieSearchDetailDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UISearchBar 설정
        searchBar.delegate = self
        
        // UITableView 설정
        tableView.delegate = self
        tableView.dataSource = self
        
        // 검색 미리보기 텍스트 업데이트 시 TableView Reload
        movieSearchVM.updatePreviewTableCell = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    // 검색 결과를 반환하는 메서드
    private func returnSearchResults(_ searchResults: [Movie]) {
        // 델리게이트를 통해 결과를 전달
        delegate?.didDismiss(with: searchResults)
        
        // 모달 닫기
        dismiss(animated: true, completion: nil)
    }
    
    // 검색 수행 메서드
    func performSearch(with query: String?) {
        guard let searchText = query else { return }
        
        // 실제 검색 메서드 호출
        movieSearchVM.performSearch(query: searchText)
        
        // 델리게이트에 검색어 전달
        delegate?.didPerformSearch(with: searchText)
        
        // 검색 완료 후 모달 닫기
        dismiss(animated: true, completion: nil)
    }
    
    func didDismiss(with searchResults: [Movie]) {
        // 검색 결과를 사용하여 필요한 작업 수행
        // 예: 결과를 콘솔에 출력
        print("Search Results: \(searchResults)")
    }
    
}

// MARK: - UISearchBarDelegate
extension MovieSearchDetailViewController: UISearchBarDelegate {
    // 검색어가 변경될 때 호출되는 메서드
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 검색어가 변경될 때마다 미리보기 텍스트를 업데이트
        movieSearchVM.updatePreviewTitles(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 검색 버튼이 눌렸을 때 검색 수행
        performSearch(with: searchBar.text)
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension MovieSearchDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 검색어에 따른 미리보기 텍스트의 개수 반환
        return movieSearchVM.getPreviewTitles().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // UITableViewCell 설정
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        
        // 검색어 스타일링을 위한 메서드 호출
        let result = movieSearchVM.getPreviewTitles()[indexPath.row]
        let styledText = styleSearchResult(result)
        
        // 셀에 스타일링된 텍스트 적용
        cell.textLabel?.attributedText = styledText
        
        return cell
    }
    
    // 검색어 스타일링 메서드
    private func styleSearchResult(_ result: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: result)
        
        // 내가 검색한 키워드를 다르게 스타일링 (예: 색상 변경)
        if let searchText = searchBar.text, !searchText.isEmpty {
            let range = (result as NSString).range(of: searchText, options: .caseInsensitive)
            attributedString.addAttribute(.foregroundColor, value: UIColor.red, range: range)
        }
        
        return attributedString
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 테이블뷰 셀 선택 시 검색 수행
        let selectedKeyword = movieSearchVM.getPreviewTitles()[indexPath.row]
        searchBar.text = selectedKeyword
        performSearch(with: selectedKeyword)
    }
}
