//
//  BindingOperator.swift
//  Tayary
//
//  Created by Mohamed Taher on 6/13/19.
//  Copyright © 2019 Mohamed Taher. All rights reserved.
//

import Foundation
internal import RxSwift
internal import RxCocoa

infix operator <->

@discardableResult func <-><T>(property: ControlProperty<T>, variable: BehaviorSubject<T>) -> Disposable {
    let variableToProperty = variable.asObservable()
        .bind(to: property)
    
    let propertyToVariable = property
        .subscribe(
            onNext: { variable.onNext($0) },
            onCompleted: { variableToProperty.dispose() }
    )
    
    return Disposables.create(variableToProperty, propertyToVariable)
}

infix operator ->>

@discardableResult func ->><T>(property: Binder<T>, variable: BehaviorSubject<T>) -> Disposable {
    let variableToProperty = variable.asObservable()
        .bind(to: property)
    
    return variableToProperty
}

@discardableResult func ->><T>(variable: BehaviorSubject<T>, action: @escaping (_ value: T) -> Void) -> Disposable {
    
     let variableToAction = variable.subscribe(onNext: { error in
            action(error)
     })
    
    return variableToAction
}
