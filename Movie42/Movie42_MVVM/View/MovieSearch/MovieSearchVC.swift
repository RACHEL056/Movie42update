//
//  MovieSearchVC.swift
//  Movie42_MVVM
//
//  Created by mirae on 1/17/24.
//

import Foundation
import UIKit

class MovieSearchViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBAction func searchBtn(_ sender: Any) {
        showSearchDetailView()
    }
    
    // MovieSearchViewModel 인스턴스 생성
    private let movieSearchVM = MovieSearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // 초기데이터 로드
        setupReload()
    }
    
    private func setupReload() {
        // 화면업데이트가 필요할 때마다 reloadData호출
        movieSearchVM.updateMovie = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
    }
    
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MovieSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource, MovieSearchDetailDelegate {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 컬렉션 뷰 셀 설정
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as? MovieCollectionViewCell else {
            fatalError("Failed to dequeue MovieCollectionViewCell")
        }
        
        // 특정 인덱스의 아이템을 가져와 셀에 설정
        let movie = self.movieSearchVM.item(at: indexPath.item)
        cell.configure(with: movie)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.movieSearchVM.itemsCount() 
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // 셀을 선택했을 때의 동작
        let selectedMovie = movieSearchVM.item(at: indexPath.item)
        // 상세 페이지로 이동하거나 다른 동작 수행
        showDetailView(with: selectedMovie)
    }
    
    func showDetailView(with movie: Movie) {
        let storyboard = UIStoryboard(name: "MovieDetailView", bundle: nil)
        if let detailViewController = storyboard.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController {
            // MovieDetailViewController의 프로퍼티에 직접 할당
            detailViewController.selectedMovie = movie
            
            // 화면을 modal로 표시
            detailViewController.modalPresentationStyle = .automatic
            present(detailViewController, animated: true, completion: nil)
        }
    }
    
    // 검색 결과를 보여주는 모달 화면 표시
    func showSearchDetailView() {
        let storyboard = UIStoryboard(name: "MovieSearchDetailView", bundle: nil)
        if let detailViewController = storyboard.instantiateViewController(withIdentifier: "MovieSearchDetailViewController") as? MovieSearchDetailViewController {

            // 화면을 modal로 표시
            detailViewController.modalPresentationStyle = .automatic

            // 델리게이트 설정
            detailViewController.delegate = self

            present(detailViewController, animated: true, completion: nil)
        }
    }
    
    // MovieSearchDetailDelegate 프로토콜을 준수하는 didDismiss 메서드 구현
    func didDismiss(with searchResults: [Movie]) {
        // 검색 결과를 사용하여 화면을 업데이트하거나 다른 동작 수행
        updateCollectionView(with: searchResults)
    }
    
    func didPerformSearch(with query: String) {
        print("Performed search with query: \(query)")
        // MovieSearchViewModel에 검색어 전달
        movieSearchVM.performSearch(query: query)
    }
    
    // 검색 결과를 콜렉션뷰에 반영하는 메서드 추가
    func updateCollectionView(with searchResults: [Movie]) {
        // 현재 데이터에 검색 결과를 추가, 콜렉션뷰를 리로드
        movieSearchVM.setCurrentData(searchResults)
        print("************************************ updateCollectionView : \(searchResults)")
        DispatchQueue.main.async { [weak self] in
            self?.collectionView.reloadData()
        }
        print("************************************ currentData : \(movieSearchVM.getCurrentData())")
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension MovieSearchViewController: UICollectionViewDelegateFlowLayout {
    // 셀의 사이즈 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width / 3 - 6.0 // 한 줄에 3개씩
        let cellHeight = cellWidth * 1.4 + 63.0 // 이미지 높이 + 라벨 높이
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    // 셀과 셀 사이의 간격 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1.0
    }
    
    // 셀이 표시될 때의 여백 설정 (상, 하, 좌, 우)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4.0, left: 1.0, bottom: 4.0, right: 1.0)
    }
}
