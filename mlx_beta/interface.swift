
import Cocoa

import mlx_window
import mlx_image
import mlx_init



func _mlx_bridge<T : AnyObject>(obj : T) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passUnretained(obj).toOpaque())
}

func _mlx_bridge_retained<T : AnyObject>(obj : T) -> UnsafeRawPointer {
    return UnsafeRawPointer(Unmanaged.passRetained(obj).toOpaque())
}

func _mlx_bridge<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeUnretainedValue()
}

func _mlx_bridge_transfer<T : AnyObject>(ptr : UnsafeRawPointer) -> T {
    return Unmanaged<T>.fromOpaque(ptr).takeRetainedValue()
}


let MLX_SYNC_IMAGE_WRITABLE = Int32(1)
let MLX_SYNC_WIN_FLUSH_CMD = Int32(2)
let MLX_SYNC_WIN_CMD_COMPLETED = Int32(3)



/// C decl


@_cdecl("mlx_init")
public func mlx_init_swift() -> UnsafeRawPointer
{
	let mm = MlxMain()	
	return (_mlx_bridge_retained(obj:mm))
}


@_cdecl("mlx_loop")
public func mlx_loop_swift(_ mlxptr:UnsafeRawPointer)
{
	let mlx:MlxMain = _mlx_bridge(ptr:mlxptr)
	mlx.inLoop = true
        NSApp.run()
}


@_cdecl("mlx_new_window")
public func mlx_new_window_swift(_ mlxptr:UnsafeRawPointer, Width w:UInt32, Height h:UInt32, Title t:UnsafePointer<CChar>) -> UnsafeRawPointer
{
		let mlx:MlxMain = _mlx_bridge(ptr:mlxptr)
		let mw = MlxWin(device: mlx.device, width: Int(w), height: Int(h), title: String(cString: t))
		mw.setNotifs()
		mw.initMetal()
		mlx.addWinToList(mw)
		return (_mlx_bridge_retained(obj:mw))
}



@_cdecl("mlx_key_hook")
public func mlx_key_hook_swift(_ winptr:UnsafeRawPointer, _ fctptr:UnsafeMutableRawPointer, _ paramptr:UnsafeMutableRawPointer) -> Int32
{
	let win:MlxWin = _mlx_bridge(ptr:winptr)
	win.addHook(index: 3, fct: fctptr, param: paramptr)
	return (Int32(0));
}


@_cdecl("mlx_mouse_hook")
public func mlx_mouse_hook_swift(_ winptr:UnsafeRawPointer, _ fctptr:UnsafeMutableRawPointer, _ paramptr:UnsafeMutableRawPointer) -> Int32
{
        let win:MlxWin = _mlx_bridge(ptr:winptr)
        win.addHook(index: 4, fct: fctptr, param: paramptr)
        return (Int32(0));
}


@_cdecl("mlx_hook")
public func mlx_hook_swift(_ winptr:UnsafeRawPointer, _ xevent:Int32, _ xmask:Int32, _ fctptr:UnsafeMutableRawPointer, _ paramptr:UnsafeMutableRawPointer) -> Int32
{
        let win:MlxWin = _mlx_bridge(ptr:winptr)
        win.addHook(index: Int(xevent), fct: fctptr, param: paramptr)
        return (Int32(0));
}


@_cdecl("mlx_expose_hook")
public func mlx_expose_hook_swift(_ winptr:UnsafeRawPointer, _ fctptr:UnsafeMutableRawPointer, _ paramptr:UnsafeMutableRawPointer) -> Int32
{
        let win:MlxWin = _mlx_bridge(ptr:winptr)
        win.addHook(index: 12, fct: fctptr, param: paramptr)
        return (Int32(0));
}

@_cdecl("mlx_loop_hook")
public func mlx_loop_hook_swift(_ mlxptr:UnsafeRawPointer, _ fctptr:UnsafeMutableRawPointer, _ paramptr:UnsafeMutableRawPointer) -> Int32
{
	let mlx:MlxMain = _mlx_bridge(ptr:mlxptr)
	mlx.addLoopHook(fctptr, paramptr)
        return (Int32(0));
}


