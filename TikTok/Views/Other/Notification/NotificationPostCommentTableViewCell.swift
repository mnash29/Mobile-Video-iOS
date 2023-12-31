//
//  NotificationPostCommentTableViewCell.swift
//  TikTok
//
//  Created by mnash29 on 12/1/23.
//

import UIKit

protocol NotificationPostCommentTableViewCellDelegate: AnyObject {
    func notificationPostCommentTableViewCell(_ cell: NotificationPostCommentTableViewCell, didTapPostWith identifier: String)
}

class NotificationPostCommentTableViewCell: UITableViewCell {
    static let identifier = "NotificationPostCommentTableViewCell"

    weak var delegate: NotificationPostCommentTableViewCellDelegate?

    var postID: String?

    private let postThumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill

        return imageView
    }()

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .label

        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textColor = .secondaryLabel

        return label
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(postThumbnailImageView)
        contentView.addSubview(label)
        contentView.addSubview(dateLabel)
        selectionStyle = .none

        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapPost))
        postThumbnailImageView.addGestureRecognizer(tap)
        postThumbnailImageView.isUserInteractionEnabled = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()

        let iconSize: CGFloat = 50
        postThumbnailImageView.frame = CGRect(
            x: contentView.width - 50,
            y: 3,
            width: iconSize,
            height: contentView.height - 6
        )

        label.sizeToFit()
        dateLabel.sizeToFit()
        let labelSize = label.sizeThatFits(
            CGSize(
                width: contentView.width - 10 - postThumbnailImageView.width - 5,
                height: contentView.height - 40
            )
        )
        label.frame = CGRect(
            x: 10,
            y: 0,
            width: labelSize.width,
            height: labelSize.height
        )
        dateLabel.frame = CGRect(
            x: 10,
            y: label.bottom + 3,
            width: contentView.width - postThumbnailImageView.width,
            height: 40
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        postThumbnailImageView.image = nil
        label.text = nil
        dateLabel.text = nil
    }

    func configure(with postName: String, model: Notification) {
        postThumbnailImageView.image = UIImage(named: "test")
        label.text = model.text
        dateLabel.text = .date(with: model.date)
        postID = postName
    }

    @objc func didTapPost() {
        guard let postID = postID else { return }
        delegate?.notificationPostCommentTableViewCell(self, didTapPostWith: postID)
    }
}
