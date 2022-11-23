//
//  CapsuleCreateViewModel.swift
//  SpaceCapsule
//
//  Created by young june Park on 2022/11/15.
//

import Foundation
import RxCocoa
import RxSwift

final class CapsuleCreateViewModel: BaseViewModel {
    var disposeBag = DisposeBag()
    var coordinator: CapsuleCreateCoordinator?

    var input = Input()
    var output = Output()

    struct Input {
        var close = PublishSubject<Void>()
        var done = PublishSubject<Void>()
        var imageData = BehaviorRelay<[AddImageCollectionView.Cell]>(value: [.addButton])
        var title = PublishSubject<String>()
        var description = PublishSubject<String>()

        var tapDatePicker = PublishSubject<Void>()
        var tapCapsuleLocate = PublishSubject<Void>()
        
        var urlDict = BehaviorSubject<[Int: URL]>(value: [:])
        var urlArray = PublishSubject<[String]>()

        var capsuleDataObservable: Observable<Capsule> {
            Observable.combineLatest(
                title.asObservable(),
                description.asObservable(),
                urlArray.asObservable()
            ) { title, description, urlArray in
                Capsule(
                    userId: FirebaseAuthManager.shared.currentUser?.uid ?? "",
                    images: urlArray,
                    title: title,
                    description: description,
                    openCount: 0
                )
            }
        }
    }

    struct Output {
        
    }

    init() {
        bind()
    }

    private func bind() {
        // 닫기
        input.close.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.finish()
            })
            .disposed(by: disposeBag)

        // 완료
        input.urlArray
            .withLatestFrom(input.capsuleDataObservable)
            .subscribe(onNext: { capsule in
                FirestoreManager.shared.uploadCapsule(uid: FirebaseAuthManager.shared.currentUser!.uid, capsule: capsule) { error in
                    if let error = error {
                        print(" 업로드 안됨 에러남")
                    }
                }
            })
            .disposed(by: disposeBag)

        input.urlDict
            .subscribe(onNext: { [weak self] dict in
                if dict.count == self?.input.imageData.value.compactMap({ $0.data }).count {
                    let sortedArray = dict
                        .sorted(by: { $0.key < $1.key })
                        .compactMap { $0.value.absoluteString }

                    self?.input.urlArray.onNext(sortedArray)
                }
            })
            .disposed(by: disposeBag)

        input.done
            .withLatestFrom(input.imageData)
            .compactMap { $0.compactMap { $0.data } }
            .subscribe(onNext: { data in
                data.enumerated().forEach { index, dataValue in
                    FirebaseStorageManager.shared.upload(data: dataValue)
                        .subscribe(onNext: { [weak self] in
                            guard let urlDictSubject = self?.input.urlDict,
                                  var urlDict = try? urlDictSubject.value() else {
                                return
                            }

                            urlDict[index] = $0
                            urlDictSubject.onNext(urlDict)

                        })
                        .disposed(by: self.disposeBag)
                }
            })
            .disposed(by: disposeBag)

        // 날짜선택 클릭
        input.tapDatePicker.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showDatePicker()
            })
            .disposed(by: disposeBag)

        // 위치선택 클릭
        input.tapCapsuleLocate.asObservable()
            .subscribe(onNext: { [weak self] in
                self?.coordinator?.showCapsuleLocate()
            })
            .disposed(by: disposeBag)

        // address Observable in coordinator
    }

    func addImage(data: Data) {
        let imageValues = input.imageData.value

        if !imageValues.compactMap({ $0.data }).contains(data) {
            input.imageData.accept([.image(data: data)] + imageValues)
        }
    }
}
