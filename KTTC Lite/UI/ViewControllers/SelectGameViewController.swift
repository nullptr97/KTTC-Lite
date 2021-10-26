//
//  SelectGameViewController.swift
//  WoT Manager
//
//  Created by Ярослав Стрельников on 23.10.2021.
//

import UIKit
import ObjectMapper

class SelectGameViewController: BaseController {
    @IBOutlet weak var gamesStackView: UIStackView!
    @IBOutlet weak var wotImageView: UIImageView!
    @IBOutlet weak var wotButton: UIButton!
    @IBOutlet weak var blitzImageView: UIImageView!
    @IBOutlet weak var blitzButton: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        wotImageView.image = .named("wotGray")
        blitzImageView.image = .named("wotbGray")
        
        let wotPanGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(panGesture:)))
        wotPanGesture.minimumNumberOfTouches = 1
        
        let blitzPanGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(panGesture:)))
        blitzPanGesture.minimumNumberOfTouches = 1
        
        wotButton.addGestureRecognizer(wotPanGesture)
        blitzButton.addGestureRecognizer(blitzPanGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] context in
            guard let self = self else { return }
            self.gamesStackView.axis = UIDevice.current.orientation == .portrait ? .vertical : .horizontal
        }
    }
    
    @objc func panGestureHandler(panGesture recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: view)

        switch recognizer.state {
        case .failed, .cancelled, .ended:
            setImage(wotImageView, image: .named("wotGray"))
            setImage(blitzImageView, image: .named("wotbGray"))
        case .began, .changed:
            if location.y > view.center.y {
                setImage(wotImageView, image: .named("wotGray"))
                setImage(blitzImageView, image: .named("wotb"))
            } else {
                setImage(wotImageView, image: .named("wot"))
                setImage(blitzImageView, image: .named("wotbGray"))
            }
        default:
            break
        }
    }
    
    private func setImage(_ imageView: UIImageView, image: UIImage?) {
        guard imageView.image != image else { return }
        imageView.image = image

        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .fade
        
        imageView.layer.add(transition, forKey: nil)
    }

    @IBAction func willSelectWot(_ sender: UIButton) {
        setImage(wotImageView, image: .named("wot"))
        setImage(blitzImageView, image: .named("wotbGray"))
    }
    
    @IBAction func didSelectWot(_ sender: UIButton) {
        setImage(wotImageView, image: .named("wotGray"))
        setImage(blitzImageView, image: .named("wotbGray"))

        let viewController = StatisticsWireframe<AnyTanksStats>().viewController
        viewController.gameType = .bb
        navigationController?.show(viewController, sender: sender)
    }
    
    @IBAction func willSelectWotBlitz(_ sender: UIButton) {
        setImage(wotImageView, image: .named("wotGray"))
        setImage(blitzImageView, image: .named("wotb"))
    }
    
    @IBAction func didSelectWotBlitz(_ sender: UIButton) {
        setImage(wotImageView, image: .named("wotGray"))
        setImage(blitzImageView, image: .named("wotbGray"))

        let viewController = StatisticsWireframe<AnyBlitzTanksStats>().viewController
        viewController.gameType = .blitz
        navigationController?.show(viewController, sender: sender)
    }
}
