//
//  NotificationUserFollowTableViewCell.swift
//  TikTok
//
//  Created by mnash29 on 12/1/23.
//

import UIKit

class NotificationUserFollowTableViewCell: UITableViewCell {
    static let identifier = "NotificationUserFollowTableViewCell"

    private let avatarImageView: UIImageView = {
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

    private let followButton: UIButton = {
        let button = UIButton()
        button.setTitle("Follow", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 6
        button.layer.masksToBounds = true

        return button
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.clipsToBounds = true
        contentView.addSubview(avatarImageView)
        contentView.addSubview(followButton)
        contentView.addSubview(label)
        contentView.addSubview(dateLabel)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()

        let iconSize: CGFloat = 50
        avatarImageView.layer.cornerRadius = 25
        avatarImageView.layer.masksToBounds = true
        avatarImageView.frame = CGRect(
            x: 10,
            y: 3,
            width: iconSize,
            height: iconSize
        )        

        followButton.sizeToFit()
        followButton.frame = CGRect(
            x: contentView.width - 110,
            y: 10,
            width: 100,
            height: 30
        )

        label.sizeToFit()
        dateLabel.sizeToFit()
        let labelSize = label.sizeThatFits(
            CGSize(
                width: contentView.width - 30 - followButton.width - iconSize,
                height: contentView.height - 40
            )
        )
        label.frame = CGRect(
            x: avatarImageView.right + 10,
            y: 0,
            width: labelSize.width,
            height: labelSize.height
        )
        dateLabel.frame = CGRect(
            x: avatarImageView.right + 10,
            y: label.bottom + 3,
            width: contentView.width - avatarImageView.width - followButton.width,
            height: 40
        )
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        label.text = nil
        dateLabel.text = nil
    }

    func configure(with username: String, model: Notification) {
        avatarImageView.image = UIImage(named: "test")
        label.text = model.text
        dateLabel.text = .date(with: model.date)
    }
}
