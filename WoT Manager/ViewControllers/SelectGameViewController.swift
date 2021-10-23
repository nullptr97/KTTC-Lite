//
//  SelectGameViewController.swift
//  WoT Manager
//
//  Created by Ярослав Стрельников on 23.10.2021.
//

import UIKit

class SelectGameViewController: BaseController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    @IBAction func didSelectWot(_ sender: UIButton) {
        let viewController = ViewController<AnyTanksStats>()
        viewController.gameType = .bb
        navigationController?.show(viewController, sender: sender)
    }
    
    @IBAction func didSelectWotBlitz(_ sender: UIButton) {
        let viewController = ViewController<AnyBlitzTanksStats>()
        viewController.gameType = .blitz
        navigationController?.show(viewController, sender: sender)
    }
}
