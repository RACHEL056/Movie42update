//
//  MovieScreenViewController.swift
//  Movie42_MVVM
//
//  Created by mirae on 1/21/24.
//
import Foundation
import UIKit

class MovieScreenViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    private let movieScreenVM = MovieScreenViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupViewModel()
        fetchDataForAllCategories()
        
        // 테이블뷰 셀 사이의 구분선을 없애기
        tableView.separatorStyle = .none
    }

    private func setupTableView() {
        // 셀 등록 및 델리게이트, 데이터 소스 설정
        tableView.register(MovieSreenCollectionViewTableCell.nib(), forCellReuseIdentifier: MovieSreenCollectionViewTableCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
    }

    private func setupViewModel() {
        // 뷰 모델에서 업데이트 발생 시 테이블뷰 리로드
        movieScreenVM.updateMovie = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    private func fetchDataForAllCategories() {
        // 각 카테고리에 대한 데이터 가져오기
        movieScreenVM.fetchData(for: .nowPlaying)
        movieScreenVM.fetchData(for: .popular)
        movieScreenVM.fetchData(for: .topRated)
        movieScreenVM.fetchData(for: .upcoming)
    }
}

extension MovieScreenViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        // 섹션 개수 반환 (각 카테고리 별로 1개씩)
        return 4
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // 각 섹션에 대한 영화 아이템 개수 반환 (1개씩)
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MovieSreenCollectionViewTableCell.identifier, for: indexPath) as! MovieSreenCollectionViewTableCell
        let category = getCategory(for: indexPath.section)
        if let movies = movieScreenVM.movies(for: category) {
            // 셀 설정 및 클로저 전달
            cell.configure(category: category, movies: movies) { [weak self] selectedMovie in
                self?.showDetailView(with: selectedMovie)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 셀 선택 시 상세 페이지로 이동
        let category = getCategory(for: indexPath.section)
        if let selectedMovie = movieScreenVM.item(at: indexPath.row, for: category) {
            showDetailView(with: selectedMovie)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }

    private func getCategory(for section: Int) -> MovieCategory {
        // 섹션에 대응하는 카테고리를 반환
        switch section {
        case 0:
            return .upcoming
        case 1:
            return .topRated
        case 2:
            return .popular
        case 3:
            return .nowPlaying
        default:
            fatalError("Invalid section")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0 // 헤더의 높이를 원하는 값으로 설정
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()

        let label = UILabel()
        let category = getCategory(for: section)
        // 첫글자 대문자로 변환
        label.text = "\(getCategory(for: section))".capitalized
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        label.frame = CGRect(x: 10, y: 0, width: tableView.bounds.size.width - 16, height: 30)
        headerView.addSubview(label)
        
        return headerView
    }
}

extension MovieScreenViewController {
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

//extension MovieScreenViewController {
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let movieCategory: MovieCategory
//        switch indexPath.section {
//        case 0:
//            movieCategory = .nowPlaying
//        case 1:
//            movieCategory = .popular
//        case 2:
//            movieCategory = .topRated
//        case 3:
//            movieCategory = .upcoming
//        default:
//            return
//        }
//
//        let selectedMovie = movieScreenVM.item(at: indexPath.item, for: movieCategory)!
//
//        showDetailView(with: selectedMovie)
//    }
//
//    func showDetailView(with movie: Movie) {
//        let storyboard = UIStoryboard(name: "MovieDetailView", bundle: nil)
//        if let detailViewController = storyboard.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieDetailViewController {
//            // MovieDetailViewController의 프로퍼티에 직접 할당
//            detailViewController.selectedMovie = movie
//            
//            // 화면을 modal로 표시
//            detailViewController.modalPresentationStyle = .automatic
//            present(detailViewController, animated: false, completion: nil)
//        }
//    }


