//
//  Defaults.swift
//  MapPolygonDrawer
//
//  Created by Facundo Barafani on 16/12/2021.
//

import Foundation
import SwiftyUserDefaults

extension DefaultsKey {
    var lastUserLocation_Latitude: DefaultsKey<Double?> { .init("lastUserLocation_Latitude") }
    var lastUserLocation_Longitude: DefaultsKey<Double?> { .init("lastUserLocation_Longitude") }
}

