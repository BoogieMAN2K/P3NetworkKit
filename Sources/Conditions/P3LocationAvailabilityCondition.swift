//
//  P3LocationAvailabilityCondition.swift
//  P3NetworkKit
//
//  Created by Oscar Swanros on 6/20/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

import CoreLocation

public struct P3LocationAvailabilityCondition: P3OperationCondition {
    public enum Usage {
        case WhenInUse
        case Always
    }
    
    static let locationServicesEnabledKey = "CLLocationServicesEnabled"
    static let authorizationStatusKey     = "CLAuthorizationSTatus"
    public static var name                = "Location"
    public static var isMutuallyExclusive = false
    
    let usage: Usage
    
    public init(usage: Usage) {
        self.usage = usage
    }
    
    public func dependencyForOperation(operation: Operation) -> Operation? {
        return P3RequestLocationPermissionOperation(usage: usage)
    }
    
    
    public func evaluateForOperation(operation: Operation, completion: (P3OperationCompletionResult) -> Void) {
        let enabled = CLLocationManager.locationServicesEnabled()
        let actual = CLLocationManager.authorizationStatus()
        
        var error: NSError?
        
        switch (enabled, usage, actual) {
        case (true, _, .authorizedAlways):
            break
            
        case (true, .WhenInUse, .authorizedWhenInUse):
            break
            
        default:
            error = NSError(error: P3ErrorSpecification(ec: P3OperationError.ConditionFailed), userInfo: [
                P3OperationConditionKey: self.dynamicType.name,
                self.dynamicType.locationServicesEnabledKey: enabled,
                self.dynamicType.authorizationStatusKey: Int(actual.rawValue)
                ])
        }
        
        if let error = error {
            completion(.Failed(error))
        } else {
            completion(.Satisfied)
        }
    }
}

private class P3RequestLocationPermissionOperation: P3Operation {
    let usage: P3LocationAvailabilityCondition.Usage
    var manager: CLLocationManager?
    
    init(usage: P3LocationAvailabilityCondition.Usage) {
        self.usage = usage
        
        super.init()
        
        addCondition(condition: AlertPresentation())
    }
    
    private override func execute() {
        switch (CLLocationManager.authorizationStatus(), usage) {
        case (.notDetermined, _), (.authorizedWhenInUse, .Always):
            p3_executeOnMainThread {
                self.requestPermission()
            }
            
        default:
            finish()
        }
        
    }
    
    private func requestPermission() {
        manager = CLLocationManager()
        manager?.delegate = self
        let key: String
        switch usage {
        case .WhenInUse:
            key = "NSLocationWhenInUseUsageDescription"
            manager?.requestWhenInUseAuthorization()
            
        case .Always:
            key = "NSlocationAlwaysUsageDescription"
            manager?.requestAlwaysAuthorization()
        }
        
        assert(Bundle.main().objectForInfoDictionaryKey(key) != nil, "Requesting location permition requires the \(key) in the Info.plist file!")
    }
}

extension P3RequestLocationPermissionOperation: CLLocationManagerDelegate {
    private func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if manager == self.manager && isExecuting && status != .notDetermined {
            finish()
        }
    }
}