//
//  MovieSreenCollectionViewCell.swift
//  Movie42_MVVM
//
//  Created by mirae on 1/21/24.
//

import UIKit

class MovieSreenCollectionViewCell: UICollectionViewCell {
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    static let identifier = "MovieSreenCollectionViewCell"

    static func nib() -> UINib {
        return UINib(nibName: "MovieSreenCollectionViewCell", bundle: nil)
    }

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
        titleLabel.text = movie.title
        if let posterURL = movie.posterURL {
            URLSession.shared.dataTask(with: posterURL) { [weak self] (data, _, error) in
                if let error = error {
                    print("Error downloading image: \(error.localizedDescription)")
                    return
                }
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.posterImageView.image = image
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
    
