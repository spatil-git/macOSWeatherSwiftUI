//
//  ContentView.swift
//  MyWeatherApp
//
//  Created by Sanjay Patil on 12/17/19.
//  Copyright © 2019 Sanjay Patil. All rights reserved.
//

import SwiftUI

struct Test {
    var test:String = ""
}

struct WeatherContentView: View {
    @EnvironmentObject var currentWeather:WeatherModel
    var testObj:Test = Test()
    var testStr = ""
    var body: some View {
        VStack {
            Text("\(currentWeather.dayModel.dateStr)").bold()
            Text("\(currentWeather.dayModel.location)").bold()
            Image("\(currentWeather.dayModel.todayWeather.rawValue)").resizable().frame(width: 50, height: 50, alignment: .center)
            HStack {
                Text("\(currentWeather.dayModel.temperatureMin)").bold()
                Text("\(currentWeather.dayModel.temperatureMax)").bold()
            }
            Text(currentWeather.dayModel.todayWeather.rawValue).bold()
            HStack {
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack {
                        ForEach(currentWeather.weekModel) { model in
                            WeekWeather(model: model)
                        }
                    }
                }
            }
        }.background(Color.blue)
    }
}

// Show the weather of the rest of the week.
struct WeekWeather:View {
    let model:DayModel
    init(model:DayModel) {
        self.model = model
    }
    var body: some View {
        VStack {
            Text(model.dateStr).bold()
            Image("\(model.todayWeather.rawValue)").resizable().frame(width: 50, height: 50, alignment: .center)
            HStack {
                Text("\(model.temperatureMin)").bold()
                Text("\(model.temperatureMax)").bold()
            }
        }.padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WeatherContentView()
    }
}
