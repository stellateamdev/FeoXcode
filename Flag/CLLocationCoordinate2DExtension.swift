//
//  CLLocationCoordinate2DExtension.swift
//  Flag
//
//  Created by marky RE on 1/8/2560 BE.
//  Copyright © 2560 marky RE. All rights reserved.
//

import Foundation
import MapKit

extension CLLocationCoordinate2D:Equatable {
    static public func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return (lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude)
    }
}
