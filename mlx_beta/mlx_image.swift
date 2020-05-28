

import Metal


public class MlxImg
{
    public var texture: MTLTexture
///    var texture_buff: MTLBuffer

    public var texture_sizeline: Int
    public var texture_data: UnsafeMutablePointer<UInt32>
    public var texture_width: Int
    public var texture_height: Int

    public var onGPU = 0

     convenience public init(d device:MTLDevice, w width:Int, h height:Int)
     {
	self.init(d:device, w:width, h:height, t:0)
     }

     public init(d device:MTLDevice, w width:Int, h height:Int, t target:Int)
     {
	 texture_width = width
    	 texture_height = height
    	 texture_sizeline = width * 4
    	 texture_sizeline = 256 * (texture_sizeline / 256 + (texture_sizeline%256 >= 1 ? 1 : 0) )

         let textureDesc = MTLTextureDescriptor()
    	 textureDesc.width = texture_width
    	 textureDesc.height = texture_height
	 textureDesc.usage = .shaderRead
	 if (target == 1)
	  {
		textureDesc.usage = .renderTarget
		textureDesc.storageMode = .private
	  }
    	 textureDesc.pixelFormat = MTLPixelFormat.bgra8Unorm
    	 let texture_buff = device.makeBuffer(length: texture_sizeline * height)!
    	 texture = texture_buff.makeTexture(descriptor:textureDesc, offset:0, bytesPerRow:texture_sizeline)!	

	let tmpptr = texture_buff.contents()
	texture_data = tmpptr.assumingMemoryBound(to:UInt32.self)
     }


}