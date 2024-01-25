//
//  MovieSreenCollectionViewTableCell.swift
//  Movie42_MVVM
//
//  Created by mirae on 1/21/24.
//

import UIKit

class MovieSreenCollectionViewTableCell: UITableViewCell {
    @IBOutlet private weak var collectionView: UICollectionView!
    
    private var category: MovieCategory?
    private var movies: [Movie] = []
    private let movieScreenVM = MovieScreenViewModel()
    
    // 셀클릭 이벤트될 때 상세페이지로 이동하기위한 클로저
    var didSelectMovie: ((Movie) -> Void)?

    static let identifier = "MovieSreenCollectionViewTableCell"

    static func nib() -> UINib {
        return UINib(nibName: "MovieSreenCollectionViewTableCell", bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(MovieSreenCollectionViewCell.nib(), forCellWithReuseIdentifier: MovieSreenCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    // 셀에 카테고리와 영화 데이터 설정 및 클로저 할당
    func configure(category: MovieCategory, movies: [Movie], didSelectMovie: @escaping (Movie) -> Void) {
        self.category = category
        self.movies = movies
        self.didSelectMovie = didSelectMovie
        collectionView.reloadData() // collectionView를 새로고침하여 데이터를 반영
    }
}

extension MovieSreenCollectionViewTableCell: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
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
        return UIEdgeInsets(top: 4.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
}

extension MovieSreenCollectionViewTableCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movies.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieSreenCollectionViewCell.identifier, for: indexPath) as! MovieSreenCollectionViewCell
        let movie = movies[indexPath.item]
        cell.configure(with: movie)
        return cell
    }
    
    // 상세페이지 클릭 이벤트
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedMovie = movies[safe: indexPath.item] {
            didSelectMovie?(selectedMovie)
        }
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
