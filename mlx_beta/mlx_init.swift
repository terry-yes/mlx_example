
import Cocoa
import Metal
import mlx_window
import mlx_image


func _mlx_bridge<T : AnyObject>(obj : T) -> UnsafeMutableRawPointer? {
    return UnsafeMutableRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

func _mlx_bridge<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
}



public class MlxMain {

      public var winList = [MlxWin]()
      public var imgList = [MlxImg]()
      var myMlxApp:NSApplication?
      public var device:MTLDevice!
      var loopHook:UnsafeMutableRawPointer?
      var loopParam:UnsafeMutableRawPointer
      var loopHookTimer:CFRunLoopTimer?
      public var inLoop = false

      public init(_ flag:Int = 0)
      {
	/// make app with top menubar
        myMlxApp = NSApplication.shared
	if (flag == 1)
	{
		NSApp.setActivationPolicy(NSApplication.ActivationPolicy.prohibited)   /// for non clickable win, no top menu
	}
	else
	{
		NSApp.setActivationPolicy(NSApplication.ActivationPolicy.regular)
	}

	device = MTLCreateSystemDefaultDevice()!
	loopParam = UnsafeMutableRawPointer(&inLoop)  /// dummy addr init

	/// Add observer anyway to flush pixels every loop. If loop_hook exists, call it.
        var ocontext = CFRunLoopObserverContext(version:0, info:_mlx_bridge(obj:self), retain:nil, release:nil, copyDescription:nil)
	let observer = CFRunLoopObserverCreate(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue, true, 0, createOCallback(), &ocontext)
	CFRunLoopAddObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)

      }

      public func addWinToList(_ win:MlxWin)
      { winList.append(win) }
      public func addImgToList(_ img:MlxImg)
      { imgList.append(img) }


    func doCallLoopHook()
    {
///	if (loopHook != nil)
///	{
	   _ = (unsafeBitCast(loopHook!,to:(@convention(c)(UnsafeRawPointer)->Void).self))(loopParam)
///	}
    }

    func createOCallback() -> CFRunLoopObserverCallBack
    {
        return { (cfRunloopObserver, cfrunloopactivity, info) -> Void in
	    let mlx:MlxMain = _mlx_bridge(ptr:info!)
	    mlx.winList.forEach { $0.flushImages() }
///         mlx.doCallLoopHook()
        }
    }

    func createTCallback() -> CFRunLoopTimerCallBack
    {
        return { (cfRunloopTimer, info) -> Void in
	    let mlx:MlxMain = _mlx_bridge(ptr:info!)
            mlx.doCallLoopHook()
        }
    }

    public func addLoopHook(_ f:UnsafeMutableRawPointer?, _ p:UnsafeMutableRawPointer)
      {
        var tcontext = CFRunLoopTimerContext(version:0, info:_mlx_bridge(obj:self), retain:nil, release:nil, copyDescription:nil)
	if (loopHook != nil)
	{
		CFRunLoopTimerInvalidate(loopHookTimer)
	}

	loopHook = f
	loopParam = p
	if (loopHook != nil)
	{
	   loopHookTimer = CFRunLoopTimerCreate(kCFAllocatorDefault, 0.0, 0.0001, 0, 0, createTCallback(), &tcontext)
	   CFRunLoopAddTimer(CFRunLoopGetMain(), loopHookTimer, CFRunLoopMode.commonModes)
	}
      }

}
