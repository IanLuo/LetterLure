//
//  WODRenderingEngine.m
//  TOP
//
//  Created by ianluo on 14-3-13.
//  Copyright (c) 2014年 WOD. All rights reserved.
//

#import "WODRenderingEngine.h"
#import "GLProgram.h"
#import "WODPramaticSurface.h"

typedef struct VBOInfo VBOInfo;
struct VBOInfo
{
	GLuint vertexBuffer;
	GLuint indexBuffer;
	int indexCount;
};

@interface DrawingElement : NSObject
@property (nonatomic,assign)NSInteger name;
@property (nonatomic,assign)VBOInfo vboInfor;
@property (nonatomic,assign)GLuint textureName;

@property (nonatomic, assign)GLKVector3 translation;
@property (nonatomic, assign)GLKVector2 scale;
@property (nonatomic, assign)GLKMatrix4 rotation;
@property (nonatomic, assign)CGSize size;
@property (nonatomic, assign)float alpha;
@property (nonatomic, strong) NSNumber * userDefineAlpha;

@end

@implementation DrawingElement

- (id)init
{
	self = [super init];
	if (self)
	{
		self.scale = GLKVector2Make(1.0, 1.0);
		self.rotation = GLKMatrix4Identity;
		self.translation = GLKVector3Make(0.0, 0.0, 1.0);
		self.alpha = 1.0;
	}
	return self;
}

@end

@interface WODRenderingEngine()
{
	GLuint positionSlot;
	GLuint textureCoordSlot;
	GLuint adjustColorSlot;
	GLuint projectionMatUniform;
	GLuint modelViewMatUniform;
	GLuint texSampler;
	
	GLuint m_depthRenderbuffer;
	GLuint m_colorRenderbuffer;
	GLuint m_framebuffer;
	
	RenderEnviroment renderEnviroment;
	RenderMode renderMode;
	
	CGFloat * backgroundColorArray;
}

@property (nonatomic, copy)NSMutableArray * drawingElements;
@property (nonatomic, assign) BOOL isBackgroundShouldBeGrayedout;

@end

@implementation WODRenderingEngine

#pragma mark - *** Public *** -
- (void)setEnviroment:(RenderEnviroment)enviroment
{
	renderEnviroment.viewportOrigin = enviroment.viewportOrigin;
	renderEnviroment.viewportSize = enviroment.viewportSize;
	
	//set up viewport
	glViewport(renderEnviroment.viewportOrigin.x, renderEnviroment.viewportOrigin.y, renderEnviroment.viewportSize.width, renderEnviroment.viewportSize.height);	
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
 	CGFloat r,g,b,a;
	[backgroundColor getRed:&r green:&g blue:&b alpha:&a];
	
	backgroundColorArray[0] = r;
	backgroundColorArray[1] = g;
	backgroundColorArray[2] = b;
	backgroundColorArray[3] = a;
}

- (void)createFramebuffers
{
	int width, height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    // Create a depth buffer that has the same size as the color buffer.
    glGenRenderbuffers(1, &m_depthRenderbuffer);
	checkError2("glGenRenderbuffers m_depthRenderbuffer");
    glBindRenderbuffer(GL_RENDERBUFFER, m_depthRenderbuffer);
	checkError2("glBindRenderbuffer m_depthRenderbuffer");
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    checkError2("glRenderbufferStorage");
	
    // Create the framebuffer object.
    glGenFramebuffers(1, &m_framebuffer);
	checkError2("glGenFramebuffers framebuffer");
    glBindFramebuffer(GL_FRAMEBUFFER, m_framebuffer);
	checkError2("glBindFramebuffer framebuffer");
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, m_colorRenderbuffer);
	checkError2("glFramebufferRenderbuffer m_colorRenderbuffer");
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, m_depthRenderbuffer);
	checkError2("glFramebufferRenderbuffer m_depthRenderbuffer");
    glBindRenderbuffer(GL_RENDERBUFFER, m_colorRenderbuffer);
	checkError2("glBindRenderbuffer m_colorRenderbuffer");
	
	NSAssert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE,@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
}

