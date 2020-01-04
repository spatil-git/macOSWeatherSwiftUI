//
//  FetchWeatherInfo.swift
//  MyWeatherApp
//
//  Created by Sanjay Patil on 12/19/19.
//  Copyright © 2019 Sanjay Patil. All rights reserved.
//

import Foundation

protocol URLSessionProtocol {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

protocol URLSessionDataTaskProtocol {
    func resume() -> Void
}

class FetchWeatherInfo {
    private var session:URLSessionProtocol!
    private var weatherEndpointURL:URL? = nil
    private let latitude:String = String(CurrentLocation.sharedInstance.latitude)
    private let longitude:String = String(CurrentLocation.sharedInstance.longitude)
    let dateFormatter = DateFormatter()
    init(session:URLSessionProtocol!) {
        self.session = session
        self.dateFormatter.dateStyle = .full
        self.dateFormatter.timeStyle = .none
    }
    
    func fetchWeatherInfo(_ url:URL, completionHandler: @escaping (_ data:Data) -> Void) -> Void {
        let dataTask = session.dataTask(with: url) { (data:Data?, response:URLResponse?, error:Error?) in
            guard error == nil else {
                print("Failed to download the weather info:\(self.weatherEndpointURL!). Error:\(error!)")
                return
            }
            let httpResponse = response! as! HTTPURLResponse
            guard httpResponse.statusCode == 200 else {
                print("Download of the weaher info failed : \(httpResponse.description)")
                return
            }
            completionHandler(data!)
            
        }
        dataTask.resume()
    }
}

extension FetchWeatherInfo {
    func fetchCurrentWeatherInfo(completionHandler: @escaping (_ model:DayModel) -> Void, weatherModel:WeatherModel) -> Void {
        var urlComponents = URLComponents(string: weatherAPI)!
        urlComponents.scheme = "http"
        let latQueryItems = URLQueryItem(name: "lat", value: latitude)
        let longQueryItems = URLQueryItem(name: "lon", value: longitude)
        let apiKey = URLQueryItem(name: "appid", value: apiKEY)
        let unit = URLQueryItem(name:"units", value:"imperial")
        urlComponents.queryItems = [latQueryItems, longQueryItems, unit, apiKey]
        weatherEndpointURL = urlComponents.url
        fetchWeatherInfo(weatherEndpointURL!) { (data:Data) in
            do {
                let dict:[String: Any] = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                let currentWeather = (dict["weather"] as! Array<Dictionary<String, Any>>)[0]
                let model = weatherModel.dayModel
                model.location = dict["name"] as! String
                model.today = Date(timeIntervalSince1970: dict["dt"] as! TimeInterval)
                model.dateStr = self.dateFormatter.string(from: model.today)
                model.temperature = String((dict["main"] as! [String:Double])["temp"]!)
                model.temperatureMin = String((dict["main"] as! [String:Double])["temp_min"]!)
                model.temperatureMax = String((dict["main"] as! [String:Double])["temp_max"]!)
                model.todayWeather = WeatherType(rawValue: currentWeather["main"] as! String)!
                completionHandler(model)
            } catch {
                print("Weather model parsing failed:\(error)")
            }
        }
    }
}

extension FetchWeatherInfo {
    func fetchWeatherInfoForWeek(completionHandler: @escaping (_ model:[DayModel]) -> Void, weatherModel:WeatherModel) -> Void {
        var urlComponents = URLComponents(string: weekWeatherAPI)!
        urlComponents.scheme = "http"
        let latQueryItems = URLQueryItem(name: "lat", value: latitude)
        let longQueryItems = URLQueryItem(name: "lon", value: longitude)
        let apiKey = URLQueryItem(name: "appid", value: apiKEY)
        urlComponents.queryItems = [latQueryItems, longQueryItems, apiKey]
        let url = urlComponents.url
        fetchWeatherInfo(url!) { (data:Data) in
            do {
                let dict:[String: Any] = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                let list = (dict["list"] as! Array<Dictionary<String, Any>>)
                var index = 0
                weatherModel.weekModel.removeAll();
                while index < list.count {
                    let model:[String:Any] = list[index]
                    let weather:[[String:AnyObject]] = model["weather"]! as! [[String : AnyObject]]
                    let temperature:[String:AnyObject] = model["main"]! as! [String : AnyObject]
                    let dayModel = DayModel()
                    let currentWeather = weather[0]
                    dayModel.today = Date(timeIntervalSince1970: model["dt"] as! TimeInterval)
                    dayModel.dateStr = self.dateFormatter.string(from: dayModel.today)
                    dayModel.temperature = String(temperature["temp"] as! Double)
                    dayModel.temperatureMin = String(temperature["temp_min"] as! Double)
                    dayModel.temperatureMax = String(temperature["temp_max"] as! Double)
                    dayModel.todayWeather = WeatherType(rawValue: currentWeather["main"] as! String)!
                    weatherModel.weekModel.append(dayModel)
                    // Hack to get thedaily temp as forecast API is not free anymore
                    index += 8
                }
                completionHandler(weatherModel.weekModel)
            } catch {
                print("Weather model parsing failed:\(error)")
            }
        }
    }
}

// MARK:For injecting the custom object with the help of DI.
extension URLSession:URLSessionProtocol {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        // so that we can return our own custom "DataTak" and handle resume.
        return (dataTask(with: url, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}

extension URLSessionDataTask:URLSessionDataTaskProtocol {
    
}