@_cdecl("mlx_do_key_autorepeatoff")
public func mlx_do_key_autorepeatoff_swift(_ mlxptr:UnsafeRawPointer)
{
	let mlx:MlxMain = _mlx_bridge(ptr:mlxptr)
	mlx.winList.forEach{ $0.setKeyRepeat(0) }
}


@_cdecl("mlx_do_key_autorepeaton")
public func mlx_do_key_autorepeatoon_swift(_ mlxptr:UnsafeRawPointer)
{
	let mlx:MlxMain = _mlx_bridge(ptr:mlxptr)
	mlx.winList.forEach{ $0.setKeyRepeat(1) }
}


@_cdecl("mlx_clear_window")
public func mlx_clear_window_swift(_ mlxptr:UnsafeRawPointer, _ winptr:UnsafeRawPointer)
{
	let win:MlxWin = _mlx_bridge(ptr:winptr)
	win.clearWin()
}


@_cdecl("mlx_pixel_put")
public func mlx_pixel_put_swift(_ mlxptr:UnsafeRawPointer, _ winptr:UnsafeRawPointer, _ x:Int32, _ y:Int32, _ color:UInt32)
{
	let win:MlxWin = _mlx_bridge(ptr:winptr)
	win.pixelPut(x, y, color)
}


@_cdecl("mlx_get_color_value")
public func mlx_get_color_value(_ mlxptr:UnsafeRawPointer, _ color:UInt32) -> UInt32
{
    return color
}


@_cdecl("mlx_new_image")
public func mlx_new_image(_ mlxptr:UnsafeRawPointer, _ width:Int32, _ height:Int32) -> UnsafeRawPointer
{
	let mlx:MlxMain = _mlx_bridge(ptr:mlxptr)
	let img = MlxImg(d:mlx.device, w:Int(width), h:Int(height))
	mlx.addImgToList(img)
///	print(CFGetRetainCount(img))
	return (_mlx_bridge_retained(obj:img))

}

@_cdecl("mlx_get_data_addr")
public func mlx_get_data_addr_swift(_ imgptr:UnsafeRawPointer, _ bpp:UnsafeMutablePointer<Int32>, _ sizeline:UnsafeMutablePointer<Int32>, _ endian:UnsafeMutablePointer<Int32>) -> UnsafeMutablePointer<UInt32>
{
	let img:MlxImg = _mlx_bridge(ptr:imgptr)
	bpp.pointee = 32
	sizeline.pointee = Int32(img.texture_sizeline)
	endian.pointee = Int32(0)
	return img.texture_data
}

@_cdecl("mlx_put_image_to_window")
public func mlx_put_image_to_window_swift(_ mlxptr:UnsafeRawPointer, _ winptr:UnsafeRawPointer, _ imgptr:UnsafeRawPointer, _ x:Int32, _ y:Int32) -> Int32
{
	let win:MlxWin = _mlx_bridge(ptr:winptr)
	let img:MlxImg = _mlx_bridge(ptr:imgptr)
	win.putImage(image:img, x:x, y:y)
	return Int32(0)
}

@_cdecl("mlx_put_image_to_window_scale")
public func mlx_put_image_to_window_scale_swift(_ mlxptr:UnsafeRawPointer, _ winptr:UnsafeRawPointer, _ imgptr:UnsafeRawPointer, _ sx:Int32, _ sy:Int32, _ sw:Int32, _ sh:Int32, _ dx:Int32, _ dy:Int32, _ dw:Int32, _ dh:Int32, _ color:UInt32) -> Int32
{
	let win:MlxWin = _mlx_bridge(ptr:winptr)
	let img:MlxImg = _mlx_bridge(ptr:imgptr)
	win.putImageScale(image:img, sx:sx, sy:sy, sw:sw, sh:sh, dx:dx, dy:dy, dw:dw, dh:dh, c:color)
	return Int32(0)
}

@_cdecl("mlx_do_sync")
public func mlx_do_sync_swift(_ mlxptr:UnsafeRawPointer) -> Int32
{
	let mlx:MlxMain = _mlx_bridge(ptr:mlxptr)
	mlx.winList.forEach { $0.flushImages() }
	mlx.winList.forEach { $0.waitForGPU() }
	return Int32(0)
}

