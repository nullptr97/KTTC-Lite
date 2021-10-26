import UIKit

protocol WireframeInterface: AnyObject {
}

class BaseWireframe<T: UIViewController> {

    private unowned var _viewController: T

    //to retain view controller reference upon first access
    private var _temporaryStoredViewController: UIViewController?

    init(viewController: T) {
        _temporaryStoredViewController = viewController
        _viewController = viewController
    }

}

extension BaseWireframe: WireframeInterface {

}

extension BaseWireframe {

    var viewController: T {
        defer { _temporaryStoredViewController = nil }
        return _viewController
    }

    var navigationController: UINavigationController? {
        return viewController.navigationController
    }

}

extension UIViewController {

    func presentWireframe(_ wireframe: BaseWireframe<UIViewController>, animated: Bool = true, completion: (() -> Void)? = nil) {
        present(wireframe.viewController, animated: animated, completion: completion)
    }

}

extension UINavigationController {

    func pushWireframe(_ wireframe: BaseWireframe<UIViewController>, animated: Bool = true) {
        self.pushViewController(wireframe.viewController, animated: animated)
    }

    func setRootWireframe(_ wireframe: BaseWireframe<UIViewController>, animated: Bool = true) {
        self.setViewControllers([wireframe.viewController], animated: animated)
    }

}
