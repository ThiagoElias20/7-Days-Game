shader_type canvas_item;

uniform float noise_strength : hint_range(0.0, 1.0) = 0.08;
uniform float vignette = 0.35;
uniform vec4 tint_color : source_color = vec4(0.27, 0.25, 0.19, 1.0);

float hash(vec2 p){ return fract(sin(dot(p, vec2(127.1,311.7))) * 43758.5453); }

void fragment() {
    vec2 uv = UV;
    float n = hash(floor(uv * 1024.0) + floor(TIME * 30.0));
    vec4 base = tint_color;
    base.rgb += (n - 0.5) * noise_strength;

    vec2 c = uv - 0.5;
    float v = smoothstep(0.9, vignette, length(c));
    base.rgb *= mix(1.0, 0.85, v);

    COLOR = base;
}