- (void)deleteFramebuffers
{
	glDeleteFramebuffers(1, &m_framebuffer);
}

- (void)createRenderBuffers
{
	glGenRenderbuffers(1, &m_colorRenderbuffer);
	checkError2("glGenRenderbuffers m_colorRenderbuffer");
	glBindRenderbuffer(GL_RENDERBUFFER, m_colorRenderbuffer);
	checkError2("glBindRenderbuffer");
}

- (void)createRenderBuffersOffscreen:(CGSize)size
{
	glGenRenderbuffers(1, &m_colorRenderbuffer);
	checkError2("glGenRenderbuffers m_colorRenderbuffer");
	glBindRenderbuffer(GL_RENDERBUFFER, m_colorRenderbuffer);
	checkError2("glBindRenderbuffer");
	glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, size.width, size.height);
	checkError2("glBindRenderbuffer Storage");
}

- (void)deleteRenderBuffers
{
	glDeleteRenderbuffers(1, &m_colorRenderbuffer);
	glDeleteRenderbuffers(1, &m_depthRenderbuffer);
}

- (void)createDrawingElement:(WODOpenGLESDrawable *)drawable
{
	DrawingElement * newElement = [DrawingElement new];
	newElement.size = drawable.frame.size;
	newElement.name = drawable.name;
	newElement.scale = drawable.scale;
	newElement.translation = drawable.translation;
	newElement.rotation = drawable.rotation;
	newElement.userDefineAlpha = drawable.alpha;

	//remove the old element first, if there is any
	DrawingElement * oldElement = [self findElement:newElement.name];
	[self removedDrawingElementWithElement:oldElement];
	
	//create vbo and upload to gpu
	[self createVBO:newElement surface:drawable.surface];
	
	//load texture and upload to gpu
	if (drawable.name == -1)
	{
		[self loadTexture:newElement image:drawable.image];
		[self.drawingElements insertObject:newElement atIndex:0];
		
		//set the snapsize to the background image size
		renderEnviroment.snapshotSize = CGSizeMake(newElement.size.width, newElement.size.height);
	}
	else
	{
		[self loadTexture:newElement image:drawable.image];
		[self.drawingElements addObject:newElement];
	}
	
	[self setNeedRender:YES];
}

- (void)removedDrawingElement:(WODOpenGLESDrawable *)drawable
{
	DrawingElement * element = [self findElement:drawable.name];
	
	if (drawable.name == -1)
	{
		renderEnviroment.snapshotSize = CGSizeZero;
	}
		
	[self removedDrawingElementWithElement:element];
}

- (void)removedDrawingElementWithElement:(DrawingElement *)element
{
	if (element)
	{
		//remove vbo from gpu
		[self removeVBO:element];
		
		//remove texture from gpu
		[self unloadTexture:element];
		
		//clear drawing element
		[self.drawingElements removeObject:element];
	}
	
	[self setNeedRender:YES];
}

- (void)updateElementImage:(WODOpenGLESDrawable *)drawable
{
	DrawingElement * element = [self findElement:drawable.name];
	
	if (element)
	{
		//1. if size changed, re calculate the vertices
		if (!CGSizeEqualToSize(drawable.frame.size, element.size))
		{
			[self removeVBO:element];
			[self createVBO:element surface:drawable.surface];
			element.size = drawable.frame.size;
		}
		
		//2. reload texture
		[self unloadTexture:element];
		[self loadTexture:element image:drawable.image];
	}
	
	element.userDefineAlpha = drawable.alpha;
	
	[self setNeedRender:YES];
}

