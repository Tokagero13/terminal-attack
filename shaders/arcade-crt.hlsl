// Retro arcade CRT for Windows Terminal.
// Crisp text + glow, scanlines, vignette, rolling band, flicker,
// scrolling starfield and a spinning coin in place of the cursor.

Texture2D shaderTexture;
SamplerState samplerState;

cbuffer PixelShaderSettings {
    float  Time;
    float  Scale;
    float2 Resolution;
    float4 Background;
};

#define GLOW_STRENGTH   0.6   // halo around text
#define SCANLINE_DARK   0.28  // how dark the scanlines are (0 = off)
#define SCANLINE_SIZE   3.0   // pixels per scanline period
#define VIGNETTE        0.35  // corner darkening (0 = off)
#define STARS           1.0   // starfield brightness (0 = off)
#define STAR_SPEED      18.0  // starfield scroll, pixels per second
#define COIN_SPEED      4.0   // coin spin speed
#define COIN_SIZE       1.9   // coin width relative to the cursor cell (1 = fits the cell, max ~2.2 = cell height)
#define BAND            0.05  // rolling CRT band brightness (0 = off)
#define FLICKER         0.015 // brightness flicker (0 = off)

// Must match cursorColor of the arcade style (#FFCC01); the shader finds the cursor by it.
static const float3 CURSOR = float3(1.0, 0.8, 1.0 / 255.0);

float luma(float3 c) { return dot(c, float3(0.299, 0.587, 0.114)); }
float hash(float2 p) { return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453); }

bool isCursor(float2 uv)
{
    float3 s = shaderTexture.SampleLevel(samplerState, uv, 0).rgb;
    return all(abs(s - CURSOR) < 0.012);
}

// Screen sample with the cursor block erased, so the glow never outlines it.
float3 tap(float2 uv)
{
    float3 s = shaderTexture.SampleLevel(samplerState, uv, 0).rgb;
    return all(abs(s - CURSOR) < 0.012) ? Background.rgb : s;
}

// tex = this pixel, hit = a cursor pixel on the same row (may be this one), orig = this pixel's colour.
float3 coin(float2 tex, float2 hit, float2 px, float3 orig, bool inBox)
{
    // Measure the cursor box from the hit pixel.
    float l = 0, r = 0, u = 0, d = 0;
    [loop] for (int i = 1; i < 64; i++) { if (!isCursor(hit - float2(i * px.x, 0))) break; l = i; }
    [loop] for (int j = 1; j < 64; j++) { if (!isCursor(hit + float2(j * px.x, 0))) break; r = j; }
    [loop] for (int k = 1; k < 64; k++) { if (!isCursor(hit - float2(0, k * px.y))) break; u = k; }
    [loop] for (int m = 1; m < 64; m++) { if (!isCursor(hit + float2(0, m * px.y))) break; d = m; }

    float  ox = (tex.x - hit.x) / px.x;
    float2 p = float2(ox - (r - l) * 0.5, (u - d) * 0.5);     // pixel offset from box centre
    float  R = min((l + r + 1) * 0.48 * COIN_SIZE, (u + d + 1) * 0.48);
    float  spin = cos(Time * COIN_SPEED);
    float  rx = max(R * abs(spin), 1.0);
    float  e = (p.x * p.x) / (rx * rx) + (p.y * p.y) / (R * R);

    if (e > 1.0) return inBox ? Background.rgb : orig;

    float3 gold = spin > 0 ? float3(1.0, 0.80, 0.10) : float3(0.90, 0.65, 0.05);
    if (e > 0.55) gold = float3(0.75, 0.50, 0.03);                      // rim
    float sx = p.x / rx;
    if (sx > -0.55 && sx < -0.2 && e < 0.55) gold = float3(1.0, 0.97, 0.65); // shine
    gold *= lerp(0.55, 1.0, abs(spin));                                  // darker edge-on
    return gold * 1.15;
}

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET
{
    float4 color = shaderTexture.Sample(samplerState, tex);
    float2 px = 1.0 / Resolution;

    // The coin can be wider than the cursor cell, so also look left/right for the cursor.
    static const float probes[6] = { 5, -5, 10, -10, 15, -15 };
    bool   inBox = isCursor(tex);
    bool   found = inBox;
    float2 hit   = tex;
    [unroll] for (int s = 0; s < 6; s++) {
        float2 q = tex + float2(probes[s] * px.x, 0);
        if (!found && isCursor(q)) { found = true; hit = q; }
    }
    if (found) color.rgb = coin(tex, hit, px, color.rgb, inBox);

    static const float2 dirs[8] = {
        float2( 1, 0), float2(-1, 0), float2(0,  1), float2(0, -1),
        float2( 0.707, 0.707), float2(-0.707, 0.707),
        float2( 0.707,-0.707), float2(-0.707,-0.707)
    };

    float3 glow = 0;
    [unroll] for (int i = 0; i < 8; i++) {
        glow += tap(tex + dirs[i] * px * 2.5);  // one ring of 8 samples keeps the GPU cost down
    }
    glow /= 8.0;

    float dark = saturate(1.0 - luma(color.rgb) * 1.5);
    float3 c = color.rgb + glow * GLOW_STRENGTH * dark;

    // Starfield, only in empty background away from text.
    if (luma(c) < 0.03) {
        float2 sp   = float2(pos.x, pos.y - Time * STAR_SPEED);
        float2 cell = floor(sp / 36.0);
        float  h    = hash(cell);
        float2 star = cell * 36.0 + float2(hash(cell + 1.7), hash(cell + 3.1)) * 36.0;
        float  dist = length(sp - star);
        if (h > 0.55 && dist < 1.3) {
            float twinkle = 0.4 + 0.6 * abs(sin(Time * (1.5 + h * 3.0) + h * 40.0));
            float3 tint = h > 0.85 ? float3(0.4, 1.0, 1.0) : h > 0.7 ? float3(1.0, 0.6, 1.0) : float3(1, 1, 1);
            c += tint * twinkle * (1.3 - dist) * STARS;
        }
    }

    // Scanlines
    float scan = fmod(pos.y, SCANLINE_SIZE) < 1.0 ? 1.0 - SCANLINE_DARK : 1.0;
    c *= scan;

    // Rolling CRT band
    float b = frac(tex.y - Time * 0.12) - 0.5;
    c += BAND * exp(-b * b * 400.0);

    // Flicker
    c *= 1.0 - FLICKER + FLICKER * sin(Time * 55.0);

    // Vignette
    float2 v = tex - 0.5;
    c *= 1.0 - VIGNETTE * dot(v, v) * 2.0;

    return float4(saturate(c), color.a);
}
