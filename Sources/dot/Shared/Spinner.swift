//
//  Spinner.swift
//  dot
//
//  Created by Atsushi Miyake on 2019/04/07.
//

import Foundation
import RxSwift
import Scripty

final class Spinner {
    
    static let shared = Spinner()
    private init() {
        self.triggerSpin.asObservable()
            .delay(0.1, scheduler: SerialDispatchQueueScheduler(internalSerialQueueName: "spinner"))
            .subscribe(onNext: { [weak self] string in
                guard let `self` = self else { return }
                if self.spinning {
                    "\(self.spinners[self.spinnerIndex % self.spinners.count]) \(string)"
                        .colorize(color: .green)
                        .echo(overwrite: true, newline: false)
                    self.spinnerIndex += 1
                    self.triggerSpin.onNext(string)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private let spinners = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    private var spinnerIndex = 0
    private var spinning = false
    private let triggerSpin = PublishSubject<String>()
    private let disposeBag = DisposeBag()

    func spin(with string: String) {
        self.spinning = true
        self.triggerSpin.onNext(string)
    }
    
    func stop() {
        self.spinning = false
    }
}