- (void)updateElementTransform:(WODOpenGLESDrawable *)drawable
{
	DrawingElement * element = [self findElement:drawable.name];

	if (element)
	{
		element.scale = drawable.scale;
		element.translation = GLKVector3Make(drawable.translation.x, drawable.translation.y, drawable.translation.z);
		element.rotation = drawable.rotation;
	}
	
	[self setNeedRender:YES];
}

- (void)unHighlight
{
	[self.drawingElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
	 {
		 DrawingElement * element = (DrawingElement *)obj;
		 [element setAlpha: 1.0 ];
	 }];
	 
	[self setNeedRender:YES];
}

- (void)highlightElement:(NSUInteger)name
{
	[self.drawingElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
	{
		DrawingElement * element = (DrawingElement *)obj;
		if (element.name != -1)
		{
			[element setAlpha:name == [(DrawingElement *)obj name] ? 1.0 : 0.3];
		}
	}];
	
	[self setNeedRender:YES];
}

- (DrawingElement *)findElement:(NSUInteger)name
{
	NSArray *dea = [self.drawingElements filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name==%d",name]];
	if (dea.count == 0)
		return nil;
	return dea[0];
}

- (void)render:(RenderMode)mode
{
	if (self.needRender)
	{
		renderMode = mode;
		glClearColor(backgroundColorArray[0],backgroundColorArray[1] ,backgroundColorArray[2], backgroundColorArray[3]);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		
		for (DrawingElement * de in self.drawingElements)
		{
			[self renderElement:de];
		}
				
		[self setNeedRender:NO];
	}
}

- (UIImage *)snapshot:(CGFloat)scale
{
	__block NSInteger highlighed = 0;
	
	[self.drawingElements enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		DrawingElement * element = (DrawingElement *)obj;
		if (element.alpha == 1.0)
		{
			highlighed = element.name;
		}
			element.alpha = 1.0;
	}];
	
	[self setNeedRender:YES];
//	[self render:renderMode];

	UIImage * image = [self getScreenSnapshot];
	
	[self highlightElement:highlighed];

	return image;
}

- (UIImage *)snapshotHide:(NSArray *)hideObjs
{
	NSInteger highlighed = 0;
	
	for (NSNumber * nameObj in hideObjs)
	{
		int name = [(NSNumber *)nameObj intValue];
		
		for (DrawingElement * element in self.drawingElements)
		{
			if (element.alpha == 1.0 && element.name != -1)
			{
				highlighed = element.name;
			}
			if (element.name == name)
			{
				element.alpha = 0.0;
			}
			else
			{
				element.alpha = 1.0;
			}
		}
	}
	
	[self setNeedRender:YES];
	[self render:renderMode];
	
	UIImage * image = [self getScreenSnapshot];
	
	[self highlightElement:highlighed];
	
	return image;
}

- (void)setGrayoutBackground:(BOOL)isGrayout
{
	self.isBackgroundShouldBeGrayedout = isGrayout;
	[self setNeedRender:YES];
}

- (void)userFilter:(NSString *)filterName
{
	if ([filterName isEqualToString:@"none"])
	{
		[self useProgrameForKey:@"default"];
	}
	else
	{
		[self useProgrameForKey:filterName];
	}
	
	[self setNeedRender:YES];
}

#pragma mark - *** Private ***

#pragma mark - ** Initialize **
- (id)init
{
	self = [super init];
	if (self)
	{
		[self useProgrameForKey:@"default"];
		
		backgroundColorArray = malloc(4 * sizeof(CGFloat));
		backgroundColorArray[0] = 0.0;
		backgroundColorArray[1] = 0.0;
		backgroundColorArray[2] = 0.0;
		backgroundColorArray[3] = 0.0;
	}
	return self;
}

- (void)initialize
{
	[self createFramebuffers];
	[self setNeedRender:YES];
}

#pragma mark - setup drawing structure

#pragma mark - setup drawing elements


