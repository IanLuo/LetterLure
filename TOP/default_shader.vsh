
attribute vec2 TexCoordIn;
attribute vec4 Position;

uniform vec4 AdjustColor;
uniform mat4 Projection;
uniform mat4 ModelView;

varying vec2 TexCoordOut;
varying vec4 AdjustColorOut;

void main(void)
{
	TexCoordOut = TexCoordIn;
	AdjustColorOut = AdjustColor;
	gl_Position = Projection * ModelView * Position;
}