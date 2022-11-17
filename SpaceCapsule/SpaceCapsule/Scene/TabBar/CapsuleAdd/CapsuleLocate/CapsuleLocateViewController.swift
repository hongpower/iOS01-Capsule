//
//  CapsuleLocateViewController.swift
//  SpaceCapsule
//
//  Created by young june Park on 2022/11/15.
//

import CoreLocation
import MapKit
import RxSwift
import UIKit

final class CapsuleLocateViewController: UIViewController, BaseViewController {
    var disposeBag = DisposeBag()
    var viewModel: CapsuleLocateViewModel
    let capsuleMapView = CapsuleLocateView()
    let locationManager = CLLocationManager()
    
    init(viewModel: CapsuleLocateViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = capsuleMapView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        goToCurrentLocation()
        bind()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        goToCurrentLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }
    
    func bind() {
    }
    
    private func configure() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        capsuleMapView.map.delegate = self
        capsuleMapView.map.mapType = MKMapType.standard
        
        addGesture()
    }
    
    private func goToCurrentLocation() {
        guard let center = locationManager.location?.coordinate else {
            return
        }
        print(center)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: center, span: span)
        capsuleMapView.map.setRegion(region, animated: true)
    }

    private func getLocationUsagePermission() {
        locationManager.requestWhenInUseAuthorization()
    }
}

extension CapsuleLocateViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                print("GPS 권한 설정됨")
                locationManager.startUpdatingLocation()
                goToCurrentLocation()
            case .restricted, .notDetermined:
                print("GPS 권한 설정되지 않음")
                getLocationUsagePermission()
            case .denied:
                print("GPS 권한 요청 거부됨")
                getLocationUsagePermission()
            default:
                print("GPS: Default")
            }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { // 어노테이션이 유저의 현재 뷰가 아님을 보장
            return nil
        }
        
        var annotationView = capsuleMapView.map.dequeueReusableAnnotationView(withIdentifier: "spaceCapsule")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "spaceCapsule")
            annotationView?.canShowCallout = true // tap이 가능한지
            annotationView?.backgroundColor = .themeColor100
            let btn = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = btn
        } else {
            annotationView?.annotation = annotation
        }
        annotationView?.image = UIImage(systemName: "circle")
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let alertController = UIAlertController(title: "캡슐입니다", message: "해당 캡슐로 이동할까요?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let acceptAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(acceptAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated: Bool) {
        // TODO: 이 시점에 주소 업데이트
    }
}

extension CapsuleLocateViewController: UIGestureRecognizerDelegate {
    private func addGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(drag(sender:)))
        panGesture.delegate = self
        capsuleMapView.map.addGestureRecognizer(panGesture)
    }
    
    @objc func drag(sender: UIPanGestureRecognizer) {
        // TODO: 커서 뷰 색 변경
        switch sender.state {
        case .began:
            capsuleMapView.cursor.backgroundColor = .green
        case .cancelled:
            capsuleMapView.cursor.backgroundColor = .red
        case .ended:
            capsuleMapView.cursor.backgroundColor = .red
        default:
            print("unknown")
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
       return true
    }
}