#pragma mark - ** Render **
- (void)renderElement:(DrawingElement *)de
{
	if (de.alpha == 0.0)
	{
		return;
	}
	//set projection matrix
	float w = renderEnviroment.viewportSize.width, h = renderEnviroment.viewportSize.height;
    const GLfloat aspectRatio = w / h;
    const GLfloat fieldView = GLKMathDegreesToRadians(55.0f);
    const GLKMatrix4 projectionMatrix = de.name == -1 ?GLKMatrix4MakeOrtho(-aspectRatio, aspectRatio, -1, 1, 0.1, 1) : GLKMatrix4MakePerspective(fieldView, aspectRatio, 0.01f, 10.0f);
	
	glUniformMatrix4fv(projectionMatUniform, 1, 0, projectionMatrix.m);
	checkError2("glUniformMatrix4fv projectionMatUniform");
	
	GLKMatrix4 modelViewMatrix = GLKMatrix4Identity;
    modelViewMatrix = GLKMatrix4Translate(modelViewMatrix, de.translation.x, de.translation.y, -de.translation.z);
    modelViewMatrix = GLKMatrix4Multiply(modelViewMatrix, de.rotation);
    modelViewMatrix = GLKMatrix4Scale(modelViewMatrix, de.scale.x * renderMode.scale.x , de.scale.y * renderMode.scale.y, 1);
	
	glUniformMatrix4fv(modelViewMatUniform, 1, 0, modelViewMatrix.m);
	checkError2("glUniformMatrix4fv modelViewMatUniform");

	//set the alpha for image
	GLKVector4 color;
	if (de.alpha >= 1.0)
	{
		color = GLKVector4Make(de.userDefineAlpha.floatValue, de.userDefineAlpha.floatValue, de.userDefineAlpha.floatValue, de.userDefineAlpha.floatValue);
	}
	else
	{
		color = GLKVector4Make(de.alpha,de.alpha,de.alpha,de.alpha);
	}
	
	if (de.name == -1) // background image
	{
		float colorComponent = self.isBackgroundShouldBeGrayedout ? 0.5 : 1.0;
		
		color = GLKVector4Make(colorComponent,colorComponent,colorComponent,self.isBackgroundShouldBeGrayedout ? 0.7 : 1);
	}
	glUniform4fv(adjustColorSlot, 1, color.v);
	checkError2("glUniform4fv alpha");
	

	glBindTexture(GL_TEXTURE_2D, de.textureName);
	checkError2("glBindTexture textureName");
	glUniform1i(texSampler, 0);
	checkError2("glUniform1i texSampler");
	
	glEnableVertexAttribArray(positionSlot);
	glEnableVertexAttribArray(textureCoordSlot);
	
	int stride = sizeof(float)*5;
	const GLvoid * texCoordOffset = (const GLvoid*)(sizeof(float)*3);

	glBindBuffer(GL_ARRAY_BUFFER, de.vboInfor.vertexBuffer);
	checkError2("glBindBuffer vertexBuffer");
	glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, stride, 0);
	checkError2("glVertexAttribPointer positionSlot");
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, de.vboInfor.indexBuffer);
	checkError2("glBindBuffer indexBuffer");
	glVertexAttribPointer(textureCoordSlot, 2, GL_FLOAT, GL_FALSE, stride, texCoordOffset);
	checkError2("glVertexAttribPointer textureCoordSlot");
	
	glDrawElements(GL_TRIANGLES, de.vboInfor.indexCount, GL_UNSIGNED_SHORT, 0);
	checkError2("glDrawElements");
}

