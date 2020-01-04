//
//  WeatherModel.swift
//  MyWeatherApp
//
//  Created by Sanjay Patil on 12/19/19.
//  Copyright © 2019 Sanjay Patil. All rights reserved.
//

import Foundation
import Combine

enum WeatherType:String {
    case Clear
    case Snow
    case Rain
    case Fog
    case Mist
    case Clouds
    case None
}

class WeatherModel: ObservableObject {
    @Published var test:String = ""
    @Published var dayModel:DayModel = DayModel()
    @Published var weekModel:[DayModel] = []
    var dayAnyCancellable: AnyCancellable? = nil
    var weekAnyCancellable: AnyCancellable? = nil
    init() {
        dayAnyCancellable = dayModel.objectWillChange.sink { (_) in
            self.objectWillChange.send()
        }
    }
}

class DayModel: ObservableObject,Identifiable {
    @Published var dateStr:String = ""
    @Published var today:Date = Date()
    @Published var todayWeather:WeatherType = .None
    @Published var location:String = "Not Available"
    @Published var temperature:String = "---"
    @Published var temperatureMin:String = "---"
    @Published var temperatureMax:String = "---"
}
