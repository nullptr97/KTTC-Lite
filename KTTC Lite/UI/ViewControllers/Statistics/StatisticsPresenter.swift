//
//  StatisticsPresenter.swift
//  KTTC Lite
//
//  Created by Ярослав Стрельников on 26.10.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import Foundation
import ObjectMapper

final class StatisticsPresenter {

    // MARK: - Private properties -

    internal unowned let view: StatisticsViewInterface
    internal let formatter: StatisticsFormatterInterface
    private let interactor: StatisticsInteractorInterface
    private let wireframe: StatisticsWireframeInterface
    
    private lazy var stackableOperationsQueue: StackableOperationsCuncurentQueue = {
        let queue = DispatchQueue(label: "get_statistics", qos: .background, attributes: [.concurrent], autoreleaseFrequency: .workItem, target: nil)
        return StackableOperationsCuncurentQueue(queue: queue)
    }()

    // MARK: - Lifecycle -

    init(view: StatisticsViewInterface, formatter: StatisticsFormatterInterface, interactor: StatisticsInteractorInterface, wireframe: StatisticsWireframeInterface) {
        self.view = view
        self.formatter = formatter
        self.interactor = interactor
        self.wireframe = wireframe
    }
}

// MARK: - Extensions -

extension StatisticsPresenter: StatisticsPresenterInterface {
    func didRunProcess<T: Mappable>(with model: T.Type, accountId: Int, gameType: KTTCApi.GameType, nickName: String?) {
        formatter.needCalculateData.erase()
        interactor.getStatistics(with: model, with: accountId, from: gameType)
    }
    
    private func addOperationToQueue(closure: (() -> Void)?) {
        let operation = SerialQueueOperation(actualIifNotNill: self) { closure?() }
        stackableOperationsQueue.append(operation: operation)
        print("!!!! Function added ")
    }
}
