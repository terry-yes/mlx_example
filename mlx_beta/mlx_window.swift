
import Cocoa
import Metal
import MetalKit
import Darwin

import mlx_image


class WinEvent: NSWindow
{
  var eventFuncts = [UnsafeMutableRawPointer?]()
  var eventParams = [UnsafeMutableRawPointer]()

  var keyrepeat = 1
  var keyflag:UInt32 = 0

  var size_y:Int

  init(frame rect:CGRect)
  {
    for _ in 0...31
    {
      eventFuncts.append(Optional.none)
      eventParams.append(UnsafeMutableRawPointer(&keyrepeat)) /// dummy address here, null not needed
    }

    let wsm = NSWindow.StyleMask(rawValue: NSWindow.StyleMask.titled.rawValue|NSWindow.StyleMask.closable.rawValue|NSWindow.StyleMask.miniaturizable.rawValue)
    let bck = NSWindow.BackingStoreType.buffered
    size_y = Int(rect.size.height)
    super.init(contentRect: rect, styleMask: wsm, backing: bck, defer: false)
  }

  func setNotifs()
  {
      NotificationCenter.default.addObserver(self, selector: #selector(exposeNotification(_:)), name: NSWindow.didBecomeKeyNotification, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(deminiaturizeNotification(_:)), name: NSWindow.didDeminiaturizeNotification, object: nil)
      NotificationCenter.default.addObserver(self, selector: #selector(closeNotification(_:)), name: NSWindow.willCloseNotification, object: nil)

/***
      [[NSNotificationCenter defaultCenter] addObserver:win selector:@selector(exposeNotification:) name:@"NSWindowDidBecomeKeyNotification" object:win];
      [[NSNotificationCenter defaultCenter] addObserver:win selector:@selector(deminiaturizeNotification:) name:@"NSWindowDidDeminiaturizeNotification" object:win];
      [[NSNotificationCenter defaultCenter] addObserver:win selector:@selector(closeNotification:) name:@"NSWindowWillCloseNotification" object:win];
***/

  }

  func delNotifs()
  {
      NotificationCenter.default.removeObserver(self, name: NSWindow.willCloseNotification, object: nil)
  }

  public func setKeyRepeat(_ mode:Int)
  {
	keyrepeat = mode;
  }


  func addHook(index idx:Int, fct fptr:UnsafeMutableRawPointer?, param pptr:UnsafeMutableRawPointer)
  {
	eventFuncts[idx] = fptr;
	eventParams[idx] = pptr;
	if (idx == 6 || idx == 32)
	{
		if (fptr != nil) ///  == nullptr)
		   { self.acceptsMouseMovedEvents = true }
		else { self.acceptsMouseMovedEvents = false }
	}
  }


  override func keyDown(with event: NSEvent)
  {
	/// print("got keydown with code: \(event.keyCode) ")
	if (event.isARepeat && keyrepeat == 0)
	 { return }
	if (eventFuncts[2] != nil)
	{
	  _ = unsafeBitCast(eventFuncts[2],to:(@convention(c)(Int32, UnsafeRawPointer)->Int32).self)(Int32(event.keyCode), eventParams[2])
	}
  }


  override func keyUp(with event: NSEvent)
  {
	/// print("got keyup with code: \(event.keyCode) and calling key hook")
	if (event.isARepeat && keyrepeat == 0)
	 { return }
	if (eventFuncts[3] != nil)
	{
	  _ = unsafeBitCast(eventFuncts[3],to:(@convention(c)(Int32, UnsafeRawPointer)->Int32).self)(Int32(event.keyCode), eventParams[3])
	}
  }


  func get_mouse_button(with ev:NSEvent) -> Int
  {
	switch (ev.type) {
  	       case NSEvent.EventType.leftMouseDown,
	       	    NSEvent.EventType.leftMouseUp,
	       	    NSEvent.EventType.leftMouseDragged:
	           return 1;
	       case NSEvent.EventType.rightMouseDown,
	       	    NSEvent.EventType.rightMouseUp,
	            NSEvent.EventType.rightMouseDragged:
	           return 2;
	       case NSEvent.EventType.otherMouseDown,
	            NSEvent.EventType.otherMouseUp,
	            NSEvent.EventType.otherMouseDragged:
	           return 3;
	       default:
	           return 0;
        }
  }



  func mouse(with event: NSEvent, index idx:Int, type t:Int)
  {
	var thepoint:NSPoint
	var button:Int

	thepoint = event.locationInWindow
	button = get_mouse_button(with:event)
	/// button = event.buttonNumber
	/// print(" mouse down button \(event.buttonNumber) at location \(thepoint.x) x \(thepoint.y)")
	if (eventFuncts[idx] != nil)
	{
	  if (t == 0)
	   { _ = unsafeBitCast(eventFuncts[idx],to:(@convention(c)(Int32, Int32, Int32, UnsafeRawPointer)->Int32).self)(Int32(button), Int32(thepoint.x), Int32(size_y-1-Int(thepoint.y)), eventParams[idx]) }
	  if (t == 1)
	   { _ = unsafeBitCast(eventFuncts[idx],to:(@convention(c)(Int32, Int32, UnsafeRawPointer)->Int32).self)(Int32(thepoint.x), Int32(size_y-1-Int(thepoint.y)), eventParams[idx]) }
	}
  }

  override func mouseDown(with event: NSEvent)  { mouse(with:event, index:4, type:0)  }
  override func rightMouseDown(with event: NSEvent)   {	mouse(with:event, index:4, type:0)  }
  override func otherMouseDown(with event: NSEvent)   {	mouse(with:event, index:4, type:0)  }

  override func mouseUp(with event: NSEvent)  { mouse(with:event, index:5, type:0)  }
  override func rightMouseUp(with event: NSEvent)   { mouse(with:event, index:5, type:0)  }
  override func otherMouseUp(with event: NSEvent)   { mouse(with:event, index:5, type:0)  }

  override func mouseMoved(with event: NSEvent)   { mouse(with:event, index:6, type:1)  }
  override func mouseDragged(with event: NSEvent)   { mouse(with:event, index:6, type:1)  }
  override func rightMouseDragged(with event: NSEvent)   { mouse(with:event, index:6, type:1)  }
  override func otherMouseDragged(with event: NSEvent)   { mouse(with:event, index:6, type:1)  }


  override func scrollWheel(with event: NSEvent)
  {
	var thepoint:NSPoint
	var button = 0;

	thepoint = event.locationInWindow
	if (event.deltaY > 0.2) { button = 4; }
	if (event.deltaY < -0.2) { button = 5; }
	if (event.deltaX > 0.2) { button = 6; }
	if (event.deltaX < -0.2) { button = 7; }
        if (button != 0 && eventFuncts[4] != nil)
        {
          _ = unsafeBitCast(eventFuncts[4],to:(@convention(c)(Int32, Int32, Int32, UnsafeRawPointer)->Int32).self)(Int32(button), Int32(thepoint.x), Int32(thepoint.y), eventParams[4])
        }
  } 


  override func flagsChanged(with event: NSEvent)
  {
	var flag:UInt32
	var the_key:Int32
	var val:UInt32

	flag = UInt32(event.modifierFlags.rawValue)
	val = (keyflag|flag)&(~(keyflag&flag))
	if (val == 0)
	    { return }   /// no change - can happen when loosing focus on special key pressed, then re-pressed later
         the_key = 1
	 while (((val >> (the_key-1)) & 0x01)==0)
	  { the_key += 1 }
	 if (flag > keyflag && eventFuncts[2] != nil)
	   { _ = unsafeBitCast(eventFuncts[2],to:(@convention(c)(Int32, UnsafeRawPointer)->Int32).self)(0xFF+the_key, eventParams[2]) }
	 if (flag < keyflag && eventFuncts[3] != nil)
	   { _ = unsafeBitCast(eventFuncts[3],to:(@convention(c)(Int32, UnsafeRawPointer)->Int32).self)(0xFF+the_key, eventParams[3]) }
	 keyflag = flag
  }


  @objc func exposeNotification(_ notification:Notification)
  {
	if (eventFuncts[12] != nil)
	{
	  _ = unsafeBitCast(eventFuncts[12],to:(@convention(c)(UnsafeRawPointer)->Int32).self)(eventParams[12])
	}
  }

  @objc func closeNotification(_ notification:Notification)
  {
	if (eventFuncts[17] != nil)
	{
	  _ = unsafeBitCast(eventFuncts[17],to:(@convention(c)(UnsafeRawPointer)->Int32).self)(eventParams[17])
	}
  }

  @objc func deminiaturizeNotification(_ notification:Notification)
  {
	exposeNotification(notification)
  }

}





struct textureList
{
   var uniformBuffer: MTLBuffer!
   var uniform_data:UnsafeMutablePointer<Float>
   unowned var image:MlxImg
}


public class MlxWin
{
  let vrect: CGRect
  var winE: WinEvent
  var mlayer: CAMetalLayer

  unowned var device: MTLDevice
  var commandQueue: MTLCommandQueue!
  var pipelineState: MTLRenderPipelineState!
  var vertexBuffer: MTLBuffer!

  var texture_list: Array<textureList> = Array()
  var texture_list_count = 0

  var pixel_image:MlxImg
  var pixel_count:Int

  var drawable_image: MlxImg
  var uniq_renderPassDescriptor: MTLRenderPassDescriptor
  var mtl_origin_null : MTLOrigin
  var mtl_size_all : MTLSize
  var doClear = false
  var GPUbatch = 0


  public init(device d:MTLDevice, width w:Int, height h:Int, title t:String)
  {
    vrect = CGRect(x: 100, y: 100, width: w, height: h)
    winE = WinEvent(frame: vrect)

    device = d
    mlayer = CAMetalLayer()
    mlayer.device = device
    mlayer.pixelFormat = .bgra8Unorm
    mlayer.framebufferOnly = true
    mlayer.contentsScale = 1.0 /// winE.screen!.backingScaleFactor
    mlayer.frame = vrect
    winE.contentView! = NSView(frame: vrect)
    winE.contentView!.wantsLayer = true
    winE.contentView!.layer = mlayer
    winE.title = t
    winE.isReleasedWhenClosed = false
    winE.makeKeyAndOrderFront(nil)


    /// drawable_image = MlxImg(d: device, w:Int(CGFloat(vrect.size.width)*winE.screen!.backingScaleFactor), h:Int(CGFloat(vrect.size.height)*winE.screen!.backingScaleFactor), t:1)
    drawable_image = MlxImg(d: device, w:Int(vrect.size.width), h:Int(vrect.size.height), t:1)
    pixel_image = MlxImg(d: device, w:Int(vrect.size.width), h:Int(vrect.size.height))
    for i in 0...(pixel_image.texture_height*pixel_image.texture_sizeline/4-1)
      { pixel_image.texture_data[i] = UInt32(0xFF000000) }
    pixel_count = 0

    mtl_origin_null = MTLOriginMake(0,0,0)
    mtl_size_all = MTLSizeMake(drawable_image.texture.width, drawable_image.texture.height, 1)

    uniq_renderPassDescriptor = MTLRenderPassDescriptor()
    uniq_renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 0.0, blue: 0.0, alpha:0.0)
    uniq_renderPassDescriptor.colorAttachments[0].texture = drawable_image.texture
    uniq_renderPassDescriptor.colorAttachments[0].storeAction = .store
    uniq_renderPassDescriptor.colorAttachments[0].loadAction = .load
  }


/// winEvent calls
  public func getWinEFrame() -> NSRect  { return winE.frame }
  public func getScreenFrame() -> NSRect { return winE.screen!.frame }
  public func getMouseLoc() -> NSPoint { return winE.mouseLocationOutsideOfEventStream }
  public func addHook(index idx:Int, fct fptr:UnsafeMutableRawPointer, param pptr:UnsafeMutableRawPointer)
  {  winE.addHook(index: idx, fct: fptr, param: pptr)  }
  public func setKeyRepeat(_ mode:Int)  { winE.setKeyRepeat(mode) }
  public func destroyWinE()  { winE.close() }
  public func setNotifs() { winE.setNotifs() }
  public func delNotifs() { winE.delNotifs() }


  public func initMetal()
  {
    commandQueue = device.makeCommandQueue()!

    /// vertex buffer & shaders stay the always the same.
    let lib = try! device.makeLibrary(source: shaders, options: nil)
    let vertexFunction = lib.makeFunction(name: "basic_vertex_function")
    let fragmentFunction = lib.makeFunction(name: "basic_fragment_function")
    let pipelineDesc = MTLRenderPipelineDescriptor()
    pipelineDesc.colorAttachments[0].pixelFormat = .bgra8Unorm
    pipelineDesc.colorAttachments[0].isBlendingEnabled = true
    pipelineDesc.colorAttachments[0].rgbBlendOperation = .add
    pipelineDesc.colorAttachments[0].alphaBlendOperation = .add
    pipelineDesc.colorAttachments[0].sourceRGBBlendFactor = .oneMinusSourceAlpha
    pipelineDesc.colorAttachments[0].sourceAlphaBlendFactor = .oneMinusSourceAlpha
    pipelineDesc.colorAttachments[0].destinationRGBBlendFactor = .sourceAlpha
    pipelineDesc.colorAttachments[0].destinationAlphaBlendFactor = .sourceAlpha
    pipelineDesc.vertexFunction = vertexFunction
    pipelineDesc.fragmentFunction = fragmentFunction
    pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDesc)

    let vertexData: [Float] = [
       -1.0, -1.0, 0.0, 1.0,  0.0, 1.0, 0.0, 0.0,
       -1.0, 1.0, 0.0, 1.0,   0.0, 0.0, 0.0, 0.0,
       1.0, -1.0, 0.0, 1.0,   1.0, 1.0, 0.0, 0.0,
       1.0, -1.0, 0.0, 1.0,   1.0, 1.0, 0.0, 0.0,
       -1.0, 1.0, 0.0, 1.0,   0.0, 0.0, 0.0, 0.0,
       1.0, 1.0, 0.0, 1.0,    1.0, 0.0, 0.0, 0.0  ]
    var dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
    vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options: []) 

