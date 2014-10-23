varying lowp vec2 TexCoordOut;
varying lowp vec4 AdjustColorOut;
uniform sampler2D Texture;

void main(void)
{
	gl_FragColor = texture2D(Texture, TexCoordOut) * AdjustColorOut;
}
