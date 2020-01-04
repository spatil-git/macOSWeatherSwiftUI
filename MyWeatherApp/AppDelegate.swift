//
//  AppDelegate.swift
//  MyWeatherApp
//
//  Created by Sanjay Patil on 12/17/19.
//  Copyright © 2019 Sanjay Patil. All rights reserved.
//

import Cocoa
import SwiftUI
import CoreLocation

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, CLLocationManagerDelegate {

    var window: NSWindow!
    let locationManager = CLLocationManager()
    var location:CLLocation!
    var weatherModel:WeatherModel = WeatherModel()
    
    // Adjust length as per content.
    let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // load status item.
        statusBarItem.button?.title = "--°"
        statusBarItem.button!.action = #selector(AppDelegate.loadContent(_:))
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.distanceFilter = 1000
        locationManager.startUpdatingLocation()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func loadContent(_ sender:AnyObject) -> Void {
        let contentView = WeatherContentView()
        let popover = NSPopover()
        // Host the SwiftUI view as AppKit view controller.
        popover.contentViewController = NSHostingController(rootView: contentView.environmentObject(weatherModel))
        popover.behavior = .transient
        popover.show(relativeTo: statusBarItem.button!.bounds, of: statusBarItem.button!, preferredEdge: .maxY)
    }
    
    fileprivate func fetchWeatherNow() {
        let fetcher = FetchWeatherInfo(session: URLSession.shared)
        fetcher.fetchCurrentWeatherInfo(completionHandler: { [unowned self] (day:DayModel) in
            fetcher.fetchWeatherInfoForWeek(completionHandler: { (week:[DayModel]) in
                print("Updated weather model...")
                DispatchQueue.main.async {
                    self.statusBarItem.button?.title = day.temperature + "°F"
                }
            }, weatherModel: self.weatherModel)
            }, weatherModel: self.weatherModel)
        self.locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations[locations.count-1]
        CurrentLocation.sharedInstance.latitude = location.coordinate.latitude
        CurrentLocation.sharedInstance.longitude = location.coordinate.longitude
        fetchWeatherNow()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("\(error)")
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Auth: \(status)")
    }
}