    let uniformData: [Float] = [ 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Float(vrect.size.width), Float(vrect.size.height), 0.0, 0.0, 0.0, 0.0,
    		     	       1.0, 1.0, 1.0, 1.0 ]
    dataSize = uniformData.count * MemoryLayout.size(ofValue: uniformData[0])
    for _ in 0...255
    { 
      let uniformBuffer = device.makeBuffer(bytes: uniformData, length: dataSize, options: [])!
      let uniform_data = (uniformBuffer.contents()).assumingMemoryBound(to:Float.self)
      texture_list.append(textureList(uniformBuffer:uniformBuffer, uniform_data:uniform_data, image:pixel_image))
    }

    self.clearWin();
  }


  public func clearWin()
  {
	/// discard previous put_images, doClear become first operation in next render pass.
	var i = 0
	while i < texture_list_count
	{
		texture_list[i].image.onGPU -= 1
		i += 1
	}
	texture_list_count = 0
	doClear = true
	///  next flush images should call draw(), even if there is no image to put
  }

  func flushPixels()
  {
	if (pixel_count > 0)
	{
	  pixel_count = 0
	  self.putImage(image:pixel_image, x:0, y:0)
	}
  }

  public func flushImages()
  {
	flushPixels()
	if (texture_list_count > 0 || doClear)
	 {
	    self.draw()
	 }
  }

  public func waitForGPU()
  {
	while (GPUbatch > 0) { }
  }


  public func pixelPut(_ x:Int32, _ y:Int32, _ color:UInt32)
  {
	if (pixel_count == 0)
	{
	  while (pixel_image.onGPU > 0)
	  {
	     if (GPUbatch > 0) { waitForGPU() }
	     else { flushImages() }
	  }
	  for i in 0...pixel_image.texture_height*pixel_image.texture_sizeline/4-1
	    { pixel_image.texture_data[i] = UInt32(0xFF000000) }
	}
	let t = (x&(Int32(vrect.size.width-1)-x))&(y&(Int32(vrect.size.height-1)-y))
	if t >= 0
	{
		pixel_image.texture_data[Int(y)*pixel_image.texture_sizeline/4+Int(x)] = color
		pixel_count += 1
	}
  }

  public func putImage(image img:MlxImg, x posx:Int32, y posy:Int32)
  {
	flushPixels()
	putImageScale(image:img, sx:0, sy:0, sw:Int32(img.texture_width), sh:Int32(img.texture_height), 
			   dx:posx, dy:posy, dw:Int32(img.texture_width), dh:Int32(img.texture_height),
			   c:UInt32(0xFFFFFFFF))
  }

  public func putImageScale(image img:MlxImg, sx src_x:Int32, sy src_y:Int32, sw src_w:Int32, sh src_h:Int32, dx dest_x:Int32, dy dest_y:Int32, dw dest_w:Int32, dh dest_h:Int32, c color:UInt32)
  {
	flushPixels()
	if (texture_list_count == 0) /// means  I just draw
	{
		waitForGPU()    /// to be able to write again in uniforms
	}
	texture_list[texture_list_count].uniform_data[0] = Float(img.texture_width)
	texture_list[texture_list_count].uniform_data[1] = Float(img.texture_height)
	texture_list[texture_list_count].uniform_data[2] = Float(src_x)
	texture_list[texture_list_count].uniform_data[3] = Float(src_y)
	texture_list[texture_list_count].uniform_data[4] = Float(src_w)
	texture_list[texture_list_count].uniform_data[5] = Float(src_h)

	texture_list[texture_list_count].uniform_data[8] = Float(dest_x)
	texture_list[texture_list_count].uniform_data[9] = Float(dest_y)
	texture_list[texture_list_count].uniform_data[10] = Float(dest_w)
	texture_list[texture_list_count].uniform_data[11] = Float(dest_h)

	texture_list[texture_list_count].uniform_data[12] = Float((color>>16)&0xFF)/255.0;
	texture_list[texture_list_count].uniform_data[13] = Float((color>>8)&0xFF)/255.0;
	texture_list[texture_list_count].uniform_data[14] = Float((color>>0)&0xFF)/255.0;
	texture_list[texture_list_count].uniform_data[15] = Float((color>>24)&0xFF)/255.0;

	texture_list[texture_list_count].image = img
	img.onGPU += 1
	
	texture_list_count += 1
	if (texture_list_count == 255) /// keep 1 slot for put_pixels image
	{
		flushImages()
	}
  }


  func draw()
  {
	var commandBuffer = commandQueue.makeCommandBuffer()!

/// clear if asked
	if (doClear)
	{
	  uniq_renderPassDescriptor.colorAttachments[0].loadAction = .clear
	  let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: uniq_renderPassDescriptor)!
	  commandEncoder.endEncoding()
	  uniq_renderPassDescriptor.colorAttachments[0].loadAction = .load
	  doClear = false
	}

