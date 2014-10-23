//
//  WODExportManager.m
//  TOP
//
//  Created by ianluo on 13-12-13.
//  Copyright (c) 2013年 WOD. All rights reserved.
//

#import "WODExportManager.h"
//#import <QuartzCore/QuartzCore.h>
//#import <OpenGLES/ES2/gl.h>
//#include <OpenGLES/ES2/glext.h>
//#import "GLProgram.h"
//#import "GLCommon.h"
//#import <GLKit/GLKit.h>

//const float Vertices[] = {
//	-1.0f, -1.0f, 0.0f,
//	1.0f, -1.0f, 0.0f,
//	-1.0f,  1.0f, 0.0f,
//	1.0f,  1.0f, 0.0f,
//};
//
//const float TextureVertices[] = {
//	0.0f, 0.0f,
//	1.0f, 0.0f,
//	0.0f, 1.0f,
//	1.0f, 1.0f,
//};

@implementation WODExportManager
{
//	int scaleFactor;
//	GLuint _projectionUniform;
//	GLuint _modelViewUniform;
//	GLuint _positionSlot;
//	GLuint _texCoordSlot;
//	GLuint _textureUniform;
//	GLuint _outputTexture;
//	GLuint _offsetUniform;
//	GLuint _affineTransformUniform;
//	
//	GLuint _colorRenderBuffer;
//	
//	EAGLContext * _context;
//	
//	CGSize textSize;
}

