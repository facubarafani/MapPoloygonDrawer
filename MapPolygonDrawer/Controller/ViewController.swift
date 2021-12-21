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
    @IBOutlet weak var undoFloatingButton: MDCFloatingButton!
    @IBOutlet weak var confirmFloatingButton: MDCFloatingButton!
    @IBOutlet weak var optionsStackView: UIStackView!
    
    var isCreatingPolygon: Bool = false {
        didSet {
            displayOptions()
        }
    }
    var currentPolygon = Polygon()
    var currentMarkers = [GMSMarker]()
    var currentGMapsPolygon = GMSPolygon()
    var mapPolygons = [GMSPolygon]() {
        didSet {
            mapPolygons.forEach { $0.map = self.mapView }
        }
    }
    
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
        // Options StackView initial state
        optionsStackView.subviews.forEach { $0.isHidden = true }
        
        // Add Floating Button
        addFloatingButton.setImage(R.image.images.add(), for: .normal)
        addFloatingButton.setImageTintColor(.white, for: .normal)
        addFloatingButton.setBackgroundColor(R.color.colors.primary(), for: .normal)
        
        // Confirm Floating Button
        confirmFloatingButton.setImage(R.image.images.done(), for: .normal)
        confirmFloatingButton.setImageTintColor(.white, for: .normal)
        confirmFloatingButton.setBackgroundColor(R.color.colors.green(), for: .normal)
        
        // Undo Floating Button
        undoFloatingButton.setImage(R.image.images.undo(), for: .normal)
        undoFloatingButton.setImageTintColor(.white, for: .normal)
        undoFloatingButton.setBackgroundColor(R.color.colors.primary(), for: .normal)
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
            
            self.fetchLocallyStoredPolygons()
        }.catch { error in
            self.view.makeToast("Error while attempting to init map.")
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
            addFloatingButton.setBackgroundColor(R.color.colors.secondary(), for: .normal)
            addFloatingButton.setImage(R.image.images.close(), for: .normal)
        } else {
            // sets add icon when isCreatingPolygon is turning into false
            currentMarkers.removeAll()
            currentPolygon = Polygon()
            clearMap()
            addFloatingButton.setBackgroundColor(R.color.colors.primary(), for: .normal)
            addFloatingButton.setImage(R.image.images.add(), for: .normal)
        }
        // Changes variable value to inverse
        isCreatingPolygon = !isCreatingPolygon
    }
    
    @IBAction func confirmFloatingButtonPressed(_ sender: Any) {
        savePolygonAndEmptyCurrentPolygon()
        addFloatingButton.setBackgroundColor(R.color.colors.primary(), for: .normal)
        addFloatingButton.setImage(R.image.images.add(), for: .normal)
        addFloatingButton.setImageTintColor(.white, for: .normal)
        // Changes variable value to inverse
        isCreatingPolygon = !isCreatingPolygon
    }
    
    
    @IBAction func undoFloatingButtonPressed(_ sender: Any) {
        // If there is at least a marker on the map
        if !currentPolygon.points.isEmpty {
            if let lastMarker = currentMarkers.last {
                // remove last point stored in Polygon structure
                currentPolygon.undoLastPoint()
                // remove its marker from the mapview
                lastMarker.map = nil
                currentMarkers.removeLast()
                // redraw polygon based on current point
                currentGMapsPolygon.map = nil
                drawPolygonBasedOnCurrentPoints()
            }
        } else {
            self.view.makeToast("No points left to undo.")
        }
    }
    
    private func savePolygonAndEmptyCurrentPolygon() {
        if !currentPolygon.points.isEmpty {
            PolygonRepository.shared.store(polygon: currentPolygon)
                .done {
                    self.currentGMapsPolygon = GMSPolygon()
                    self.currentPolygon = Polygon()
                    self.currentMarkers.removeAll()
                    self.fetchLocallyStoredPolygons()
                    self.clearMap()
                    self.view.makeToast("Polygon saved successfully.")
                }
                .catch { error in
                    self.view.makeToast("Error occurred when attempting to save polygon")
                }
        } else {
            self.view.makeToast("You can't save an empty polygon. Try again.")
        }
    }
    
    private func clearMap() {
        mapView.clear()
        mapPolygons.forEach { $0.map = self.mapView }
    }
    
    private func fetchLocallyStoredPolygons() {
        PolygonRepository.shared.fetchAll()
            .done { polygons in
                let gMapsPolygons = polygons.map { $0.getGMSPolygon() }
                self.mapPolygons = gMapsPolygons
            }
            .catch { _ in
                self.view.makeToast("Error attempting to fetch locally stored polygons.")
            }
    }
    
    private func displayOptions() {
        UIView.animate(
            withDuration: 0.2, delay: 0, options: .curveEaseIn,
            animations: {
                self.optionsStackView.subviews.forEach {
                    $0.isHidden = !$0.isHidden
                }
            })
    }
    
    func drawPolygonBasedOnCurrentPoints() {
        let polygon = currentPolygon.getGMSPolygon()
        currentGMapsPolygon = polygon
        polygon.map = mapView
    }
}

extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        // if user is not creating polygon -> then ignore taps at screen
        if !isCreatingPolygon {
            return
        }
        // On each coordinate where user tapped generates a marker
        let point = Point(coordinate: coordinate)
        let marker = point.toMarker()
        marker.map = mapView
        currentPolygon.points.append(point)
        clearMap()
        for p in currentPolygon.points {
            let m = p.toMarker()
            m.map = mapView
            currentMarkers.append(m)
        }
        drawPolygonBasedOnCurrentPoints()
    }
}

