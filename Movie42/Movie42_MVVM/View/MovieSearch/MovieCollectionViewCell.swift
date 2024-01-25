//
//  MovieCollectionViewCell.swift
//
//  Created by mirae on 1/18/24.
//

import UIKit

class MovieCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // titleLabel 설정
        titleLabel.numberOfLines = 0 // 여러 줄 지원
        titleLabel.lineBreakMode = .byTruncatingTail // 줄임표(...)로 표시
        titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .bold) // 폰트와 굵기 설정
        
        // posterImageView 설정
        posterImageView.contentMode = .scaleAspectFill // 이미지를 셀 내부에 채우면서 일부가 잘림
        posterImageView.clipsToBounds = true // 필요한 경우 이미지가 셀 밖으로 나가지 않도록 클리핑
        
    }

    func configure(with movie: Movie) {
        // Movie 객체에서 필요한 데이터를 가져와 UI 업데이트
        titleLabel.text = movie.title

        // 포스터 이미지를 가져와 설정
        if let posterURL = movie.posterURL {
            // URLSession을 사용하여 비동기적으로 이미지 다운로드
            URLSession.shared.dataTask(with: posterURL) { (data, response, error) in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        // 이미지 로딩이 완료된 후에 posterImageView에 설정
                        self.posterImageView.image = image
                    }
                }
            }.resume()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        // 셀이 재사용되기 전에 초기화 작업을 수행
        posterImageView.image = nil
        titleLabel.text = nil
    }
}
