# StoryboardUtil

스토리보드에서 특정 identifier를 가진 viewController를 불러오기 위해서는 다음과 같은 코드를 사용해야한다.
```
let storyboard = UIStoryboard(name: "Main", bundle: nil)
let testVC = storyboard.instantiateViewController(withIdentifier: "TestViewController") as! TestViewController
```
하지만, 스토리보드가 많은 경우 매번 해당 viewController가 어느 storyboard에 존재하는지 확인하기가 어려운 문제가 있어서, 
해당 프로젝트를 만들게 되었다.

### 사용법
```
import StoryboardUtil

...

let testVC = StoryboardUtil().controller(from: TestViewController.self)  
```

### 추가기능

최상단의 viewController에 접근하고 싶은 경우,
```
UIApplication.topViewController { topVC in 
  // topVC는 최상단 viewController임
}
```
또는
```
let topVC = await UIApplication.topViewController() 
// topVC는 최상단 viewController임
```
해당 함수를 사용하면,
복잡한 서브뷰 최상단 화면이 아닌 클래스 내부에서, Alert / NavigationPush / Modal 등을 바로 처리할 수 있다

... - ViewController - TableView - ACell에서 검색하면으로 바로 naviation push를 할 수 있음
```
let topVC = await UIApplication.topViewController()
let vc = StoryboardUtil().controller(from: SearchViewController.self)
await topVC.navigationController?.pushViewController(vc, animated: true)  
```
