//
//  AddImageCollectionViewCell.swift
//  SpaceCapsule
//
//  Created by 장재훈 on 2022/11/19.
//

import SnapKit
import UIKit

final class AddImageCollectionViewCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill

        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubViews()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(item: String) {
        imageView.image = UIImage(named: item)
    }

    private func addSubViews() {
        addSubview(imageView)
    }

    private func makeConstraints() {
        imageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
    }
}