@_cdecl("mlx_sync")
public func mlx_sync_swift(_ what:Int32, _ param:UnsafeRawPointer) -> Int32
{
    switch what
    {
	case MLX_SYNC_IMAGE_WRITABLE:
		let img:MlxImg = _mlx_bridge(ptr:param); while img.onGPU > 0 {} 
	case MLX_SYNC_WIN_FLUSH_CMD:
		let win:MlxWin = _mlx_bridge(ptr:param); win.flushImages()
	case MLX_SYNC_WIN_CMD_COMPLETED:
	        let win:MlxWin = _mlx_bridge(ptr:param); win.flushImages(); win.waitForGPU()
	default:
		break
    }
    return Int32(0)
}

@_cdecl("mlx_destroy_window")
public func mlx_destroy_window_swift(_ mlxptr:UnsafeRawPointer, _ winptr:UnsafeRawPointer) -> Int32
{
	let mlx:MlxMain = _mlx_bridge(ptr:mlxptr)
	/// bridge_transfer to get the retain, at end of this func should release the MlxWin object, because no ref anymore.
	let win:MlxWin = _mlx_bridge_transfer(ptr:winptr)
	win.delNotifs()
	win.flushImages()
	win.waitForGPU()
	win.destroyWinE()
	mlx.winList.removeAll(where: { $0 === win} )
	return Int32(0)
}

@_cdecl("mlx_destroy_image")
public func mlx_destroy_image_swift(_ mlxptr:UnsafeRawPointer, _ imgptr:UnsafeRawPointer) -> Int32
{
	let mlx:MlxMain = _mlx_bridge(ptr:mlxptr)
	/// bridge_transfer to get the retain, at end of this func should release the MlxImg object, because no ref anymore.
	let img:MlxImg = _mlx_bridge_transfer(ptr:imgptr)
	mlx.winList.forEach { $0.flushImages() }
	while img.onGPU > 0 {}
	mlx.imgList.removeAll(where: { $0 === img} )
	return Int32(0)
}


@_cdecl("mlx_get_screen_size")
public func mlx_get_screen_size_swift(_ mlxptr:UnsafeRawPointer, _ sizex:UnsafeMutablePointer<Int32>, _ sizey:UnsafeMutablePointer<Int32>) -> Int32
{
	/// let mlx:MlxMain = _mlx_bridge(ptr:mlxptr)
	sizex.pointee = Int32(NSScreen.main!.frame.size.width)
	sizey.pointee = Int32(NSScreen.main!.frame.size.height)
	return Int32(0)
}


@_cdecl("mlx_mouse_hide")
public func mlx_mouse_hide_swift() -> Int32
{
  NSCursor.hide()
  return Int32(0)
}

@_cdecl("mlx_mouse_show")
public func mlx_mouse_show_swift() -> Int32
{
  NSCursor.unhide()
  return Int32(0)
}


@_cdecl("mlx_mouse_move")
public func mlx_mouse_move_swift(_ winptr:UnsafeRawPointer, _ x:Int32, _ y:Int32) -> Int32
{
	let win:MlxWin = _mlx_bridge(ptr:winptr)
	let frame = win.getWinEFrame()
///	let sframe = win.getScreenFrame()
	var pt = CGPoint()
	pt.x = frame.origin.x + CGFloat(x)
///	pt.y = sframe.size.y - frame.size.y - frame.origin.y + 1 + y
	pt.y = frame.origin.y + frame.size.height - 1.0 - CGFloat(y)
	CGWarpMouseCursorPosition(pt)
	CGAssociateMouseAndMouseCursorPosition(UInt32(1))
	return Int32(0);
}



@_cdecl("mlx_mouse_get_pos")
public func mlx_mouse_get_pos_swift(_ winptr:UnsafeRawPointer, _ x:UnsafeMutablePointer<Int32>, _ y:UnsafeMutablePointer<Int32>) -> Int32
{
	let win:MlxWin = _mlx_bridge(ptr:winptr)
	let frame = win.getWinEFrame()
	let point = win.getMouseLoc()
	x.pointee = Int32(point.x)
	y.pointee = Int32(frame.size.height - 1.0 - point.y)
	return Int32(0)
}
