//
//  SearchWireframe.swift
//  KTTC Lite
//
//  Created by Ярослав Стрельников on 26.10.2021.
//  Copyright (c) 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  This file was generated by the 🐍 VIPER generator
//

import UIKit

final class SearchWireframe: BaseWireframe<SearchViewController> {

    // MARK: - Private properties -

    // MARK: - Module setup -

    init(by gameType: KTTCApi.GameType) {
        let moduleViewController = SearchViewController(by: gameType)
        super.init(viewController: moduleViewController)

        let formatter = SearchFormatter()
        let interactor = SearchInteractor()
        let presenter = SearchPresenter(view: moduleViewController, formatter: formatter, interactor: interactor, wireframe: self)
        moduleViewController.presenter = presenter
        interactor.presenter = presenter
    }

}

// MARK: - Extensions -

extension SearchWireframe: SearchWireframeInterface {
}
