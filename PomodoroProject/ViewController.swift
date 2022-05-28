//
//  ViewController.swift
//  PomodoroProject
//
//  Created by Мария Вольвакова on 28.05.2022.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(circleView)
        circleView.addSubview(timeLabel)
        circleView.addSubview(playStopButton)
            
        setupLayout()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
            
        circleView.layer.addSublayer(shapeLayer)
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 300),
            circleView.heightAnchor.constraint(equalToConstant: 300)
        ])
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor, constant: -40)
        ])
        NSLayoutConstraint.activate([
            playStopButton.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            playStopButton.centerYAnchor.constraint(equalTo: circleView.centerYAnchor, constant: 60),
            playStopButton.widthAnchor.constraint(equalToConstant: 50),
            playStopButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    
    // MARK: - Elements
    
    var timer = Timer()
    var durationTime = TimeDuration.workingTime
    
    var isTimerRunning = false
    var isWorkingTime = true
    
    private lazy var circleView: UIView = {
        let circle = UIView()
        circle.translatesAutoresizingMaskIntoConstraints = false
        circle.layer.cornerRadius = 150
        circle.layer.borderWidth = 25
        circle.backgroundColor = .white
        circle.layer.borderColor = UIColor.clear.cgColor
        return circle
    }()
    
    private lazy var timeLabel: UILabel = {
        let lable = UILabel()
        lable.translatesAutoresizingMaskIntoConstraints = false
        lable.font = .systemFont(ofSize: 70, weight: .light)
        lable.textColor = Color.workingTimeColor
        lable.text = "\(formatTime())"
        lable.textAlignment = .center
        return lable
    }()
    
    private lazy var playStopButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setBackgroundImage(UIImage(systemName: "play"), for: .normal)
        button.tintColor = Color.workingTimeColor
        button.addTarget(self, action: #selector(buttonPlayAction), for: .touchUpInside)
        return button
    }()

    lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = animationCircle.cgPath
        shapeLayer.lineWidth = 10
        shapeLayer.strokeStart = 0
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = Color.workingTimeColor?.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        return shapeLayer
    }()

// Создаем анимированный круг
    lazy var animationCircle: UIBezierPath = {
        var animationCircle = UIBezierPath()
        let center = CGPoint(x: circleView.frame.width / 2, y: circleView.frame.height / 2)
        let endAngle = (-CGFloat.pi / 2)
        let startAngle = 2 * CGFloat.pi + endAngle
   
        animationCircle = UIBezierPath(arcCenter: center, radius: 150, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return animationCircle
    }()
    
    // MARK: - Methods for timer
    
// Создаем функцию таймера времени
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerAction), userInfo: nil, repeats: true)
    }
    
// Устанавливаем конфигурацию времени на минуты и секунды
    private func formatTime() -> String {
        let minutes = Int(durationTime) / 60 % 60
        let seconds = Int(durationTime) % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
    
// Указываем действия для таймера
    @objc func timerAction() {
        durationTime -= 1
        timeLabel.text = "\(formatTime())"
// Когда время заканчивается,таймер обнуляется
          if durationTime < 1 {
              timer.invalidate()
              playStopButton.setBackgroundImage(UIImage(systemName: "play"), for: .normal)
              playStopButton.tintColor = Color.restTimeColor
              isTimerRunning = false
// Если рабочее время, меняем параметры таймера на время отдыха
              if isWorkingTime {
                  isWorkingTime = false
                  durationTime = TimeDuration.restTime
                  timeLabel.text = "\(formatTime())"
                  timeLabel.textColor = Color.restTimeColor
                  playStopButton.tintColor = Color.restTimeColor
                  circleView.layer.borderColor = UIColor.clear.cgColor
                  shapeLayer.strokeColor = Color.restTimeColor?.cgColor
              } else {
// Если время отдыха, меняем параметры таймера на время рабочее
                  isWorkingTime = true
                  durationTime = TimeDuration.workingTime
                  timeLabel.text = "\(formatTime())"
                  timeLabel.textColor = Color.workingTimeColor
                  playStopButton.tintColor = Color.workingTimeColor
                  circleView.layer.borderColor = UIColor.clear.cgColor
                  shapeLayer.strokeColor = Color.workingTimeColor?.cgColor
              }}}
    
    // MARK: - Methods for button
    
// Действия кнопки при запуске таймера
    @objc func buttonPlayAction() {
            if isTimerRunning == false {
                isTimerRunning = true
                startTimer()
                playStopButton.setBackgroundImage( UIImage(systemName: "pause"), for: .normal)
                
// Проверяем на паузе ли наша анимация
// Вызываем функцию, которая после паузы возобновляет работу таймера
// Если она не на паузе, а просто не была еще запущена (то есть перед началом времени на работу или отдых), то просто запускаем стандартную анимацию
                if view.layer.speed == 0 { resumeAnimation(layer: view.layer) } else { animation() }
            } else {
                isTimerRunning = false
                pauseAnimation(layer: view.layer)
                timer.invalidate()
                playStopButton.setBackgroundImage( UIImage(systemName: "play"), for: .normal)
            }}
    
// Действия кнопки при остановке таймера
     @objc func buttonPauseAction() {
        timer.invalidate()
        buttonPlayAction()
        timeLabel.text = "\(formatTime())"
        playStopButton.setBackgroundImage( UIImage(systemName: "play"), for: .normal)
        playStopButton.tintColor = Color.restTimeColor
    }
    
    
    // MARK: - Animation
    
    private func animation(){
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.toValue = 0
        animation.duration = CFTimeInterval(durationTime)
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = true
        shapeLayer.add(animation, forKey: "animation")
    }
    
    private func pauseAnimation(layer: CALayer) {
                // Фиксируем время во время паузы
    let pausedTime: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil)
                // Скорость останавливаем
        layer.speed = 0
                // Задаем смещению времени время, в которое была сделана пауза
        layer.timeOffset = pausedTime
    }
     
//  Возобновляет работу анимации
    private  func resumeAnimation(layer: CALayer) {
        // Получаем то смещение времени, когда была поставлена пауза
        let pausedTime: CFTimeInterval = layer.timeOffset
        // Возобновляем скорость
        layer.speed = 1
        layer.timeOffset = 0
        layer.beginTime = 0
        // Высчитываем время
        let timeSincePause: CFTimeInterval = layer.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        layer.beginTime = timeSincePause
    }
}
    

// MARK: - Constants

extension ViewController {
    // Тут можно установить цвета для рабочеего времени и времени отдыха, поменяется по всему коду
    enum Color {
        static let workingTimeColor = UIColor(named: "redColor")
        static let restTimeColor = UIColor(named: "greenColor")
    }
    
    // Тут можно установить рабочее время и время отдыха, поменяется по всему коду
    enum TimeDuration {
        static let workingTime: Int = 1500
        static let restTime: Int = 300
    }
}

