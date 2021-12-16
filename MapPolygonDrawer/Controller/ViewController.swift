//
//  ViewController.swift
//  MapPolygonDrawer
//
//  Created by Facundo Barafani on 15/12/2021.
//

import UIKit
import GoogleMaps
import MaterialComponents
import SwiftyUserDefaults
import PromiseKit

class ViewController: UIViewController {
    @IBOutlet weak var addFloatingButton: MDCFloatingButton!
    @IBOutlet weak var mapView: GMSMapView!
    var isCreatingPolygon: Bool = false
    var currentMarkers = [GMSMarker]()
    
    var userLocationCoordinate: CLLocationCoordinate2D?
    override func viewDidLoad() {
        super.viewDidLoad()
        setMapView()
        setText()
        setUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initMap()
    }
    
    @objc func setText() {}
    
    @objc func setUI() {
        addFloatingButton.setImage(R.image.images.add(), for: .normal)
        addFloatingButton.setImageTintColor(.white, for: .normal)
        addFloatingButton.setBackgroundColor(R.color.colors.primary(), for: .normal)
    }
    
    private func setMapView() {
        mapView.settings.myLocationButton = false
        mapView.isHidden = true
        mapView.isHidden = false
    }
    
    private func initMap() {
        firstly {
            CLLocationManager.requestLocation(authorizationType: .whenInUse).lastValue
        }.done { location in
            self.userLocationCoordinate = location.coordinate
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude,
                                                  zoom: 16)
            self.mapView.animate(to: camera)
            self.mapView.delegate = self
        }.catch { error in
            debugPrint("UbicacionVC-initMap-requestLocation-error \(error)")
        }
    }
    
    private func deinitMap() {
        mapView.clear()
        mapView.delegate = nil
    }
    
    @IBAction func addFloatingButtonPressed(_ sender: Any) {
        // if last state before pressing button is user not creating polygon -> now it turns into true
        if !isCreatingPolygon {
            // sets cross icon when isCreatingPolygon is turning into true
            addFloatingButton.setImage(R.image.images.close(), for: .normal)
        } else {
            // sets add icon when isCreatingPolygon is turning into false
            addFloatingButton.setImage(R.image.images.add(), for: .normal)
        }
        // Changes variable value to inverse
        isCreatingPolygon = !isCreatingPolygon
    }
    
}

extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // if user is not creating polygon -> then ignore taps at screen
        if !isCreatingPolygon {
            return
        }
        let marker = GMSMarker()
        marker.position = coordinate
        marker.map = mapView
        currentMarkers.append(marker)
        mapView.clear()
        let rect = reorderMarkersClockwise(mapView)
        for mark in currentMarkers {
            mark.map = mapView
        }
        let polygon = GMSPolygon(path: rect)
        polygon.fillColor = UIColor(red: 0.25, green: 0, blue: 0, alpha: 0.05);
        polygon.strokeColor = .black
        polygon.strokeWidth = 2
        polygon.map = mapView
    }
    
    func reorderMarkersClockwise(_ mapView: GMSMapView) -> GMSMutablePath {
        let rect = GMSMutablePath()
        let arr = currentMarkers.map{$0.position}.sorted(by: isLess)
        for pos in arr {
            rect.add(pos)
        }
        
        return rect
    }
    
    func isLess(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Bool {
        let center = getCenterPointOfPoints()
        
        if (a.latitude >= 0 && b.latitude < 0) {
            return true
        } else if (a.latitude == 0 && b.latitude == 0) {
            return a.longitude > b.longitude
        }
        
        let det = (a.latitude - center.latitude) * (b.longitude - center.longitude) - (b.latitude - center.latitude) * (a.longitude - center.longitude)
        if (det < 0) {
            return true
        } else if (det > 0) {
            return false
        }
        
        let d1 = (a.latitude - center.latitude) * (a.latitude - center.latitude) + (a.longitude - center.longitude) * (a.longitude - center.longitude)
        let d2 = (b.latitude - center.latitude) * (b.latitude - center.latitude) + (b.longitude - center.longitude) * (b.longitude - center.longitude)
        return d1 > d2
    }
    
    func getCenterPointOfPoints() -> CLLocationCoordinate2D {
        let arr = currentMarkers.map {$0.position}
        let s1: Double = arr.map{$0.latitude}.reduce(0, +)
        let s2: Double = arr.map{$0.longitude}.reduce(0, +)
        let c_lat = arr.count > 0 ? s1 / Double(arr.count) : 0.0
        let c_lng = arr.count > 0 ? s2 / Double(arr.count) : 0.0
        return CLLocationCoordinate2D.init(latitude: c_lat, longitude: c_lng)
    }
}