- (UIImage *)getScreenSnapshot
{
	int s = 1;
    UIScreen* screen = [UIScreen mainScreen];
    if ([screen respondsToSelector:@selector(scale)]) {
        s = (int) [screen scale];
    }
    
    GLint viewport[4];
    glGetIntegerv(GL_VIEWPORT, viewport);
    
    int width = viewport[2];
    int height = viewport[3];
    
    int myDataLength = width * height * 4;
    GLubyte *buffer = (GLubyte *) malloc(myDataLength);

    glReadPixels(0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, buffer);
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer, myDataLength, NULL);
    int bitsPerComponent = 8;
    int bitsPerPixel = 32;
    int bytesPerRow = 4 * width;
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    CGImageRef imageRef = CGImageCreate(width, height, bitsPerComponent, bitsPerPixel, bytesPerRow, colorSpaceRef, bitmapInfo, provider, NULL, true, renderingIntent);
		
	UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), YES, 1);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
	CGImageRelease(imageRef);
	free(buffer);
	
	if (CGSizeEqualToSize(renderEnviroment.snapshotSize, CGSizeZero))
	{
		return image;
	}
	else
	{
		return [WODConstants cropImage:image rect:CGRectMake(0, 0, renderEnviroment.snapshotSize.width, renderEnviroment.snapshotSize.height)];
	}
	
}

#pragma mark - ** Dealloc **
- (void)dealloc
{
	// remove all resources from gpu
#ifdef DEBUGMODE
	NSLog(@"deallocing... %@",[[NSString stringWithUTF8String:__FILE__]lastPathComponent]);
#endif
}

#pragma mark - ** Helper **
- (void)createVBO:(DrawingElement *)element surface:(WODPramaticSurface *)surface
{
	// Create the VBO for the vertices.
	unsigned char flags = VertexFlagsTexCoords;
	int floatsPerVertex = 3;
    if (flags & VertexFlagsNormals)
        floatsPerVertex += 3;
    if (flags & VertexFlagsTexCoords)
        floatsPerVertex += 2;

	unsigned int verticeNumber = (int)[surface getVertexCount] * floatsPerVertex;
	float * vertices = malloc(verticeNumber * sizeof(float));
	[surface generateVertices:vertices flag:flags];
	
	[self checkFloatArrays:vertices length:verticeNumber];
	
	GLuint vertexBuffer;
	glGenBuffers(1, &vertexBuffer);
	checkError2("glBindBuffer vertexBuffer");
	glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
	checkError2("glBindBuffer vertexBuffer");
	glBufferData(GL_ARRAY_BUFFER, verticeNumber * sizeof(vertices[0]), &vertices[0], GL_STATIC_DRAW);
	checkError2("glBufferData vertexBuffer");

	int indexCount = (int)[surface getTriangleIndexCount];
	GLuint indexBuffer;
	GLushort * indices = malloc(indexCount * sizeof(GLushort));
	[surface generateTriangleIndices:indices];
	
	[self checkUShortArrays:indices length:indexCount];
		
	glGenBuffers(1, &indexBuffer);
	checkError2("glBindBuffer indexBuffer");
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
	checkError2("glBindBuffer indexBuffer");
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, indexCount * sizeof(GLushort), &indices[0], GL_STATIC_DRAW);
	checkError2("glBufferData indexCount");
	
	VBOInfo vboInfo = {vertexBuffer, indexBuffer, indexCount};
	element.vboInfor = vboInfo;
	
	free(vertices);
	free(indices);
}

- (void)checkFloatArrays:(float *)array length:(int)length
{
//	for (int i = 0; i < length; i ++)
//	{
//		NSLog(@"%f",array[i]);
//	}
}

- (void)checkUShortArrays:(unsigned short *)array length:(int)length
{
//	for (int i = 0; i < length; i ++)
//	{
//		NSLog(@"%u",array[i]);
//	}
}


- (void)removeVBO:(DrawingElement *)element
{
	GLuint bufferNames[] = {element.vboInfor.vertexBuffer,element.vboInfor.indexBuffer};
	glDeleteBuffers(1, bufferNames);
	checkError2("glDeleteBuffers");
}

