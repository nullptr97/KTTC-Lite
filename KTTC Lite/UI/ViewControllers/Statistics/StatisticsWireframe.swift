//
//  StatisticsWireframe.swift
//  KTTC Lite
//
//  Created by Ярослав Стрельников on 26.10.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit
import ObjectMapper

final class StatisticsWireframe<T: Mappable>: BaseWireframe<StatisticsViewController<T>> {

    // MARK: - Private properties -

    // MARK: - Module setup -

    init() {
        let moduleViewController = StatisticsViewController<T>()
        super.init(viewController: moduleViewController)

        let formatter = StatisticsFormatter()
        let interactor = StatisticsInteractor()
        let presenter = StatisticsPresenter(view: moduleViewController, formatter: formatter, interactor: interactor, wireframe: self)
        moduleViewController.presenter = presenter
        interactor.presenter = presenter
        formatter.presenter = presenter
    }

}

// MARK: - Extensions -

extension StatisticsWireframe: StatisticsWireframeInterface {
}
