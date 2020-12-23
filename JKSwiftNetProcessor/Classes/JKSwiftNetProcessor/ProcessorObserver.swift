//
//  ProcessorObserver.swift
//  JKSwiftNetProcessor
//
//  Created by IronMan on 2020/12/23.
//

import Foundation

// 将请求绑定到对应的对象上，从而跟随对象的生命周期进行释放
class ProcessorObserver {
    private var requests: [Processor] = []

    public init() {}

    func add(processor: Processor) {
        requests.append(processor)
        processor.observer = self
    }

    internal func remove(processor: Processor) {
        for i in 0...requests.count {
            if requests[i] === processor {
                #if DEBUG
                print("remove")
                #endif
                requests.remove(at: i)
                return
            }
        }
    }

    deinit {
        requests.forEach { sp in
            #if DEBUG
            print("cancel")
            #endif
            sp.cancel()
        }
    }
}

public protocol ProcessorLifeBinder {
    func bindLife<T: Processor>(processor: T) -> T
}

extension UIViewController: ProcessorLifeBinder {}

private var lifeBinderObserverKey: Void?
extension ProcessorLifeBinder {
    
    @discardableResult
    public func bindLife<T: Processor>(processor: T) -> T {
        processorObserver.add(processor: processor)
        return processor
    }
    
    var processorObserver: ProcessorObserver {
        if let ob = objc_getAssociatedObject(self, &lifeBinderObserverKey) as? ProcessorObserver {
            return ob
        }
        let ob = ProcessorObserver()
        objc_setAssociatedObject(self, &lifeBinderObserverKey, ob, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return ob
    }
}

private var processorObserverKey: Void?
extension Processor {
    
    public func bind(_ ob: ProcessorLifeBinder) -> Self {
        let _ = ob.bindLife(processor: self)
        return self
    }
    
    weak var observer: ProcessorObserver? {
        set {
            var container = objc_getAssociatedObject(self, &processorObserverKey) as? ObserverContainer
            if container == nil {
                container = ObserverContainer()
                objc_setAssociatedObject(self, &processorObserverKey, container, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            container?.observer = newValue
        }
        get {
            let container = objc_getAssociatedObject(self, &processorObserverKey) as? ObserverContainer
            return container?.observer
        }
    }
}

// 解决关联只有assign没有weak的问题
private class ObserverContainer {
    weak var observer: ProcessorObserver?
}

