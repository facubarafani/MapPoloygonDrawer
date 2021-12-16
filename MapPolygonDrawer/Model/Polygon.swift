//
//  Polygon.swift
//  MapPolygonDrawer
//
//  Created by Facundo Barafani on 16/12/2021.
//

import Foundation
import RealmSwift
import GoogleMaps

@objcMembers class Polygon: Object {
    let points = List<Point>()
    
    func getGMSPolygon() -> GMSPolygon {
        let polygon = GMSPolygon(path: self.generateMutablePathFromPoints())
        polygon.fillColor = R.color.colors.primary()?.withAlphaComponent(0.05)
        polygon.strokeColor = R.color.colors.primary()
        polygon.strokeWidth = 2
        return polygon
    }
    
    private func generateMutablePathFromPoints() -> GMSMutablePath {
        let path = GMSMutablePath()
        let arr = points.map {$0.coordinate}.sorted(by: isLess)
        for point in arr {
            path.add(point)
        }
        return path
    }
    
    private func isLess(_ a: CLLocationCoordinate2D, _ b: CLLocationCoordinate2D) -> Bool {
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
    
    private func getCenterPointOfPoints() -> CLLocationCoordinate2D {
        let arr = points.map {$0.coordinate}
        let s1: Double = arr.map{$0.latitude}.reduce(0, +)
        let s2: Double = arr.map{$0.longitude}.reduce(0, +)
        let c_lat = arr.count > 0 ? s1 / Double(arr.count) : 0.0
        let c_lng = arr.count > 0 ? s2 / Double(arr.count) : 0.0
        return CLLocationCoordinate2D.init(latitude: c_lat, longitude: c_lng)
    }
}
