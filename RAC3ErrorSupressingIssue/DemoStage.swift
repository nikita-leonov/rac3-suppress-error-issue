//
//  DemoStage.swift
//  RAC3ErrorSupressingIssue
//
//  Created by Nikita Leonov on 7/30/15.
//  Copyright © 2015 Nikita Leonov. All rights reserved.
//

import Foundation
import ReactiveCocoa

public class DemoStage {
    private var faultySignal: Signal<Void, NSError>
    private var faultyPipe = Signal<Void, NSError>.pipe()
    
    public init () {
        faultySignal = faultyPipe.0
    }
    
    public func sendError() {
        ReactiveCocoa.sendError(faultyPipe.1, NSError())
    }
    
    public func sendNext() {
        ReactiveCocoa.sendNext(faultyPipe.1, ())
    }
    
    public func faultyProducer() -> SignalProducer<Void, NSError> {
        return SignalProducer { (observer, compositeDisposable) in
            let disposable = self.faultySignal.observe(observer)
            compositeDisposable.addDisposable(disposable)
        }
    }
    
    public func stableProducer() -> SignalProducer<Void, NSError> {
        return faultyProducer() |> catch { _ in self.faultyProducer() }
    }
}