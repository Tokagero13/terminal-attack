// Matrix style for Windows Terminal.
// Old-TV look (pixelated, curved, phosphor mask, scanlines, grain) + green glow
// + digital glyph rain in the empty background.

Texture2D shaderTexture;
SamplerState samplerState;

cbuffer PixelShaderSettings {
    float  Time;
    float  Scale;
    float2 Resolution;
    float4 Background;
};

#define GLOW_STRENGTH   0.5   // overall glow intensity
#define GLOW_RADIUS     2.5   // glow spread in pixels
#define CONTOUR         0.08  // tight outline intensity (higher = thicker-looking text)

#define PIXEL_SIZE      2.0   // size of the chunky TV pixels (1 = off)
#define CURVE           0.025 // screen bulge (0 = flat)
#define MASK            0.25  // RGB phosphor stripes (0 = off)
#define SCANLINE_DARK   0.3   // scanline darkness (0 = off)
#define GRAIN           0.05  // film grain / noise (0 = off)
#define VIGNETTE        0.45  // corner darkening (0 = off)

#define RAIN            0.2  // background digital rain brightness (0 = off)
#define RAIN_SPEED      1.0   // rain fall speed multiplier
#define RAIN_BIT        4.0   // pixels per glyph dot (bigger = larger rain glyphs)
#define RAIN_DROPS      3     // drops per column (more = denser rain, fewer gaps)

// 5x6 bitmaps: row r in bits r*5..r*5+4, leftmost column = highest bit of the row.
static const uint GLYPHS[16] = {
    272697013u, 404801073u, 272727103u, 32506304u, 941679672u, 276957247u, 32772191u, 15521390u,
    809583919u, 1058349188u, 29487228u, 156931044u, 474091908u, 272765924u, 69539905u, 404814862u
};

float luma(float3 c) { return dot(c, float3(0.299, 0.587, 0.114)); }
float hash(float n) { return frac(sin(n * 12.9898) * 43758.5453); }
float hash2(float2 p) { return frac(sin(dot(p, float2(12.9898, 78.233))) * 43758.5453); }

uint bitAt(uint bits, int x, int y)
{
    if (x < 0 || x > 4 || y < 0 || y > 5) return 0u;
    return (bits >> (y * 5 + (4 - x))) & 1u;
}

// Falling columns of glyphs; sp = screen pixel. Returns green light to add.
float3 rain(float2 sp)
{
    float2 cell = float2(6.0, 8.0) * RAIN_BIT;           // 5x6 glyph + 1-2 dot gap
    float  colI = floor(sp.x / cell.x);
    float  rowI = floor(sp.y / cell.y);

    // Several drops per column so columns are rarely empty; keep the nearest one behind its head.
    float  dist = -1.0, trail = 1.0;
    [unroll] for (int k = 0; k < RAIN_DROPS; k++) {
        float  seed  = colI + k * 101.0;
        float  spd   = (60.0 + hash(seed) * 140.0) * RAIN_SPEED;
        float  trl   = 150.0 + hash(seed + 3.3) * 350.0;
        float  span  = Resolution.y + trl;
        float  head  = fmod(Time * spd + hash(seed + 7.7) * span, span);
        float  dd    = head - (rowI + 0.5) * cell.y;      // distance behind this drop's head
        if (dd >= 0.0 && dd <= trl && (dist < 0.0 || dd / trl < dist / trail)) { dist = dd; trail = trl; }
    }
    if (dist < 0.0) return 0;

    // Each cell's glyph flips at its own random moments.
    float  flip = floor(Time * (2.0 + hash(colI + rowI * 31.0) * 6.0));
    uint   bits = GLYPHS[(uint)(hash2(float2(colI, rowI) + flip * 0.137) * 16.0) & 15u];
    int    bx = (int)floor(fmod(sp.x, cell.x) / RAIN_BIT);
    int    by = (int)floor(fmod(sp.y, cell.y) / RAIN_BIT);
    if (!bitAt(bits, bx, by)) return 0;

    float  fade = 1.0 - dist / trail;
    float3 tint = dist < cell.y ? float3(0.75, 1.0, 0.8) : float3(0.0, 1.0, 0.3);  // white-green head
    return tint * fade;
}

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET
{
    float2 px = 1.0 / Resolution;

    // Curved tube: bulge the image, black outside the glass.
    float2 cc = tex - 0.5;
    float2 uv = 0.5 + cc * (1.0 + CURVE * dot(cc, cc) * 4.0);
    if (any(uv < 0.0) || any(uv > 1.0)) return float4(0, 0, 0, 1);

    // Chunky pixels: snap to a coarse grid.
    float2 sp = uv * Resolution;
    uv = (floor(sp / PIXEL_SIZE) * PIXEL_SIZE + PIXEL_SIZE * 0.5) * px;

    float4 color = shaderTexture.SampleLevel(samplerState, uv, 0);

    static const float2 dirs[8] = {
        float2( 1, 0), float2(-1, 0), float2(0,  1), float2(0, -1),
        float2( 0.707, 0.707), float2(-0.707, 0.707),
        float2( 0.707,-0.707), float2(-0.707,-0.707)
    };

    // 8 samples (one ring) instead of 32: the GPU cost is dominated by these reads.
    float3 glow = 0;
    [unroll] for (int i = 0; i < 8; i++)
        glow += shaderTexture.SampleLevel(samplerState, uv + dirs[i] * px * GLOW_RADIUS * 1.5, 0).rgb;
    glow /= 8.0;

    // Only light up pixels darker than their neighbours, so glyphs stay sharp.
    float dark = saturate(1.0 - luma(color.rgb) * 1.5);
    float3 c = color.rgb + glow * (GLOW_STRENGTH + CONTOUR) * dark;

    // Digital rain only in empty background (on the chunky pixel grid), so text stays readable.
    if (luma(c) < 0.05) c += rain(uv * Resolution) * RAIN;

    // RGB phosphor stripes
    int col = (int)fmod(sp.x, 3.0);
    float3 mask = col == 0 ? float3(1, 1 - MASK, 1 - MASK) : col == 1 ? float3(1 - MASK, 1, 1 - MASK) : float3(1 - MASK, 1 - MASK, 1);
    c *= mask * (1.0 + MASK * 0.6);

    // Scanlines follow the chunky pixel rows
    c *= fmod(sp.y, PIXEL_SIZE * 1.5) < 1.0 ? 1.0 - SCANLINE_DARK : 1.0;

    // Grain
    c += (hash2(floor(sp) + frac(Time) * 97.0) - 0.5) * GRAIN;

    // Vignette
    c *= 1.0 - VIGNETTE * dot(cc, cc) * 2.0;

    return float4(saturate(c), color.a);
}
