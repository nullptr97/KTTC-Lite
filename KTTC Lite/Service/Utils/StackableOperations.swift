//
//  StackableOperations.swift
//  KTTC Lite
//
//  Created by Ярослав Стрельников on 26.10.2021.
//

import Foundation

class StackableOperationsQueue {
    private let semaphore = DispatchSemaphore(value: 1)
    private lazy var operations = [QueueOperation]()
    private lazy var isExecuting = false

    fileprivate func _append(operation: QueueOperation) {
        semaphore.wait()
        operations.append(operation)
        semaphore.signal()
        execute()
    }

    func append(operation: QueueOperation) { _append(operation: operation) }

    private func execute() {
        semaphore.wait()
        guard !operations.isEmpty, !isExecuting else { semaphore.signal(); return }
        let operation = operations.removeFirst()
        isExecuting = true
        semaphore.signal()
        operation.perform()
        semaphore.wait()
        isExecuting = false
        semaphore.signal()
        execute()
    }
}

// MARK: - StackableOperationsCuncurentQueue performs functions from the stack one by one (serial performing) but in cuncurent queue

class StackableOperationsCuncurentQueue: StackableOperationsQueue {
    private var queue: DispatchQueue
    init(queue: DispatchQueue) { self.queue = queue }
    override func append(operation: QueueOperation) {
        queue.async { [weak self] in self?._append(operation: operation) }
    }
}

// MARK: QueueOperation interface

protocol QueueOperation: AnyObject {
    var сlosure: (() -> Void)? { get }
    var actualityCheckingClosure: (() -> Bool)? { get }
    init (actualityCheckingClosure: (() -> Bool)?, serialClosure: (() -> Void)?)
    func perform()
}

extension QueueOperation {
    // MARK: - Can queue perform the operation `сlosure: (() -> Void)?` or not
    var isActual: Bool {
        guard   let actualityCheckingClosure = self.actualityCheckingClosure,
                self.сlosure != nil else { return false }
        return actualityCheckingClosure()
    }
    func perform() { if isActual { сlosure?() } }

    init (actualIifNotNill object: AnyObject?, serialClosure: (() -> Void)?) {
        self.init(actualityCheckingClosure: { return object != nil }, serialClosure: serialClosure)
    }
}

class SerialQueueOperation: QueueOperation {
    let сlosure: (() -> Void)?
    let actualityCheckingClosure: (() -> Bool)?
    required init (actualityCheckingClosure: (() -> Bool)?, serialClosure: (() -> Void)?) {
        self.actualityCheckingClosure = actualityCheckingClosure
        self.сlosure = serialClosure
    }
}
