//
//  MapViewController.swift
//  MapProject
//
//  Created by 김태현 on 2022/08/11.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var annotationList: [MKPointAnnotation] = []
    var theaterList: [Theater] = TheaterList().mapAnnotations
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        designNavigationBar()

        locationManager.delegate = self
        
        // 37.517829, 126.886270
        let center = CLLocationCoordinate2D(latitude: 37.517829, longitude: 126.886270)
        setRegionAndAnnotation(center: center, regionTitle: "새싹 캠퍼스")
    }
    
    func setRegionAndAnnotation(center: CLLocationCoordinate2D, regionTitle: String) {
        annotationList = []
        
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = regionTitle
        
        annotationList.append(annotation)
        
        mapView.addAnnotations(annotationList)
    }

    func designNavigationBar() {
        
        title = "영화관 찾기"
                
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(showAlertController))
    }


    @IBAction func tappedFilterButton(_ sender: UIButton) {
        
        showAlertController()
    }
}



extension MapViewController {
        
    func checkUserDeviceLocationServiceAuthorization() {
        
        let authorizationStatus: CLAuthorizationStatus
        
        if #available(iOS 14.0, *) {
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        if CLLocationManager.locationServicesEnabled() {
            
            checkUserCurrentLocationAuthorization(authorizationStatus)
        } else {
            
            showRequestLocationServiceAlert()
            print("위치 서비스가 꺼져있음.")
        }
    }
    
    func checkUserCurrentLocationAuthorization(_ authorizationStatus: CLAuthorizationStatus) {
        
        switch authorizationStatus {
        case .notDetermined:
            
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            
            print("앱의 위치권한 미허용")
        case .authorizedWhenInUse:
            
            print("위치권한 허용")
            locationManager.startUpdatingLocation()
        default:
            print("DEFAULT")
        }
    }
    
    func showRequestLocationServiceAlert() {
          let requestLocationServiceAlert = UIAlertController(title: "위치정보 이용", message: "위치 서비스를 사용할 수 없습니다. 기기의 '설정>개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
          let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            
              if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                  UIApplication.shared.open(appSetting)
              }
          }
          let cancel = UIAlertAction(title: "취소", style: .default)
          requestLocationServiceAlert.addAction(cancel)
          requestLocationServiceAlert.addAction(goSetting)

            
          present(requestLocationServiceAlert, animated: true, completion: nil)
    }
    
    @objc
    func showAlertController() {
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let mega = UIAlertAction(title: "메가박스", style: .default) { value in
            
            self.annotationList = []
            
            for t in self.theaterList {
                if t.type == value.title {
                    let center = CLLocationCoordinate2D(latitude: t.latitude, longitude: t.longitude)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = center
                    annotation.title = value.title
                    self.annotationList.append(annotation)
                }
            }
            
            self.mapView.addAnnotations(self.annotationList)
        }
        let lotte = UIAlertAction(title: "롯데시네마", style: .default) { value in
            self.annotationList = []
            
            for t in self.theaterList {
                if t.type == value.title {
                    let center = CLLocationCoordinate2D(latitude: t.latitude, longitude: t.longitude)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = center
                    annotation.title = value.title
                    self.annotationList.append(annotation)
                }
            }
            
            self.mapView.addAnnotations(self.annotationList)
        }
        let cgv = UIAlertAction(title: "CGV", style: .default) { value in
            self.annotationList = []
            
            for t in self.theaterList {
                if t.type == value.title {
                    let center = CLLocationCoordinate2D(latitude: t.latitude, longitude: t.longitude)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = center
                    annotation.title = value.title
                    self.annotationList.append(annotation)
                }
            }
            
            self.mapView.addAnnotations(self.annotationList)
        }
        let all = UIAlertAction(title: "전체보기", style: .default) { value in
            self.annotationList = []
            
            for t in self.theaterList {
                let center = CLLocationCoordinate2D(latitude: t.latitude, longitude: t.longitude)
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = t.type
                self.annotationList.append(annotation)
            
            }
            
            self.mapView.addAnnotations(self.annotationList)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(mega)
        alert.addAction(lotte)
        alert.addAction(cgv)
        alert.addAction(all)
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil)
    }
}



extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("정보 수신 성공")
        
        if let coordinate = locations.last?.coordinate {
            
            setRegionAndAnnotation(center: coordinate, regionTitle: "당신의 현재위치")
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 정보 못 가져옴")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkUserDeviceLocationServiceAuthorization()
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkUserDeviceLocationServiceAuthorization()
    }
}


extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        locationManager.startUpdatingLocation()
    }
}
