//
//  MovieSearchVC.swift
//  Movie42_MVVM
//
//  Created by Bae on 1/17/24.
//

import Foundation
import UIKit

class MovieSearchViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var searchTextField: UISearchBar!
    @IBOutlet weak var previewLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBAction func searchButtonTapped(_ sender: UIButton) {
        // 검색 버튼이 눌렸을 때 검색 수행
        movieSearchVM.performSearch(query: searchTextField.text ?? "")
    }
    
    // MovieSearchViewModel 인스턴스 생성
    private let movieSearchVM = MovieSearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        searchTextField.delegate = self
        
        // 초기데이터 로드
        setupReload()
        movieSearchVM.fetchData(for: .nowPlaying) {}
        
        // 검색 미리보기 라벨에 탭 제스처 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(previewLabelTapped))
        previewLabel.isUserInteractionEnabled = true
        previewLabel.addGestureRecognizer(tapGesture)
        
    }
    
    private func setupReload() {
        // 화면업데이트가 필요할 때마다 reloadData호출
        movieSearchVM.updateMovie = { [weak self] in
            DispatchQueue.main.async {
                self?.collectionView.reloadData()
            }
        }
        
        // 미리보기 라벨 업데이트 클로저 설정
        movieSearchVM.updatePreviewLabel = { [weak self] in
            DispatchQueue.main.async {
                self?.updatePreviewLabel()
            }
        }
    }
    
    @objc func previewLabelTapped(_ gesture: UITapGestureRecognizer) {
        // 검색 미리보기 라벨 클릭시 검색 수행
        let point = gesture.location(in: previewLabel)
        if let tappedLabel = findTappedLabel(at: point) {
            let searchText = tappedLabel.text ?? ""
            movieSearchVM.performSearch(query: searchText)
        }
    }
    
    // 특정 지점에서 탭된 라벨을 찾는 메서드
    private func findTappedLabel(at point: CGPoint) -> UILabel? {
        for subview in previewLabel.subviews {
            if let label = subview as? UILabel, label.frame.contains(point) {
                return label
            }
        }
        return nil
    }
    
    // 미리보기 라벨 업데이트 메서드
    func updatePreviewLabel() {
        let previewTitles = movieSearchVM.getPreviewTitles()

        // 검색 결과가 없으면 배경색 제거
        previewLabel.backgroundColor = previewTitles.isEmpty ? nil : UIColor.systemGray

        // 이전에 미리보기 라벨에 추가된 뷰들을 제거
        for subview in previewLabel.subviews {
            subview.removeFromSuperview()
        }

        var previousLabel: UILabel?

        for title in previewTitles {
            // 라벨 생성
            let label = UILabel()
            label.text = title
            label.textColor = UIColor.black
            label.isUserInteractionEnabled = true

            // 라벨을 미리보기 라벨에 추가
            previewLabel.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = UIColor.systemGray
            label.layer.borderWidth = 0.5
            label.layer.borderColor = UIColor.black.cgColor

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: previewLabel.leadingAnchor),
                label.trailingAnchor.constraint(equalTo: previewLabel.trailingAnchor),
                label.heightAnchor.constraint(equalToConstant: 30.0) // 라벨의 높이 조절
            ])

            if let previousLabel = previousLabel {
                label.topAnchor.constraint(equalTo: previousLabel.bottomAnchor).isActive = true
            } else {
                // 첫 번째 라벨의 경우 previewLabel.topAnchor에 연결
                label.topAnchor.constraint(equalTo: previewLabel.topAnchor).isActive = true
            }

            // previousLabel 업데이트
            previousLabel = label
        }
    }
    
}

// MARK: - UISearchBarDelegate
extension MovieSearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // 검색어가 변경될 때마다 검색 미리보기 업데이트
        movieSearchVM.updatePreviewTitles(with: searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 검색 버튼이 클릭되면 검색 수행
        performSearch()
    }
    
    private func performSearch() {
        // 검색 실행
        guard let searchText = searchTextField.text, !searchText.isEmpty else {
            // 검색어가 비어있으면 미리보기 타이틀 제거
            previewLabel.text = nil
            return
        }
        
        // 검색어가 비어있지 않으면 검색 수행
        movieSearchVM.performSearch(query: searchText)
        
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource
extension MovieSearchViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 컬렉션 뷰 셀 설정
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCollectionViewCell", for: indexPath) as? MovieCollectionViewCell else {
            fatalError("Failed to dequeue MovieCollectionViewCell")
        }
        
        // 특정 인덱스의 아이템을 가져와 셀에 설정
        let movie = movieSearchVM.item(at: indexPath.item)
        cell.configure(with: movie)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieSearchVM.itemsCount()
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
            present(detailViewController, animated: false, completion: nil)
        }
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

