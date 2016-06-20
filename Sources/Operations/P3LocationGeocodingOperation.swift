//
//  P3LocationGeocodingOperation.swift
//  P3NetworkKit
//
//  Created by Oscar Swanros on 6/20/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

import CoreLocation

public typealias P3GeocodingCompletion = ([CLPlacemark]) -> Void

private class _GeocodeOperation: P3Operation {
    private let geoCoder = CLGeocoder()
    private var searchTerm: String
    private var completion: P3GeocodingCompletion
    
    init(searchTerm: String, completion: P3GeocodingCompletion) {
        self.searchTerm = searchTerm
        self.completion = completion
    }
    
    override func execute() {
        geoCoder.geocodeAddressString(searchTerm) { placemarks, error in
            guard let placemarks = placemarks where error != nil else {
                self.finishWithError(error: error)
                return
            }
            
            self.completion(placemarks)
            self.finish()
        }
    }
}

public class P3LocationGeocodingOperation: P3GroupOperation {
    private let geocodeOperation: _GeocodeOperation
    
    public init(searchTerm: String, completion: P3GeocodingCompletion) {
        geocodeOperation = _GeocodeOperation(searchTerm: searchTerm, completion: completion)
        geocodeOperation.addObserver(observer: NetworkActivityObserver())
        
        super.init(operations: [geocodeOperation])
        name = "Geocode Operation"
    }
}