precision mediump float;
varying lowp vec2 TexCoordOut;
varying lowp vec4 AdjustColorOut;
uniform sampler2D Texture;

void main(void)
{
	vec2 onePixel = vec2(1.0 / 480.0, 1.0 / 320.0);
	
	vec4 color;
	color.rgb = vec3(0.5);
	color -= texture2D(Texture, TexCoordOut - onePixel) * 5.0;
	color += texture2D(Texture, TexCoordOut + onePixel) * 5.0;
	
	// 5
	color.rgb = vec3((color.r + color.g + color.b) / 3.0);
	gl_FragColor = vec4(color.rgb, texture2D(Texture, TexCoordOut).a) * AdjustColorOut;
}