/// then draw the images if any.
	var i = 0
	while i < texture_list_count
	{
		let commandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: uniq_renderPassDescriptor)!
		commandEncoder.setRenderPipelineState(pipelineState)
		commandEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
		commandEncoder.setVertexBuffer(texture_list[i].uniformBuffer, offset: 0, index: 1)
		commandEncoder.setFragmentTexture(texture_list[i].image.texture, index: 0)
		commandEncoder.drawPrimitives(type: .triangleStrip, vertexStart: 0, vertexCount: 6, instanceCount:2)
		commandEncoder.endEncoding()
		({ j in
		      commandBuffer.addCompletedHandler { cb in self.texture_list[j].image.onGPU -= 1 }
		})(i)
		i += 1
	}
	texture_list_count = 0
	commandBuffer.addCompletedHandler { cb in self.GPUbatch -= 1 }
        commandBuffer.commit()
	GPUbatch += 1

/// finally copy to MTLdrawable to present, using a new commandqueue
    	commandBuffer = commandQueue.makeCommandBuffer()!
	let curdraw = mlayer.nextDrawable()!

	let commandBEncoder = commandBuffer.makeBlitCommandEncoder()!
	commandBEncoder.copy(from:drawable_image.texture, sourceSlice:0, sourceLevel:0, sourceOrigin: mtl_origin_null, sourceSize: mtl_size_all,  to:curdraw.texture, destinationSlice:0, destinationLevel:0, destinationOrigin: mtl_origin_null)
	commandBEncoder.endEncoding()

	commandBuffer.addCompletedHandler { cb in self.GPUbatch -= 1 }
	commandBuffer.present(curdraw)
        commandBuffer.commit()
	GPUbatch += 1
  }


}