//- (id)init
//{
//	self = [super init];
//	if (self)
//	{
//		scaleFactor = 1;
//		UIScreen* screen = [UIScreen mainScreen];
//		if ([screen respondsToSelector:@selector(scale)])
//			scaleFactor = (int) [screen scale];
//	}
//	return self;
//}
//
//- (void)setCanvasSize:(CGSize)canvasSize
//{
//	if (scaleFactor > 1)
//	{
//		_canvasSize = CGSizeMake(canvasSize.width * scaleFactor, canvasSize.height * scaleFactor);
//	}
//	else
//	{
//		_canvasSize = canvasSize;
//	}
//}
//
//- (void)setTextView:(WODTextView *)textView
//{
//	_textView = textView;
//	
//	textSize = CGSizeMake(_textView.bounds.size.width * scaleFactor, _textView.bounds.size.height * scaleFactor);
//	
//	_context = [[EAGLContext alloc]initWithAPI:kEAGLRenderingAPIOpenGLES2];
//	if (!_context)
//	{
//		NSLog(@"ERROR can't create context");
//		exit(1);
//	}
//	
//	if(![EAGLContext setCurrentContext:_context])
//	{
//		NSLog(@"ERROR can't set current context");
//		exit(1);
//	}
//	
//	[self compileShaders];
//	[self loadTexture];
//	[self setupFrameBuffer];
//}
//
//- (UIImage *)renderTextWithOpenGLES2
//{
//	// clear frame buffer
//	glClearColor(0.0f, 0.0f, 0.0f, 0.0f); // ARGB
//	checkError("glClearColor");
//	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//	checkError("glClear");
//	
//	glViewport(0, 0, self.canvasSize.width, self.canvasSize.height);
//
//	//load texture
//	glActiveTexture(GL_TEXTURE0);
//	checkError("glActiveTexture");
//	glBindTexture(GL_TEXTURE_2D, _outputTexture);
//	checkError("glBindTexture");
//	glUniform1i(_textureUniform, 0);
//	checkError("glUniform1i");
//	
//	
//	// create perspective projection matrix
//	// show the image full screen as the original size
//    GLfloat projectionMatrix[16];
//	GLfloat s = 0.666666666666667;
//	CGSize size = [WODConstants currentSize];
//	GLfloat aspect = size.width/size.height;
////	Matrix3DSetPerspectiveProjectionWithFieldOfView(projectionMatrix, 50, 2.0f, 1000.0f, aspect);
//	Matrix3DSetFrustumProjection(projectionMatrix, -1, 1, -1, 1, 2.0, 1000.0);
//	
//	glUniformMatrix4fv(_projectionUniform, 1, 0, projectionMatrix);
//	
//	//this function not used because the x axis rotation is inverted and current haven't figured out how to fix
//	CATransform3D t = CATransform3DIdentity;//_textView.transformLayer.transform;
//	GLfloat mv2[16];
//	[self convert3DTransform:(CATransform3D*)&t toMatrix:mv2];
//		
//	//load the x and y axis rotation from value saved ealier
//	CGPoint rotationValue = CGPointZero;//[_textView.rotation3DValue CGPointValue];
//	//		viewToPerformAction.transformLayer.transform = CATransform3DRotate(CATransform3DMakeRotation(M_PI*unitPosition.x, 0, 1, 0), -M_PI*unitPosition.y, 1, 0, 0);
//
//	GLKMatrix4 r = GLKMatrix4Rotate(GLKMatrix4MakeRotation(M_PI * rotationValue.x, 0, 1, 0), -M_PI * rotationValue.y, 1, 0, 0);
//	
//	// move the whole image further to make it visible, becase the near plane is 2, so make it -3.
//	GLfloat translate[16];
//	GLfloat mvResult[16];
//	Matrix3DSetTranslation(translate, 0, 0, -3);
//	Matrix3DMultiply(translate, r.m, mvResult);
//	glUniformMatrix4fv(_modelViewUniform, 1, 0, mvResult);
//	
//	// calculate and loat affine transformation, which is scale and rotate on the screen (2D scale and roate)
//	GLfloat affineTransformR[16],affineTransformS[16],affineTransform[16];
//	CGAffineTransform affineTransformMatrix = CGAffineTransformIdentity;// _textView.transform;
//	float angle = atan2(affineTransformMatrix.b, affineTransformMatrix.a);
//	float scaleH = sqrt(pow(affineTransformMatrix.a, 2)+pow(affineTransformMatrix.c, 2));
//	float sclaeV = sqrt(pow(affineTransformMatrix.b,2)+pow(affineTransformMatrix.d, 2));
////	CGAffineTransform fixedAffinetransformMatrix = CGAffineTransformMakeRotation(-2 * angle);
////	CATransform3D affineTransform3D = CATransform3DMakeAffineTransform(_textView.transform);
////	[self convert3DTransform:&affineTransform3D toMatrix:affineTransform];
//
//	Matrix3DSetZRotationUsingRadians(affineTransformR, -angle);
//	Matrix3DSetScaling(affineTransformS, scaleH, sclaeV, 1);
//	Matrix3DMultiply(affineTransformS, affineTransformR, affineTransform);
//	glUniformMatrix4fv(_affineTransformUniform, 1, 0, affineTransform);
//	
//	// enable vertex attributes array
//	glEnableVertexAttribArray(_positionSlot);
//	glEnableVertexAttribArray(_texCoordSlot);
//	
//	//calculate translation on the screen based on the frame's origin value
//	CGPoint center = _textView.center;
//	float W = self.canvasSize.width, H = self.canvasSize.height;
//	float cX = center.x * scaleFactor, cY = center.y * scaleFactor;
//	float w = textSize.width/2;
//	float h = textSize.height/2;
//	float ox = -(W/2 - cX)/W;
//	float oy = (H/2 - cY)/H;
//	
//	float offset[16];
//	Matrix3DSetTranslation(offset, ox*2, oy*2, 0); // don't know why need to multipy by 2, but it works.
//	glUniformMatrix4fv(_offsetUniform, 1, 0, offset);
//	
//	float newVertices[16] = {
//		-w/W, -h/H,
//		w/W, -h/H,
//		-w/W, h/H,
//		w/W, h/H,
//	};
//	
//
//	// load vertexes for texture and frame content position
//	glVertexAttribPointer(_texCoordSlot, 2 , GL_FLOAT, GL_FALSE, 0, TextureVertices);
//	glVertexAttribPointer(_positionSlot, 2, GL_FLOAT, GL_FALSE, 0, newVertices);
//	checkError("glVertexAttribPointer");
//	checkError("glVertexAttribPointer");
//			
//	// draw the frame
//	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
//	checkError("glDrawArrays");
//		
//	//snapshot
//	return [self snapUIImage];
//}
//
//- (void)setupFrameBuffer
//{
//	GLuint frameBuffer;
//	glGenFramebuffers(1, &frameBuffer);
//	checkError("glGenFramebuffers");
//	glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
//	checkError("glBindFramebuffer");
//	
//	glGenRenderbuffers(1, &_colorRenderBuffer);
//	checkError("glGenRenderbuffers");
//	glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
//	checkError("glBindRenderbuffer");
//	glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA4, self.canvasSize.width, self.canvasSize.height);
//	checkError("glRenderbufferStorage");
//	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
//	checkError("glFramebufferRenderbuffer");
//	
//	GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
//	NSAssert(status == GL_FRAMEBUFFER_COMPLETE,@"failed to make complete framebuffer object %x", status);
//		
//	checkError("glViewport");
//}
//
//- (void)loadTexture
//{
//	glActiveTexture(GL_TEXTURE0);
//	glGenTextures(1, &_outputTexture);
//	glBindTexture(GL_TEXTURE_2D, _outputTexture);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
//	checkError("glTexParameteri 1");
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
//	checkError("glTexParameteri 2");
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
//	checkError("glTexParameteri 3");
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
//	checkError("glTexParameteri 4");
//	
//	GLint width = textSize.width, height = textSize.height;
//	GLubyte * data = (GLubyte *) calloc(textSize.width * textSize.height * 4, sizeof(GLubyte));
//	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//	CGContextRef textureContext = CGBitmapContextCreate(data, width, height, 8, width * 4, colorSpace, (CGBitmapInfo)kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedFirst);
//	CGContextScaleCTM(textureContext, scaleFactor, scaleFactor);
////	[_textView.layer renderInContext:textureContext];
//	CGContextRelease(textureContext);
//	CGColorSpaceRelease(colorSpace);
//	
//	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textSize.width, textSize.height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
//	checkError("glTexImage2D");
//	
//	free(data);
//	
//	glBindTexture(GL_TEXTURE_2D, 0);
//	checkError("glBindTexture");
//}
//
//-(UIImage *)snapUIImage
//{
//    const int w = self.canvasSize.width/2 ;
//    const int h = self.canvasSize.height/2 ;
//    const NSInteger myDataLength = w * h * scaleFactor * scaleFactor * 4;
//    // allocate array and read pixels into it.
//    GLubyte *buffer = (GLubyte *) malloc(myDataLength);
//	
//	glPixelStorei(GL_PACK_ALIGNMENT, 4);
//    glReadPixels(0, 0, w*scaleFactor, h*scaleFactor, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
//    // gl renders "upside down" so swap top to bottom into new array.
//    // there's gotta be a better way, but this works.
//    GLubyte *buffer2 = (GLubyte *) malloc(myDataLength);
//    for(int y = 0; y < h * scaleFactor; y++)
//    {
//        memcpy( buffer2 + (h * scaleFactor - 1 - y) * w * 4 * scaleFactor, buffer + (y * 4 * w * scaleFactor), w * 4 * scaleFactor );
//    }
//    free(buffer); // work with the flipped buffer, so get rid of the original one.
//	
//    // make data provider with data.
//    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, myDataLength, NULL);
//    // prep the ingredients
//    int bitsPerComponent = 8;
//    int bitsPerPixel = 32;
//    int bytesPerRow = 4 * w * scaleFactor;
//    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
//    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big|kCGImageAlphaPremultipliedFirst;
//    CGColorRenderingIntent renderingIntent = kCGRenderingIntentRelativeColorimetric;
//    // make the cgimage
//    CGImageRef imageRef = CGImageCreate(w * scaleFactor, h * scaleFactor, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
//    // then make the uiimage from that
//    UIImage *myImage = [UIImage imageWithCGImage:imageRef scale:scaleFactor orientation:UIImageOrientationUp ];
//    CGImageRelease(imageRef);
//    CGDataProviderRelease(provider);
//    CGColorSpaceRelease(colorSpaceRef);
//    free(buffer2);
//	
////	NSString * path = [NSHomeDirectory() stringByAppendingString:@"/Documents/dev/image/text.png"];
////	[UIImagePNGRepresentation(myImage) writeToFile:path atomically:NO];
//	
//	return myImage;
//}
//
//void checkError(char* msg)
//{
//#ifdef DEBUGMODE
//	GLenum error = glGetError();
//	if (error != GL_NO_ERROR)
//	{
//		NSLog(@"(%s) error:%x",msg,error);
//	}
//#endif
//}
//
//- (void)compileShaders
//{
//	GLProgram * program = [[GLProgram alloc] initWithVertexShaderFilename:@"shader" fragmentShaderFilename:@"shader"];
//	
//	[program addAttribute:@"Position"];
//	[program addAttribute:@"TexCoordIn"];
//
//	if (![program link])
//	{
//		NSString *progLog = [program programLog];
//		NSLog(@"link faild :%@",progLog);
//		
//		NSLog(@"vertexShaderLog:\n %@",[program vertexShaderLog]);
//		NSLog(@"fragmentShaderLog:\n %@",[program fragmentShaderLog]);
//		NSLog(@"programLog:\n %@",[program programLog]);
//	}
//	_positionSlot = [program attributeIndex:@"Position"];
//	checkError("_positionSlot");
//	_texCoordSlot = [program attributeIndex:@"TexCoordIn"];
//	checkError("_texCoordSlot");
//	
//	_projectionUniform = [program uniformIndex:@"Projection"];
//	checkError("_projectionUniform");
//	_textureUniform = [program uniformIndex:@"Texture"];
//	checkError("_textureUniform");
//	_modelViewUniform = [program uniformIndex:@"ModelView"];
//	checkError("_modelViewUniform");
//	_offsetUniform = [program uniformIndex:@"offset"];
//	checkError("_offsetUniform");
//	_affineTransformUniform = [program uniformIndex:@"AffineTransform"];
//	checkError("_affineTransformUniform");
//	
//	[program use];
//}
//
//- (void)convert3DTransform:(CATransform3D *)transform3D toMatrix:(GLfloat *)matrix;
//{
//	matrix[0] = (CGFloat)transform3D->m11;
//	matrix[1] = (CGFloat)transform3D->m12;
//	matrix[2] = (CGFloat)transform3D->m13;
//	matrix[3] = (CGFloat)transform3D->m14;
//	matrix[4] = (CGFloat)transform3D->m21;
//	matrix[5] = (CGFloat)transform3D->m22;
//	matrix[6] = (CGFloat)transform3D->m23;
//	matrix[7] = (CGFloat)transform3D->m24;
//	matrix[8] = (CGFloat)transform3D->m31;
//	matrix[9] = (CGFloat)transform3D->m32;
//	matrix[10] = (CGFloat)transform3D->m33;
//	matrix[11] = (CGFloat)transform3D->m34;
//	matrix[12] = (CGFloat)transform3D->m41;
//	matrix[13] = (CGFloat)transform3D->m42;
//	matrix[14] = (CGFloat)transform3D->m43;
//	matrix[15] = (CGFloat)transform3D->m44;
//
//}
//
//
//
////- (UIImage *)generateImage
////{
////    _transform = _textView.transformLayer.transform;
////	
////    _denominatorx = _transform.m12 * _transform.m21 - _transform.m11  * _transform.m22 + _transform.m14 * _transform.m22 * _transform.m41 - _transform.m12 * _transform.m24 * _transform.m41 - _transform.m14 * _transform.m21 * _transform.m42 +
////    _transform.m11 * _transform.m24 * _transform.m42;
////	
////    _denominatory = -_transform.m12 *_transform.m21 + _transform.m11 *_transform.m22 - _transform.m14 *_transform.m22 *_transform.m41 + _transform.m12 *_transform.m24 *_transform.m41 + _transform.m14 *_transform.m21 *_transform.m42 -
////    _transform.m11* _transform.m24 *_transform.m42;
////	
////    _denominatorw = _transform.m12 *_transform.m21 - _transform.m11 *_transform.m22 + _transform.m14 *_transform.m22 *_transform.m41 - _transform.m12 *_transform.m24 *_transform.m41 - _transform.m14 *_transform.m21 *_transform.m42 +
////    _transform.m11 *_transform.m24 *_transform.m42;
////	
////    _rect = _textView.bounds;
////	
////    if ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
////        ([UIScreen mainScreen].scale == 2.0)) {
////        _factor = 2.0f;
////    } else {
////        _factor = 1.0f;
////    }
////	
////    const int width = _rect.size.width;
////    const int height = _rect.size.height;
////	
////    NSUInteger bytesPerPixel = 4;
////    NSUInteger bytesPerRow = bytesPerPixel * width * _factor;
////    NSUInteger bitsPerComponent = 8;
////	NSUInteger dataLength = height * _factor * width * _factor * bytesPerPixel;
////	
////    unsigned char *inputData = malloc(dataLength);
////    unsigned char *outputData = malloc(dataLength);
////	
////    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
////    CGContextRef context = CGBitmapContextCreate(inputData, width * _factor, height * _factor,
////                                                 bitsPerComponent, bytesPerRow, colorSpace,
////                                                 kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Big);
////	CGContextScaleCTM(context, _factor, _factor);
////	CGContextTranslateCTM(context, 0, height*_factor);
////	CGContextScaleCTM(context, 1, -1);
////	[_textView.layer renderInContext:context];
////	
////	CGImageRef cgImage = CGBitmapContextCreateImage(context);
////	
////    CGContextRelease(context);
////	
////    for (int y = 0 ; y < height * _factor ; ++y)
////	for (int x = 0 ; x < width * _factor ; ++x)
////    {
////        NSUInteger indexOutput = 4 * x + 4 * width* _factor * y;
////		
////        CGPoint p = [self modelToScreenX:(x*2/_factor - _rect.size.width)/2.0 andY:(y*2/_factor - _rect.size.height)/2.0];
////		
////        p.x *= _factor;
////        p.y *= _factor;
////		
////        NSUInteger indexInput = bytesPerPixel*(int)p.x + (bytesPerRow*(int)p.y);
////		
////        if (p.x >= width* _factor || p.x < 0 || p.y >= height* _factor || p.y < 0 || indexInput >  width* _factor * height* _factor *4)
////        {
////            outputData[indexOutput] = 0.0;
////            outputData[indexOutput+1] = 0.0;
////            outputData[indexOutput+2] = 0.0;
////            outputData[indexOutput+3] = 0.0;
////        }
////        else
////        {
////            outputData[indexOutput] = inputData[indexInput];
////            outputData[indexOutput+1] = inputData[indexInput + 1];
////            outputData[indexOutput+2] = inputData[indexInput + 2];
////            outputData[indexOutput+3] = inputData[indexInput + 3];
////        }
////    }
////	
////    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, outputData, dataLength, NULL);
////    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
////    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Big|kCGImageAlphaPremultipliedFirst;
////    CGColorRenderingIntent renderingIntent = kCGRenderingIntentRelativeColorimetric;
////    // make the cgimage
////    CGImageRef imageRef = CGImageCreate(width * _factor, height * _factor, bitsPerComponent, bytesPerPixel * 8, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, NO, renderingIntent);
////    // then make the uiimage from that
////    UIImage *myImage = [UIImage imageWithCGImage:imageRef scale:scaleFactor orientation:UIImageOrientationUp ];
//////    UIImage* rawImage = [UIImage imageWithCGImage:imageRef];
////	CGImageRelease(imageRef);
////	CGColorSpaceRelease(colorSpaceRef);
////    free(inputData);
////    free(outputData);
////    return myImage;
////}
//
//- (CGPoint) modelToScreenX:(CGFloat)x andY:(CGFloat)y
//{
//    CGFloat xp = (_transform.m22 *_transform.m41 - _transform.m21 *_transform.m42 - _transform.m22* x + _transform.m24 *_transform.m42 *x + _transform.m21* y - _transform.m24* _transform.m41* y) / _denominatorx;
//    CGFloat yp = (-_transform.m11 *_transform.m42 + _transform.m12 * (_transform.m41 - x) + _transform.m14 *_transform.m42 *x + _transform.m11 *y - _transform.m14 *_transform.m41* y) / _denominatory;
//    CGFloat wp = (_transform.m12 *_transform.m21 - _transform.m11 *_transform.m22 + _transform.m14*_transform.m22* x - _transform.m12 *_transform.m24* x - _transform.m14 *_transform.m21* y + _transform.m11 *_transform.m24 *y) / _denominatorw;
//	
//    CGPoint result = CGPointMake(xp/wp, yp/wp);
//    return result;
//}

@end
