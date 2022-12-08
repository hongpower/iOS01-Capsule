//
//  DetailImageViewController.swift
//  SpaceCapsule
//
//  Created by 장재훈 on 2022/12/06.
//

import RxSwift
import UIKit

final class DetailImageViewController: UIViewController {
    var disposeBag = DisposeBag()
    var viewModel: DetailImageViewModel?

//    private let mainView = ZoomableImageView()
    private let mainView = DetailImageView()
    private var dataSource: UICollectionViewDiffableDataSource<Int, Data>?

    override func loadView() {
        view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        applyDataSource()

        viewModel?.fetchData()
    }

    private func bind() {
        viewModel?.output.imageData
            .subscribe(onNext: { [weak self] imageData in
                let index = imageData.index
                self?.applySnapshot(items: imageData.data)

                self?.mainView.itemCount = imageData.data.count
                self?.mainView.currentIndex = index

                DispatchQueue.main.async {
                    self?.mainView.collectionView.scrollToItem(
                        at: IndexPath(item: index, section: 0),
                        at: .top,
                        animated: true
                    )
                }

            })
            .disposed(by: disposeBag)

        mainView.closeButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.viewModel?.input.tapClose.onNext($0)
            })
            .disposed(by: disposeBag)
    }
}

extension DetailImageViewController {
    private func applyDataSource() {
        mainView.collectionView.register(ZoomableImageCell.self, forCellWithReuseIdentifier: ZoomableImageCell.identifier)

        dataSource = UICollectionViewDiffableDataSource(collectionView: mainView.collectionView, cellProvider: { collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZoomableImageCell.identifier, for: indexPath) as? ZoomableImageCell else {
                return UICollectionViewCell()
            }

            cell.configure(data: item)

            return cell
        })
    }

    private func applySnapshot(items: [Data]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, Data>()
        snapshot.appendSections([0])
        snapshot.appendItems(items, toSection: 0)
        dataSource?.apply(snapshot)
    }
}