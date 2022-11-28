//
//  CapsuleCloseView.swift
//  SpaceCapsule
//
//  Created by young june Park on 2022/11/15.
//

import AVFoundation
import SnapKit
import UIKit

final class CapsuleCloseView: UIView, BaseView {
    struct Item {
        let closedDateString: String
        let memoryDateString: String
        let simpleAddress: String
        let thumbnailImageURL: String
    }

    private let thumbnailImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = FrameResource.capsuleThumbnailWidth / 2
        imageView.clipsToBounds = true

        return imageView
    }()

    private let thumbnailImageContainerView = {
        let view = UIView()
        view.layer.shadowOffset = FrameResource.shadowOffset
        view.layer.shadowRadius = FrameResource.shadowRadius
        view.layer.shadowOpacity = FrameResource.shadowOpacity
        view.layer.cornerRadius = FrameResource.capsuleThumbnailWidth / 2
        return view
    }()

    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.layer.cornerRadius = FrameResource.capsuleThumbnailWidth / 2
        blurEffectView.clipsToBounds = true

        return blurEffectView
    }()

    private let closedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .lock
        imageView.tintColor = .themeGray200

        return imageView
    }()

    private let closedDateLabel = ThemeLabel(size: FrameResource.fontSize90, color: .themeGray200)

    private let descriptionLabel = {
        let label = ThemeLabel(size: FrameResource.fontSize140, color: .themeGray300)
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()

    let closeButton = {
        let button = UIButton()
        button.titleLabel?.font = .themeFont(ofSize: FrameResource.fontSize100)
        button.setTitle("완료", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .themeColor200
        button.layer.cornerRadius = FrameResource.commonCornerRadius

        return button
    }()

    // MARK: - Lifecycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        addSubViews()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Methods

    func configure() {
        backgroundColor = .themeBackground
    }

    func configure(item: Item) {
        closedDateLabel.text = "밀봉시간: \(item.closedDateString)"

        descriptionLabel.text = """
        \(item.memoryDateString)
        \(item.simpleAddress) 에서의
        추억이 담긴 캡슐을 보관하였습니다.
        """

        descriptionLabel.asFontColor(
            targetStringList: [item.memoryDateString, item.simpleAddress],
            size: FrameResource.fontSize140,
            color: .themeGray400
        )

        thumbnailImageView.kr.setImage(with: item.thumbnailImageURL, scale: FrameResource.closedImageScale)
    }

    func addSubViews() {
        [blurEffectView, closedImageView, closedDateLabel].forEach {
            thumbnailImageView.addSubview($0)
        }

        [thumbnailImageContainerView, descriptionLabel, closeButton].forEach {
            addSubview($0)
        }

        thumbnailImageContainerView.addSubview(thumbnailImageView)
    }

    func makeConstraints() {
        blurEffectView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalToSuperview()
        }

        closedImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(FrameResource.closedIconSize)
        }

        closedDateLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(closedImageView.snp.bottom).offset(FrameResource.closedDateOffset)
        }

        thumbnailImageContainerView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().multipliedBy(0.8)
            $0.width.equalTo(FrameResource.capsuleThumbnailWidth)
            $0.height.equalTo(FrameResource.capsuleThumbnailHeight)
        }

        thumbnailImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        descriptionLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(closeButton.snp.top).offset(-FrameResource.buttonHeight)
        }

        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(FrameResource.horizontalPadding)
            $0.trailing.equalToSuperview().offset(-FrameResource.horizontalPadding)
            $0.bottom.equalToSuperview().offset(-FrameResource.buttonHeight)
            $0.height.equalTo(FrameResource.buttonHeight)
        }
    }

    func animate() {
        UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse]) {
            self.thumbnailImageContainerView.transform = .init(translationX: 0, y: FrameResource.floatingOffsetY)
        }
    }
}
