import UIKit

public class StoryboardUtil: NSObject {
    
    public static let shared = StoryboardUtil()
    
    public var boards = [String]()
    
    // MARK: Get ViewController From Storyboard
    
    public func controller<T: UIViewController>(from: T.Type) -> T {
        let name = String(describing: from)
        for sotyrboardName in StoryboardUtil.shared.boards {
            let storyboard = UIStoryboard(name: sotyrboardName, bundle: nil)
            if let availableIdentifiers = storyboard.value(forKey: "identifierToNibNameMap") as? [String: Any], availableIdentifiers[name] != nil {
                return storyboard.instantiateViewController(withIdentifier: name) as! T
            }
        }
        assertionFailure("Error! Board Not Found!")
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name) as! T
    }
    
    // MARK: Get NavigationController From Storyboard
    
    public func navigation<T: UINavigationController>(name: String) -> T {
        for sotyrboardName in StoryboardUtil.shared.boards {
            let storyboard = UIStoryboard(name: sotyrboardName, bundle: nil)
            if let availableIdentifiers = storyboard.value(forKey: "identifierToNibNameMap") as? [String: Any], availableIdentifiers[name] != nil {
                return storyboard.instantiateViewController(withIdentifier: name) as! T
            }
        }
        assertionFailure("Error! Board Not Found!")
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name) as! T
    }
}

extension UIWindow {
    
    // MARK: Change RootViewController in UIWindow
    
    public func setAnimatedRootViewController<T: UIViewController>(_ newRootViewController: T) {
        let previousViewController = rootViewController
        rootViewController = newRootViewController
        
        UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve, animations: nil, completion: nil)
        
        if let previousViewController = previousViewController {
            previousViewController.dismiss(animated: false) {
                previousViewController.view.removeFromSuperview()
            }
        }
    }
}

extension UIApplication {
    
    // NARK: Find Too ViewController
    
    public class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController, complete: @escaping (UIViewController?) -> Void) {

        DispatchQueue.main.async {

            if let navigationController = controller as? UINavigationController {
                topViewController(controller: navigationController.visibleViewController, complete: complete)
                return
            }

            if let tabController = controller as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    topViewController(controller: selected, complete: complete)
                    return
                }
            }

            if let presented = controller?.presentedViewController {
                topViewController(controller: presented, complete: complete)
                return
            }

            complete(controller)
        }
    }
    
    public class func topViewController(complete: @escaping (UIViewController?) -> Void) {
        
        DispatchQueue.main.async {
            
            let controller = UIApplication.shared.keyWindow?.rootViewController
            
            if let navigationController = controller as? UINavigationController {
                topViewController(controller: navigationController.visibleViewController, complete: complete)
                return
            }
            
            if let tabController = controller as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    topViewController(controller: selected, complete: complete)
                    return
                }
            }
            
            if let presented = controller?.presentedViewController {
                topViewController(controller: presented, complete: complete)
                return
            }
            
            complete(controller)
        }
    }
    
    public class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) async -> UIViewController? {

        if let navigationController = controller as? UINavigationController {
            return await topViewController(controller: navigationController.visibleViewController)
        }

        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return await topViewController(controller: selected)
            }
        }

        if let presented = controller?.presentedViewController {
            return await topViewController(controller: presented)
        }
        
        return controller
    }
    
    public class func topViewController() async -> UIViewController? {
        
        let controller = UIApplication.shared.keyWindow?.rootViewController
        
        if let navigationController = controller as? UINavigationController {
            return await topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return await topViewController(controller: selected)
            }
        }
        
        if let presented = controller?.presentedViewController {
            return await topViewController(controller: presented)
        }
        
        return controller
    }
    
    // MARK: Change RootViewController
    
    public class func setRootViewController(viewController: UIViewController) {
        UIApplication.shared.delegate?.window??.setAnimatedRootViewController(viewController)
    }
}
