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
    
    // MARK: Get Default NavigationController From ViewController
    
    public func defaultNavigation<T: UIViewController>(root: T, isClear: Bool = false, isUseTheme: Bool = true) -> UINavigationController {
        
        root.title = nil
        
        let naviController = UINavigationController(rootViewController: root)
        naviController.navigationBar.isTranslucent = false
        
        return naviController
    }
}
