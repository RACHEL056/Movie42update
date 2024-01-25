import UIKit

class ScreenCollectionViewCell: UICollectionViewCell {
  @IBOutlet private weak var posterImageView: UIImageView!
  @IBOutlet private weak var titleLabel: UILabel!
    
  override func awakeFromNib() {
    super.awakeFromNib()
    // 셀 초기화 설정 (예: 배경색, 테두리 등)
  }
  func configure(with movie: Movie) {
    // Movie 객체에서 필요한 데이터를 가져와 UI 업데이트
    titleLabel.text = movie.title
    // 포스터 이미지를 가져와 설정 (이미지 다운로드 등은 비동기적으로 처리하는 것이 좋음)
    if let posterURL = URL(string: "https://image.tmdb.org/t/p/w500" + movie.posterPath) {
    }
  }
  override func prepareForReuse() {
    super.prepareForReuse()
    // 셀이 재사용되기 전에 초기화 작업을 수행할 수 있습니다.
    posterImageView.image = nil
    titleLabel.text = nil
  }
}
