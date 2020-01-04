//
//  MyWeatherAppTests.swift
//  MyWeatherAppTests
//
//  Created by Sanjay Patil on 12/17/19.
//  Copyright © 2019 Sanjay Patil. All rights reserved.
//

import XCTest
@testable import MyWeatherApp

enum Mode {
    case Day
    case Week
}

class MockURLSession:URLSessionProtocol {
    let mode:Mode
    init(mode:Mode) {
        self.mode = mode
    }
    
    let mockDataTask = MockURLDataTask()
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        // return the custom data.
        let bundle = Bundle(for: type(of: self))
        var path:String!
        if self.mode == .Day {
            path = bundle.path(forResource: "SingleDayWeather", ofType: "json")!
        } else {
            path = bundle.path(forResource: "WeekWeatherInfo", ofType: "json")!
        }
        let xmlData = NSData(contentsOfFile: path)
        completionHandler(xmlData as Data?, HTTPURLResponse(url: url,
                                               statusCode: 200,
                                               httpVersion: "HTTP/1.1",
                                               headerFields: [:]),
                          nil)
        return mockDataTask
    }
}

class MockURLDataTask: URLSessionDataTaskProtocol {
    func resume() {
        
    }
}

class MyWeatherAppTests: XCTestCase {

    var weatherModel:WeatherModel = WeatherModel()
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        CurrentLocation.sharedInstance.latitude = 35
        CurrentLocation.sharedInstance.longitude = 139
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testFetchCurrentWeatherInfo() {
        let fetcher = FetchWeatherInfo(session: MockURLSession(mode:.Day))
        fetcher.fetchCurrentWeatherInfo (completionHandler: { (model:DayModel) in
            assert(model.todayWeather == WeatherType.Clear, "Invalid weater for day!")
        }, weatherModel: self.weatherModel)
    }
    
    func testFetchWeekWeatherInfo() {
        let fetcher = FetchWeatherInfo(session: MockURLSession(mode:.Week))
        fetcher.fetchWeatherInfoForWeek (completionHandler: { (week:[DayModel]) in
            assert(self.weatherModel.weekModel.count == 5, "Invalid weater for week!")
        }, weatherModel: self.weatherModel)
    }
}
