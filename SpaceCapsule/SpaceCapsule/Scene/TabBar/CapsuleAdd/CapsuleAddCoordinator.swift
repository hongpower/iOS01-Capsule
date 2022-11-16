//
//  CapsuleAddCoordinator.swift
//  SpaceCapsule
//
//  Created by young june Park on 2022/11/15.
//

import UIKit

class CapsuleAddCoordinator: Coordinator {
    var parent: Coordinator?
    var children: [Coordinator] = []
    var navigationController: UINavigationController?

    init() {
        navigationController = .init()
    }

    func start() {
        showCapsuleCreate()
    }

    private func showCapsuleCreate() {
        let capsuleCreateCoordinator = CapsuleCreateCoordinator(navigationController: navigationController)
        children.append(capsuleCreateCoordinator)
        capsuleCreateCoordinator.parent = self
        capsuleCreateCoordinator.start()
    }
    
   
}
