extends TextEdit

var keyword_list := [
	"true",
	"false",
	"void",
	"bool",
	"bvec2",
	"bvec3",
	"bvec4",
	"int",
	"ivec2",
	"ivec3",
	"ivec4",
	"uint",
	"uvec2",
	"uvec3",
	"uvec4",
	"float",
	"vec2",
	"vec3",
	"vec4",
	"mat2",
	"mat3",
	"mat4",
	"sampler2D",
	"isampler2D",
	"usampler2D",
	"sampler2DArray",
	"isampler2DArray",
	"usampler2DArray",
	"sampler3D",
	"isampler3D",
	"usampler3D",
	"samplerCube",
	"samplerExternalOES",
	"flat",
	"smooth",
	"const",
	"lowp",
	"mediump",
	"highp",
	"if",
	"else",
	"for",
	"while",
	"do",
	"switch",
	"case",
	"default",
	"break",
	"continue",
	"return",
	"discard",
	"uniform",
	"varying",
	"in",
	"out",
	"inout",
	"render_mode",
	"hint_white",
	"hint_black",
	"hint_normal",
	"hint_aniso",
	"hint_albedo",
	"hint_black_albedo",
	"hint_color",
	"hint_range",
	"shader_type",
]

var keyword_color : Color = Color8(255, 112, 133, 255)
var comment_color : Color = Color8(203, 205, 207, 128)

# Called when the node enters the scene tree for the first time.
func _ready():
	for keyword in keyword_list:
		add_keyword_color(keyword, keyword_color);
	
	add_color_region("/*", "*/", comment_color, false);
	add_color_region("//", "", comment_color, false);

