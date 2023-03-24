
import UIKit

class PopupActionsTableViewCell: UITableViewCell {
    
    // MARK: - Subviews
    private lazy var actionNameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var actionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Methods
    func setupCell(forAction action: PopupAction) {
        self.addSubview(actionNameLabel)
        self.addSubview(actionImageView)
        
        setupConstraints()
        
        actionNameLabel.textColor = .white
        
        switch action {
        case .reply:
            fillCell(
                actionText: action.rawValue.localized,
                actionImage: replyImage
            )
        case .copy:
            fillCell(
                actionText: action.rawValue.localized,
                actionImage: copyImage
            )
        case .edit:
            fillCell(
                actionText: action.rawValue.localized,
                actionImage: editImage
            )
        case .delete:
            actionNameLabel.textColor = actionColourDelete
            fillCell(
                actionText: action.rawValue.localized,
                actionImage: deleteImage
            )
        case .like:
            fillCell(
                actionText: action.rawValue.localized,
                actionImage: editImage
            )
        case .dislike:
            fillCell(
                actionText: action.rawValue.localized,
                actionImage: editImage
            )
        }
    }
    
    // MARK: - Private methods
    private func setupConstraints() {
        actionNameLabel.snp.remakeConstraints { (make) in
            make.centerY.equalToSuperview()
            // For some reason this layout only works for iOS 13+ only, not iOS 11+ as supposed to
            if #available(iOS 13.0, *) {
                make.leading.equalTo(self.safeAreaLayoutGuide.snp.leading)
                    .inset(10)
            } else {
                make.leading.equalToSuperview()
                    .inset(10)
            }
        }
        
        actionImageView.snp.remakeConstraints { (make) in
            // For some reason this layout only works for iOS 13+ only, not iOS 11+ as supposed to
            if #available(iOS 13.0, *) {
                make.trailing.equalTo(self.safeAreaLayoutGuide)
                    .inset(10)
                make.top.bottom.equalTo(self.safeAreaLayoutGuide)
                    .inset(10)
                make.leading.equalTo(actionNameLabel.snp.trailing)
                    .offset(10)
            } else {
                make.trailing.bottom.equalToSuperview()
                    .inset(10)
                make.top.bottom.equalToSuperview()
                    .inset(10)
            }
            make.centerY.equalTo(actionNameLabel.snp.centerY)
            make.width.equalTo(actionImageView.snp.height)
        }
    }
    
    private func fillCell(actionText: String, actionImage: UIImage) {
        actionNameLabel.text = actionText
        actionImageView.image = actionImage
        actionImageView.tintColor = nil
    }
}
