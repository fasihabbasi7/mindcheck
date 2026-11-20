// MindCurio aurora: three soft ribbons of light that slowly drift and bend,
// like the northern lights. Drawn by the phone's graphics chip (GPU).
#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;       // size of the area in pixels
uniform float uTime;      // seconds since start
uniform vec4 uColorA;     // top ribbon colour
uniform vec4 uColorB;     // middle ribbon colour
uniform vec4 uColorC;     // bottom ribbon colour
uniform float uIntensity; // overall strength, 0 to 1

out vec4 fragColor;

// A cheap, smooth "wobble" made from sine waves.
float wave(vec2 p, float t) {
  return 0.5 * sin(p.x * 1.7 + t * 0.6) +
         0.5 * sin(p.y * 2.3 - t * 0.45 + sin(p.x * 1.3 + t * 0.3));
}

// A soft horizontal ribbon at height [center] that bends with [bend].
float ribbon(vec2 uv, float center, float bend, float width) {
  float d = abs(uv.y - center - bend);
  return smoothstep(width, 0.0, d);
}

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec2 p = uv * vec2(3.0, 2.2);
  float t = uTime;

  float a = ribbon(uv, 0.18, 0.10 * wave(p + vec2(0.0, t * 0.05), t), 0.30);
  float b = ribbon(uv, 0.52, 0.14 * wave(p * 1.3 + vec2(1.7, 0.0), t * 1.2), 0.26);
  float c = ribbon(uv, 0.86, 0.09 * wave(p * 0.8 + vec2(3.1, 0.0), t * 0.8), 0.34);

  // Shimmer: thin vertical curtains inside the ribbons.
  float shimmer = 0.75 + 0.25 * sin(uv.x * 38.0 + t * 1.4 + wave(p, t) * 4.0);

  float total = a + b + c;
  vec3 colour = (uColorA.rgb * a + uColorB.rgb * b + uColorC.rgb * c) /
                max(total, 0.0001);
  float alpha = clamp(total * shimmer * uIntensity, 0.0, 1.0);

  // Flutter expects "premultiplied" colour: rgb already multiplied by alpha.
  fragColor = vec4(colour * alpha, alpha);
}
