//
//  CapsuleDetailView.swift
//  SpaceCapsule
//
//  Created by young june Park on 2022/11/15.
//

import UIKit
import MapKit

final class CapsuleDetailView: UIView, BaseView {
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = FrameResource.spacing80
        return stackView
    }()
    
    private let closingDateView: UILabel = {
        let label = UILabel()
        label.textColor = .themeGray300
        label.font = .themeFont(ofSize: 16)
        return label
    }()
    
    private let contentView: UIView = {
       let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    private let mapView: UIView = {
        let mapView = UIView()
        mapView.backgroundColor = .gray
        return mapView
    }()
    
    private let imageCollectionView: ContentImageCollectionView = {        
        let collectionView = ContentImageCollectionView(frame: .zero)
        collectionView.alwaysBounceHorizontal = true
        collectionView.backgroundColor = .brown
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageCollectionView.delegate = self
        imageCollectionView.dataSource = self

        configure()
        addSubViews()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        closingDateView.text = "밀봉시간: 2010년 7월 1일"
    }
    
    func addSubViews() {
        [imageCollectionView,
         closingDateView,
         contentView,
         mapView
        ].forEach {
            mainStackView.addArrangedSubview($0)
        }
        
        self.addSubview(mainStackView)
    }
    
    func makeConstraints() {
        mainStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        imageCollectionView.snp.makeConstraints {
            $0.height.equalTo(FrameResource.detailImageViewHeight)
        }
        
        contentView.snp.makeConstraints {
            $0.height.equalTo(500)
        }
        
        mapView.snp.makeConstraints {
            $0.height.equalTo(600)
        }
    }
}

extension CapsuleDetailView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: ContentImageCell.identifier, for: indexPath)
    }
}
