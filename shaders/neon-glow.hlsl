// Neon glow / contour for Windows Terminal.
// Text stays crisp; light bleeds only into the dark space around glyphs.

Texture2D shaderTexture;
SamplerState samplerState;

cbuffer PixelShaderSettings {
    float  Time;
    float  Scale;
    float2 Resolution;
    float4 Background;
};

#define GLOW_STRENGTH   0.9   // overall glow intensity
#define GLOW_RADIUS     2.5   // glow spread in pixels
#define CONTOUR         0.35  // tight 1px outline intensity

float luma(float3 c) { return dot(c, float3(0.299, 0.587, 0.114)); }

float4 main(float4 pos : SV_POSITION, float2 tex : TEXCOORD) : SV_TARGET
{
    float4 color = shaderTexture.Sample(samplerState, tex);
    float2 px = 1.0 / Resolution;

    static const float2 dirs[8] = {
        float2( 1, 0), float2(-1, 0), float2(0,  1), float2(0, -1),
        float2( 0.707, 0.707), float2(-0.707, 0.707),
        float2( 0.707,-0.707), float2(-0.707,-0.707)
    };

    float3 glow = 0;
    float3 contour = 0;
    [unroll] for (int i = 0; i < 8; i++) {
        float3 n1 = shaderTexture.Sample(samplerState, tex + dirs[i] * px).rgb;
        contour = max(contour, n1);
        [unroll] for (int r = 1; r <= 3; r++) {
            float3 s = shaderTexture.Sample(samplerState, tex + dirs[i] * px * GLOW_RADIUS * r).rgb;
            glow += s * (1.0 / r);
        }
    }
    glow /= 8.0 * 1.833;

    // Only light up pixels darker than their neighbours, so glyphs stay sharp.
    float dark = saturate(1.0 - luma(color.rgb) * 1.5);
    float3 halo = (glow * GLOW_STRENGTH + contour * CONTOUR) * dark;

    return float4(saturate(color.rgb + halo), color.a);
}
