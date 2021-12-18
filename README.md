# ⛅️ weatherApp-iOS-practice

![Kapture 2021-12-18 at 15 00 18](https://user-images.githubusercontent.com/28912774/146631143-7524bfb4-5f84-416c-a316-3d9d56ea21db.gif)

## 📌 기능 상세

- 도시 이름을 입력하면 현재 날씨 정보를 가져와 화면에 표시되게 만들어야 합니다

- 도시 이름을 잘못 입력하면 서버로부터 응답받은 에러 메시지가 alert으로 표시 됩니다

## 🔑 Check Point !

![image](https://user-images.githubusercontent.com/28912774/146631112-f5bb1378-ac2e-4dfe-bcb1-d790392ec992.png)

### 🔷 Current Weather API (OpenWeather API)

#### json 과 struct 구조체(model) mapping 하기

![image](https://user-images.githubusercontent.com/28912774/146618816-114981b1-717a-43c3-be8d-e336b498637a.png)

```swift
// WeatherInfo.swift

import Foundation

// Codable 은 자신을 변환하거나, 외부표현으로 변환 할 수 있는 (예, .json) 타입을 의미함
// Codable 은 decodable(자신을 외부에 decoding 타입), encodable(자신을 외부에서 encoding 타입)
// Codable protocol 을 채택 했다는 것은 Json decoding, encoding 이 모두 가능 하다는 것임, 즉 Json <-> WeatherInfo 객체
struct WeatherInfo: Codable {
	let weather: [Weather]
	let temp: Temp
	let nameL: String

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
```

#### response 한 data를 UI 에 업데이트

```swift
//

// UI창에 weatherInfo 가 나타나게 하는 method
func configureView(weatherInfo: WeatherInfo) {
	self.cityNameLabel.text = weatherInfo.name
	// weatherInfor 안에 wather 의 첫번째 상수에 대입
	if let weather = weatherInfo.weather.first {
		self.weatherDescriptionLabel.text = weather.description
	}
	self.tempLabel.text = "\(Int(weatherInfo.temp.temp))°C"
	self.minTempLabel.text = "최저: \(Int(weatherInfo.temp.minTemp))°C"
	self.maxTempLabel.text = "최고: \(Int(weatherInfo.temp.maxTemp))°C"
}
```

- 도시의 현재 날씨 정보를 가져옵니다

### 🔷 URLSession

```swift
func getCurrentWeather(cityName: String) {
	guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&units=metric&lang=kr&appid=0fb8463dce1de96897cba0b1eff08e18") else { return }
	// session 을 default session 으로 설정
	let session = URLSession(configuration: .default)
	// compression handler 로써 closure 매개 변수에 data(서버에서 응답 받은 data), response(HTTP header 나 상태 코드의 metaData), error(error 코드 반환)
	session.dataTask(with: url) { [weak self] data, response, error in
......
	}
```

> Describing check point in details in Jacob's DevLog - https://jacobko.info/ios/ios-06/

## ❌ Error Check Point

### 🔶 API Response Error 발생시 Error 처리

![image](https://user-images.githubusercontent.com/28912774/146629837-ece86509-5b1e-4909-8a35-93463e0a82d5.png)

위와 같이 textField 에서 도시이름이 오타나 검색이 되지 않으면, 404 error 가 발생합니다. 그럴때 alert 창으로 **도시이름이 일치하지 않습니다** 라는 나오게 하는 code 는 다음과 같습니다

- Error message 처리를 위한 struct 모델 생성

```swift
// in ViewController.swift

// Error message 가 alert 에 표시되게 하는 logic
func showAlert(message: String) {
	let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
	alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
	self.present(alert, animated: true, completion: nil)
}

// URLSession 을 이용해서 currentWeather API를 호출하기
func getCurrentWeather(cityName: String) {
	guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&units=metric&lang=kr&appid=0fb8463dce1de96897cba0b1eff08e18") else { return }
	// session 을 default session 으로 설정
	let session = URLSession(configuration: .default)
	// compression handler 로써 closure 매개 변수에 data(서버에서 응답 받은 data), response(HTTP header 나 상태 코드의 metaData), error(error 코드 반환)
	session.dataTask(with: url) { [weak self] data, response, error in
		// 응답받은 response (json data)를 weatherInfo struct 에 decoding 되게 하는 logic
		let successRange = (200..<300)
		guard let data = data, error == nil else { return }
		let decorder = JSONDecoder()
		// 응답받은 data 의 statusCode 가 200번대 (200 ~ 299) 일때
		if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
			guard let weatherInfo =  try? decorder.decode(WeatherInfo.self, from: data) else { return }
			// debugPrint(weatherInfo)
			// 받아온 데이터를 UI 에 표시하기 위해서는 main thread 에서 작업을 진행 햐여 됩
			DispatchQueue.main.async {
				self?.weatherStackView.isHidden = false
				self?.configureView(weatherInfo: weatherInfo)
				}
			} else { // status code 가 200 번대가 아니면 error 상태 이니까 error message 생성 logic
				guard let errorMessage = try? decorder.decode(ErrorMessage.self, from: data) else { return }
				// debugPrint(errorMessage)
				// main thread 에서 alert 이 표시되게 해야됨
				DispatchQueue.main.async {
					self?.showAlert(message: errorMessage.message)
				}
		}
	}.resume() // app 이 실행되게 함
	}
```

![Kapture 2021-12-18 at 14 33 20](https://user-images.githubusercontent.com/28912774/146630539-dcb10199-0ca2-419b-9513-8beb8eab2c97.gif)

---

🔶 🔷 📌 🔑 👉

## 🗃 Reference

Jacob's DevLog - [https://jacobko.info/ios/ios-08/](https://jacobko.info/ios/ios-08/)

아직은 어렵지 - [https://greatpapa.tistory.com/66](https://greatpapa.tistory.com/66)

fastcampus - [https://fastcampus.co.kr/dev_online_iosappfinal](https://fastcampus.co.kr/dev_online_iosappfinal)
