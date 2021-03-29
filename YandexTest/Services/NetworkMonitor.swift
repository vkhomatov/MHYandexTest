//
//  NetworkMonitor.swift
//  YandexTest
//
//  Created by Vitaly Khomatov on 25.03.2021.
//

import Network

final class NetworkMonitor {
    let monitor = NWPathMonitor()
    
    init() {
        let queue = DispatchQueue(label: "Monitor")
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
    
    func getNetworkStatus() -> Bool {
        if monitor.currentPath.status == NWPath.Status.unsatisfied  || monitor.currentPath.status == NWPath.Status.requiresConnection {
            return false
        } else {
            return true
        }
    }
    
 
}
