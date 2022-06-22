//
//  ViewController.swift
//  pomodoro
//
//  Created by 정유진 on 2022/06/18.
//

import UIKit
import AudioToolbox

enum TimerStatus {
    case start
    case pause
    case end
}


class ViewController: UIViewController {
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var toggleButton: UIButton!
    
    var duration = 60
    //타이머에 설정된 시간을 초로 저장하는 프로퍼티
    var timerStatus: TimerStatus = .end
    //타이머의 상태를 가지고 있는 프로퍼티
    var timer: DispatchSourceTimer?
    var currentSeconds = 0
    // 현재 카운트다운 되고있는 시간을 초로 저장
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureToggleButton()
    }
    
    func setTimerInfoViewVisble(isHidden: Bool) {
        self.timerLabel.isHidden = isHidden
        self.progressView.isHidden = isHidden
    }

    func configureToggleButton() {
        self.toggleButton.setTitle("시작", for: .normal)
        self.toggleButton.setTitle("일시정지", for: .selected)
    }
    
    func startTimer() {
        if self.timer == nil {
            self.timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
            self.timer?.schedule(deadline: .now(), repeating: 1)
            self.timer?.setEventHandler(handler: { [weak self] in
                guard let self = self else { return }
                self.currentSeconds -= 1
                let hour = self.currentSeconds / 3600
                let minutes = (self.currentSeconds % 3600 ) / 60
                let seconde = (self.currentSeconds % 3600 ) % 60
                self.timerLabel.text = String(format: "%02d:%02d:%02d", hour, minutes, seconde)
                self.progressView.progress = Float(self.currentSeconds) / Float(self.duration)
                UIView.animate(withDuration: 0.5, delay: 0, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi)
                    //pi 파이 값을 넣어 이미지가 180도로 회전
                    //CGAffineTransform은 구조체. 특징은 뷰의 프레임을 계산하지 않고 2D그래픽 효과를 줄 수 있다
                })
                UIView.animate(withDuration: 0.5, delay: 0.5, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: .pi * 2)
                    //pi * 2 값으로 360도 회전 delay 0.5로 180도로 먼저 돌고 동작하게 순서를 구현함
                })
                
                
                
                if self.currentSeconds <= 0 {
                    self.stopTimer()
                    AudioServicesPlaySystemSound(1005)
                }
            })
            self.timer?.resume()
        }
    }
    
    func stopTimer() {
        if self.timerStatus == .pause {
            self.timer?.resume()
        }
        self.timerStatus = .end
        self.cancelButton.isEnabled = false
        UIView.animate(withDuration: 0.5, animations: {
            self.timerLabel.alpha = 0
            self.progressView.alpha = 0
            self.datePicker.alpha = 1
            self.imageView.transform = .identity
        })
        self.toggleButton.isSelected = false
        self.timer?.cancel()
        self.timer = nil
        //꼭 nil을 사용! 안그러면 화면을 벗어나도 타이머가 계속 동작 될 수 있음
    }
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        switch self.timerStatus {
        case .start, .pause:
            self.stopTimer()
            
        default:
            break
        }
    }
    
    @IBAction func tapToggleButton(_ sender: UIButton) {
        self.duration = Int(self.datePicker.countDownDuration)
        switch self.timerStatus {
        case .end:
            self.currentSeconds = self.duration
            self.timerStatus = .start
            UIView.animate(withDuration: 0.5, animations: {
                self.timerLabel.alpha = 1
                self.progressView.alpha = 1
                self.datePicker.alpha = 0
            })
            self.toggleButton.isSelected = true
            self.cancelButton.isEnabled = true
            self.startTimer()
            
        case .start:
            self.timerStatus = .pause
            self.toggleButton.isSelected = false
            self.timer?.suspend()
            
        case .pause:
            self.timerStatus = .start
            self.toggleButton.isSelected = true
            self.timer?.resume()
        }
    }
    
    
    
    
}

