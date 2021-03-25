using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;


namespace QuickDither {

    [Serializable]
    [PostProcess(typeof(DitheredRenderer), PostProcessEvent.AfterStack, "Post-processing/Dithered/Dithered")]
    public sealed class Dithered : PostProcessEffectSettings {

        [Range(0, 1)]
        public FloatParameter intensity = new FloatParameter { value = 1 };
        [Tooltip("Scale of pixels on screen")]
        [Range(1, 8)]
        public IntParameter pixelScale = new IntParameter { value = 1 };
        [Tooltip("Dither pattern texture")]
        public TextureParameter pattern = new TextureParameter { value = null };
        [Tooltip("Primary 3D Texture used for lookup")]
        public TextureParameter primary = new TextureParameter { value = null };
        [Tooltip("Secondary 3D Texture used for lookup")]
        public TextureParameter secondary = new TextureParameter { value = null };
        [Tooltip("Intensity of noise overlay (reduces dither repetition")]
        [Range(0, 1)]
        public FloatParameter noiseIntensity = new FloatParameter { value = 0f };
    }

    public sealed class DitheredRenderer : PostProcessEffectRenderer<Dithered> {
        public override void Render(PostProcessRenderContext context) {
            var sheet = context.propertySheets.Get(Shader.Find("Dithered/DitheredPostProcess"));
            sheet.properties.SetFloat("_Intensity", settings.intensity.value);
            sheet.properties.SetFloat("_PixelScale", settings.pixelScale.value);
            if (settings.pattern.value != null) {
                sheet.properties.SetTexture("_Pattern", settings.pattern.value);
            }
            if (settings.primary.value != null) {
                sheet.properties.SetTexture("_Primary", settings.primary.value);
            }
            if (settings.secondary.value != null) {
                sheet.properties.SetTexture("_Secondary", settings.secondary.value);
            }
            sheet.properties.SetFloat("_NoiseIntensity", settings.noiseIntensity.value);
            context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
        }
    }
}