- (void)loadTexture:(DrawingElement *)element image:(UIImage *)image
{
	GLuint name;
    glGenTextures(1, &name);
	checkError2("glGenTextures");
	glBindTexture(GL_TEXTURE_2D, name);
	checkError2("glBindTexture");
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

	element.textureName = name;
	
	static GLint maxTextureSize = 0;
	glGetIntegerv(GL_MAX_TEXTURE_SIZE, &maxTextureSize);
    CGFloat scale = 1.0;
	CGFloat maxSide = MAX(element.size.width, element.size.height);

	if (maxSide > maxTextureSize) {
		scale = maxTextureSize/maxSide;
	}
	
	void* data = [self createPixelsFromImage:image scale:scale];
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, element.size.width * scale, element.size.height * scale, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
	checkError2("glTexImage2D image");

	free(data);
	image = nil;
	name= 0;
}

- (void*)createPixelsFromImage:(UIImage *)image scale:(CGFloat)s
{
	int scale = image.scale;
	GLint width = image.size.width * scale * s, height = image.size.height * scale * s;
	GLubyte * data = (GLubyte *) calloc(width * height * 4, sizeof(GLubyte));
		
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef textureContext = CGBitmapContextCreate(data, width, height, 8, width * 4, colorSpace, (CGBitmapInfo)kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast);
	
	CGContextTranslateCTM(textureContext, 0, height);
	CGContextScaleCTM(textureContext, 1, -1);
	CGContextDrawImage(textureContext, CGRectMake(0, 0, width, height), image.CGImage);
	
	CGContextRelease(textureContext);
	CGColorSpaceRelease(colorSpace);
	return data;
}

- (void)unloadTexture:(DrawingElement *)element
{
	GLuint textureName = element.textureName;
	glDeleteTextures(1, &textureName);
	checkError2("glDeleteTextures");
}

- (GLProgram *)compileShaders:(NSString *)vShader fragmentShader:(NSString*)fShader;
{
	GLProgram * program = [[GLProgram alloc] initWithVertexShaderFilename:vShader fragmentShaderFilename:fShader];
	
	[program addAttribute:@"Position"];
	[program addAttribute:@"TexCoordIn"];
	
	if (![program link])
	{
		NSString *progLog = [program programLog];
		NSLog(@"link faild :%@",progLog);
		
		NSLog(@"vertexShaderLog:\n %@",[program vertexShaderLog]);
		NSLog(@"fragmentShaderLog:\n %@",[program fragmentShaderLog]);
		NSLog(@"programLog:\n %@",[program programLog]);
	}
	
	positionSlot = [program attributeIndex:@"Position"];
	textureCoordSlot = [program attributeIndex:@"TexCoordIn"];
	adjustColorSlot = [program uniformIndex:@"AdjustColor"];
	projectionMatUniform = [program uniformIndex:@"Projection"];
	modelViewMatUniform = [program uniformIndex:@"ModelView"];
	texSampler = [program uniformIndex:@"Texture"];

	return program;
}

- (NSMutableArray *)drawingElements
{
	if (!_drawingElements)
	{
		_drawingElements = [NSMutableArray new];
	}
	return _drawingElements;
}

void checkError2(char* msg)
{
	GLenum error = glGetError();
	if (error != GL_NO_ERROR)
	{
		NSLog(@"(%s) error:%x",msg,error);
	}
}

- (void)useProgrameForKey:(NSString *)key
{
	GLProgram * program = nil;
	
	if ([key isEqualToString:@"emboss"])
	{
		program = [self compileShaders:@"default_shader" fragmentShader:[key stringByAppendingString:@"_shader"]];
	}
	if ([key isEqualToString:@"default"])
	{
		program = [self compileShaders:@"default_shader" fragmentShader:@"default_shader"];
	}
	if ([key isEqualToString:@"refraction"])
	{
		program = [self compileShaders:@"default_shader" fragmentShader:@"refraction_shader"];
	}
	
	[program use];
}

@end
