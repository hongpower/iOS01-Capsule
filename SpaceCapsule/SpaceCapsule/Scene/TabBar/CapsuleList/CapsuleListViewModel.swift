//
//  CapsuleListViewModel.swift
//  SpaceCapsule
//
//  Created by young june Park on 2022/11/15.
//

import CoreLocation
import Foundation
import RxCocoa
import RxSwift

final class CapsuleListViewModel: BaseViewModel {
    var disposeBag = DisposeBag()
    var coordinator: CapsuleListCoordinator?
    private let currentLocation = CLLocationCoordinate2D(latitude: 37.582867, longitude: 126.027869)
    var input = Input()

    struct Input {
        var capsules: BehaviorRelay<[Capsule]> = AppDataManager.shared.capsules
        var capsuleCellModels = BehaviorRelay<[CapsuleCellModel]>(value: [])
        var sortPolicy = BehaviorRelay<SortPolicy>(value: .nearest)
        var refreshLoading = PublishRelay<Bool>()
    }

    init() {
        bind()
    }
    private func bind() {}
    
    func fetchCapsuleList() {
        input.capsules
            .withUnretained(self)
            .subscribe(
            onNext: { owner, capsuleList in
                let capsuleCellModels = capsuleList.map { capsule in
                    return CapsuleCellModel(uuid: capsule.uuid,
                                            thumbnailImageURL: capsule.images.first,
                                            address: capsule.simpleAddress,
                                            closedDate: capsule.closedDate,
                                            memoryDate: capsule.memoryDate,
                                            coordinate: CLLocationCoordinate2D(
                                                latitude: capsule.geopoint.latitude,
                                                longitude: capsule.geopoint.longitude
                                            )
                    )
                }
                owner.sort(capsuleCellModels: capsuleCellModels, by: owner.input.sortPolicy.value)
            },
            onError: { error in
                print(error.localizedDescription)
            }
        )
        .disposed(by: disposeBag)
        
    }
    
    func sort(capsuleCellModels: [CapsuleCellModel], by sortPolicy: SortPolicy) {
        var models = capsuleCellModels
        switch sortPolicy {
        case .nearest:
            models = capsuleCellModels.sorted {
                $0.distance(from: currentLocation) < $1.distance(from: currentLocation)
            }
        case .furthest:
            models = capsuleCellModels.sorted {
                $0.distance(from: currentLocation) > $1.distance(from: currentLocation)
            }
        case .latest:
            models = capsuleCellModels.sorted {
                $0.memoryDate > $1.memoryDate
            }
        case .oldest:
            models = capsuleCellModels.sorted {
                $0.memoryDate < $1.memoryDate
            }
        }
        input.capsuleCellModels.accept(models)
    }
}