let shaders = """
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position;
    float4 UV;
};
struct VertexOut {
    float4 position [[ position ]];
    float4 color;
    float2 UV;
};
struct uniforms {
   packed_float2 origin_size;
   packed_float2 origin_pos;
   packed_float2 origin_sub;
   packed_float2 dest_size;
   packed_float2 dest_pos;
   packed_float2 dest_sub;
   packed_float4 color;
};
vertex VertexOut basic_vertex_function(const device VertexIn *vertices [[ buffer(0) ]], constant uniforms& uni [[ buffer(1) ]],
uint vertexID [[ vertex_id ]])
{
    VertexOut vOut;
    float4 start = float4((2.0*uni.dest_pos.x)/(uni.dest_size.x-1.0) - 1.0, 1.0 - (2.0*uni.dest_pos.y)/(uni.dest_size.y-1.0) - (uni.dest_sub.y*2.0)/uni.dest_size.y, 0.0, 0.0);
 /*   vOut.position = (start + (vertices[vertexID].position + 1.0) * float4(uni.dest_sub, 0.0, 0.0))/float4(uni.dest_size, 1.0, 1.0); */

    vOut.position = float4(start.x+((vertices[vertexID].position.x + 1.0)*uni.dest_sub.x)/(uni.dest_size.x),
    		    	   start.y+((vertices[vertexID].position.y + 1.0)*uni.dest_sub.y)/(uni.dest_size.y), 0.0, 1.0);

    vOut.UV = (uni.origin_pos + float2(vertices[vertexID].UV.x, vertices[vertexID].UV.y)*(uni.origin_sub-1.0))/(uni.origin_size-1.0);
    vOut.color = uni.color;
    return vOut;
}
fragment float4 basic_fragment_function(VertexOut vIn [[ stage_in ]], texture2d<float> texture [[ texture(0) ]])
{
    constexpr sampler textureSampler(address::clamp_to_edge);
    return vIn.color*texture.sample(textureSampler, vIn.UV);
}
"""

