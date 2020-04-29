# Swift AR 游戏开发：实时平面检测与合并

欢迎来到 MintJian 的 Swift AR 游戏开发系列，我会在这里记录一些 Swift AR 开发中遇到的一些问题和技巧。这个系列会同时在我的 [Blog](https://mintjian.com) 和 [GitHub](https://github.com/MintJian/My-iOS-Journey/tree/master/Swift-AR-Tips) 更新，如果你感兴趣的话，请一定多多支持。

### 如何使用 ARKit 检测平面

AR 游戏提供给玩家一种类似桌游的游戏体验。所以，对于一个常规的 AR 游戏来说，第一步就是要放置主世界到一个平面。检测平面需要 ARSCNViewDelegate，被检测的平面可以是水平的，也可以是垂直的，代码如下：

```swift
class ViewController: UIViewController, ARSCNViewDelegate {
  //配置 ARSession 的代码段
	func configureARSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal //水平
        //configuration.planeDetection = .vertical //垂直
   			//其他配置
        print("AR session is configured.")
        sceneView.session.run(configuration)
  }
}
```

如此配置，检测平面的准备工作就完成了。下一步是检测平面。

ARKit 提供了很多 ARAnchor 来帮助开发者跟踪现实世界的变化，例如 ARPlaneAnchor、ARObjectAnchor、ARFaceAnchor 等等，在平面检测中，需要用到的是 ARPlaneAnchor。那么，如何让程序知道我要是用哪种 ARAnchor 呢？在这里需要重写 renderer 方法，ARKit 为开发者提供了多种重载形式的 renderer 方法。那么在这里要使用哪种呢？平面检测，顾名思义，是检测现实中的平面，在 ARKit 中，平面信息被 ARPlaneAnchor 以 mesh 存储，因此在这里使用 `func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)` 方法比较合适。首先，将 ARAnchor 加入到当前 view 的 ARSession 里：

```Swift
func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
	guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
}
```

这样，通过调用 `planeAnchor`，就可以获得 ARPlaneAnchor 检测到的平面了。

在检测到平面后，下一步要做的就是告诉玩家确实检测到平面了，方法可以是用 UILabel，也可以直接展示出平面。在这里，我们选择后者。编写一个单独的函数来处理 `planeAnchor` 返回的结果。

```swift
func createPlane(with planeAnchor: ARPlaneAnchor) -> SCNNode {
    let plane = SCNNode()
    let geometry = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
    
    geometry.firstMaterial!.diffuse.contents = UIColor.white
    plane.geometry = geometry
    plane.opacity = 0.4
    plane.position = SCNVector3(planeAnchor.center.x, 0,planeAnchor.center.z)
    plane.name = "detectedPlane"
    
    return plane
}
```

在这个函数中，先创建 SCNNode 节点，然后将节点的 geometry 设置为 SCNPlane，使用 planeAnchor 获得的平面宽高和中心位置来设定 SCNPlane，为了让玩家看到平面的位置，还需要添加颜色、透明度等信息。最后返回这个 SCNNode 即可。

之后，在 `renderer` 中调用这个方法就可以在屏幕中展示检测到的平面了。

```swift
func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
	guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
	
	let detectedPlane = createPlane(with: planeAnchor)
  node.addChildNode(detectedPlane)
}
```

但是，这样有一个问题，ARPlaneAnchor 并不会记录检测到的平面，也就是说，任何的世界中的改变都会导致 renderer 重新触发。这样有可能会导致在现实世界的一个平面里，多个平面重叠的情况出现，十分不美观，而且玩家在选择平面上的点的时候也会产生困扰。因此，还需要一个方法来合并已有平面。  



### 如何合并检测到的平面

在简单场景下，要合并平面，最简单的方法就是永远使用最新检测到的平面，删除之前的平面。ARPlaneAnchor 会记录每一个检测平面的信息，无需担心错误合并其他的平面。在 `renderer` 中添加以下代码：

```swift
func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
	guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
	let newPlane = createPlane(with: planeAnchor)
	let existPlane = node.childNode(withName: "detectedPlane", recursively: false)
	
	if existPlane == nil {
		node.addChildNode(newPlane)
	} else {
		let oldVolume = oldBoardGeometry.height * oldBoardGeometry.width * oldBoardGeometry.length
		let newVolume = newBoardGeometry.height * newBoardGeometry.width * newBoardGeometry.length
	
	if oldVolume < newVolume {
		existPlane!.removeFromParentNode()
		node.addChildNode(newPlane)
	}
}
```

这样，运行代码后，通过移动设备，屏幕中就会实时显示每个平面的真实大小了。  



### 最后但是也很重要

那么这个平面能用来干什么呢？通过 `UITapGestureRecognizer` 或者其他的定位操作，玩家可以通过点击屏幕，与屏幕里对应位置的 SCNNode 产生一个“触碰”操作，利用这个操作，就可以达到在相应位置放置主世界的目的了。在下一期中，我将聊一聊关于建立场景的那些事儿，现在你可以打开 Xcode，来试一试自己能不能正确的检测到现实中的平面吧！
