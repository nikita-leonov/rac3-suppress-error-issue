//
//  RAC3ErrorSupressingIssueTests.swift
//  RAC3ErrorSupressingIssueTests
//
//  Created by Nikita Leonov on 7/30/15.
//  Copyright (c) 2015 Nikita Leonov. All rights reserved.
//

import RAC3ErrorSupressingIssue

import Quick
import Nimble

import ReactiveCocoa

class DemoStageSpec: QuickSpec {
    override func spec() {
        describe("DemoStage") {
            var demoStage: DemoStage!
            beforeEach {
                demoStage = DemoStage()
            }
            afterEach {
                demoStage = nil;
            }
            describe("faultyProducer") {
                var faultyProducer: SignalProducer<Void, NSError>!
                beforeEach {
                    faultyProducer = demoStage.faultyProducer()
                }
                afterEach {
                    faultyProducer = nil
                }
                context("when error send") {
                    it("does receive error") {
                        waitUntil { complete in
                            faultyProducer.start(error: { _ in
                                complete()
                            })
                            demoStage.sendError()
                        }
                    }
                }
                context("when next send") {
                    it("does receive next") {
                        waitUntil { complete in
                            faultyProducer.start(next: { _ in
                                complete()
                            })
                            demoStage.sendNext()
                        }
                    }
                }
                context("when next after error send") {
                    it("does not receive next") {
                        faultyProducer.start(next: { _ in
                            expect(false) === true
                        })
                        demoStage.sendError()
                        demoStage.sendNext()
                        waitUntil(timeout: 2) { complete in
                            sleep(1)
                            complete()
                        }
                    }
                }
            }
            describe("stableProducer") {
                var stableProducer: SignalProducer<Void, NSError>!
                beforeEach {
                    stableProducer = demoStage.stableProducer()
                }
                afterEach {
                    stableProducer = nil
                }
                context("when error send") {
                    it("does not receive error") {
                        stableProducer.start(error: { _ in
                            expect(false) === true
                        })
                        demoStage.sendError()
                        waitUntil(timeout: 2) { complete in
                            sleep(1)
                            complete()
                        }
                    }
                }
                context("when next send") {
                    it("does receive next") {
                        waitUntil { complete in
                            stableProducer.start(next: { _ in
                                complete()
                            })
                            demoStage.sendNext()
                        }
                    }
                }
                context("when next after error send") {
                    it("does receive next") {
                        waitUntil { complete in
                            stableProducer.start(next: { _ in
                                complete()
                            })
                            demoStage.sendError()
                            demoStage.sendNext()
                        }
                    }
                }
            }
        }
    }
}
