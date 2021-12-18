//
//  ViewController.swift
//  06_weather_app
//
//  Created by Jacob Ko on 2021/12/17.
//

import UIKit

class ViewController: UIViewController {
	
	@IBOutlet weak var cityNameTextField: UITextField!
	@IBOutlet weak var weatherStackView: UIStackView!
	@IBOutlet weak var cityNameLabel: UILabel!
	@IBOutlet weak var weatherDescriptionLabel: UILabel!
	@IBOutlet weak var tempLabel: UILabel!
	@IBOutlet weak var maxTempLabel: UILabel!
	@IBOutlet weak var minTempLabel: UILabel!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	@IBAction func tabFetchWeatherBtn(_ sender: UIButton) {
		if let cicyName = self.cityNameTextField.text {
			self.getCurrentWeather(cityName: cicyName)
			self.view.endEditing(true) // 버튼을 누르게 되면 키보드가 강제로 사라지게 함
		}
	}
	
	// UI창에 weatherInfo 가 나타나게 하는 method
	func configureView(weatherInfo: WeatherInfo) {
		self.cityNameLabel.text = weatherInfo.name
		// weatherInfor 안에 wather 의 첫번째 상수에 대입
		if let weather = weatherInfo.weather.first {
			/Users/jacobko/dev/06_iOS_WorkSpace/06_weather_app/README.md
			self.weatherDescriptionLabel.text = weather.description
		}
		self.tempLabel.text = "\(Int(weatherInfo.temp.temp))°C"
		self.minTempLabel.text = "최저: \(Int(weatherInfo.temp.minTemp))°C"
		self.maxTempLabel.text = "최고: \(Int(weatherInfo.temp.maxTemp))°C"
	}
	
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
}

