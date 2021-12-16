//
//  Polygon.swift
//  MapPolygonDrawer
//
//  Created by Facundo Barafani on 16/12/2021.
//

import Foundation
import RealmSwift

@objcMembers class Polygon: Object {
    dynamic var points = [Point]()
}
