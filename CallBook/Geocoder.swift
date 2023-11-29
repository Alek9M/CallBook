//
//  Geocoder.swift
//  CallBook
//
//  Created by M on 29/11/2023.
//

import Foundation
import CoreLocation
import MapKit

class PostcodeGeocoder {
    static func coordinateRegion(for postcode: String) async throws -> MKCoordinateRegion {
        let geocoder = CLGeocoder()

        do {
            let placemarks = try await geocoder.geocodeAddressString(postcode)

            guard let location = placemarks.first?.location else {
                throw NSError(domain: "GeocodingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid postcode"])
            }

            let coordinate = location.coordinate
            let region = MKCoordinateRegion(
                center: coordinate,
                latitudinalMeters: 10000,
                longitudinalMeters: 10000
            )

            return region
        } catch {
            throw error
        }
    }
}
