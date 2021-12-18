//
//  WeatherInfo.swift
//  06_weather_app
//
//  Created by Jacob Ko on 2021/12/17.
//

import Foundation

// Codable 은 자신을 변환하거나, 외부표현으로 변환 할 수 있는 (예, .json) 타입을 의미함
// Codable 은 decodable(자신을 외부에 decoding 타입), encodable(자신을 외부에서 encoding 타입)
// Codable protocol 을 채택 했다는 것은 Json decoding, encoding 이 모두 가능 하다는 것임, 즉 Json <-> WeatherInfo 객체
struct WeatherInfo: Codable {
	let weather: [Weather]
	let temp: Temp
	let name: String
	
	enum CodingKeys: String, CodingKey {
		case weather
		case temp = "main"
		case name
	}
}

struct Weather: Codable {
	let id: Int
	let main: String
	let description: String
	let icon: String
}


// 만약 json의 property 이름과 type 의 이름이 다를 경우 type 내부에서 codingKeys 라는 String type 의 열거형을 선언하고 codingKey protocol 을 준수하게 만들어야 함
// main property 의 json 에서 temp struct 에 mapping 시키기 위해서 property 정의함
struct Temp: Codable {
	let temp: Double
	let feelsLike: Double
	let minTemp: Double
	let maxTemp: Double
	
	enum CodingKeys: String, CodingKey {
		case temp
		case feelsLike = "feels_like"
		case minTemp = "temp_min"
		case maxTemp = "temp_max"
	}
}
