using System.Collections.Generic;
using UnityEngine;

namespace QuickDither {

    public class PaletteTextureGenerator : MonoBehaviour {

        const int COMPUTE_THREAD_COUNT = 8;
        [Tooltip("Size of the 3D texture; 1 = 8x8x8, 8 = 64x64x64")]
        [Range(1, 8)]
        public int size = 8;
        [Tooltip("How many levels of dithering to use. Bayer4x4 has 17 levels")]
        [Range(1, 33)]
        public int ditherDepth = 17;
        [Tooltip("Factor for preventing high contrast noise")]
        [Range(0, 0.3f)]
        public float differenceFactor = 0.05f;
        [Tooltip("Gamma correction. Default 2.2 works for most")]
        [Range(0.1f, 10f)]

        public float gamma = 2.2f;
        public Color[] palette;

        public ComputeShader paletteShader;
        public ComputeShader slicerShader;

        private struct DitheredColor {
            public Color primary;
            public Color secondary;
            public float ratio;
            public DitheredColor(Color primary, Color secondary, float ratio) {
                this.ratio = Mathf.Clamp01(ratio);
                this.primary = new Color(primary.r, primary.g, primary.b, ratio);
                this.secondary = new Color(secondary.r, secondary.g, secondary.b, ratio);
            }
        }
        public Texture3D[] Generate() {
            Texture3D[] output = new Texture3D[2];
            RenderTexture[] rtArr = GenerateRT(palette, size, ditherDepth, differenceFactor, gamma, paletteShader);
            output[0] = RenderTextureToTexture3D(rtArr[0]);
            output[1] = RenderTextureToTexture3D(rtArr[1]);
            return output;
        }
        public static RenderTexture[] GenerateRT(Color[] palette, int size, int ditherDepth, float differenceFactor, float gamma, ComputeShader paletteShader) {
            RenderTexture[] renderTextures = new RenderTexture[2];
            for (int i = 0; i < 2; i++) {
                renderTextures[i] = new RenderTexture(size * COMPUTE_THREAD_COUNT, size * COMPUTE_THREAD_COUNT, 0, RenderTextureFormat.ARGB32);
                renderTextures[i].name = "PaletteTexture" + i;
                renderTextures[i].enableRandomWrite = true;
                renderTextures[i].filterMode = FilterMode.Point;
                renderTextures[i].dimension = UnityEngine.Rendering.TextureDimension.Tex3D;
                renderTextures[i].volumeDepth = size * COMPUTE_THREAD_COUNT;
                renderTextures[i].Create();
            }

            if (!SystemInfo.supportsComputeShaders) {
                Debug.LogWarning("Compute shaders are not supported by this system, dithered palette failed to generate");
                return renderTextures;
            }
            if (!paletteShader) {
                Debug.LogWarning("Palette compute shader is required to generate a dithered palette");
                return renderTextures;
            }
            if (palette.Length == 0) {
                Debug.LogWarning("A dithered palette was generated with no input palette");
                return renderTextures;
            }

            DitheredColor[] colors = GetDitheredColors(palette, ditherDepth);
            ComputeBuffer buffer = new ComputeBuffer(colors.Length, sizeof(float) * 9);
            buffer.SetData(colors);
            paletteShader.SetBuffer(0, "palette", buffer);
            paletteShader.SetInt("paletteLength", colors.Length);
            paletteShader.SetFloat("size", size * COMPUTE_THREAD_COUNT);
            paletteShader.SetFloat("differenceFactor", differenceFactor);
            paletteShader.SetFloat("gamma", gamma);
            paletteShader.SetTexture(0, "PrimaryResult", renderTextures[0]);
            paletteShader.SetTexture(0, "SecondaryResult", renderTextures[1]);
            paletteShader.Dispatch(0, size, size, size);
            buffer.Dispose();
            return renderTextures;
        }
        private static DitheredColor[] GetDitheredColors(Color[] colors, int depth = 17) {
            List<DitheredColor> ditheredColors = new List<DitheredColor>();
            for (int i = 0; i < colors.Length; i++) {
                ditheredColors.Add(new DitheredColor(colors[i], colors[i], 1f));
            }
            if (depth == 1) {
                return ditheredColors.ToArray();
            }
            float step = 1f / (depth);
            for (int i = 0; i < colors.Length; i++) {
                for (int j = i + 1; j < colors.Length; j++) {
                    for (int k = 0; k < depth - 1; k++) {
                        ditheredColors.Add(new DitheredColor(colors[i], colors[j], (k + 1) * step));
                    }
                }
            }
            return ditheredColors.ToArray();
        }
        public int ExpectedPaletteComplexity() {
            if( palette.Length == 0)
                return 0;
            return palette.Length + palette.Length * (palette.Length - 1) / 2 * (ditherDepth - 1);
        }

        // This next bit of code and slicer shader credit to Nesvi on answers.unity.com
        // https://answers.unity.com/questions/840983/how-do-i-copy-a-3d-rendertexture-isvolume-true-to.html?childToView=1243556#answer-1243556
        // Slightly modified to return the texture3D and set texture filtermodes and wrapmodes
        RenderTexture Copy3DSliceToRenderTexture(RenderTexture source, int layer) {
            RenderTexture render = new RenderTexture(size * COMPUTE_THREAD_COUNT, size * COMPUTE_THREAD_COUNT, 0, RenderTextureFormat.ARGB32);
            render.dimension = UnityEngine.Rendering.TextureDimension.Tex2D;
            render.enableRandomWrite = true;
            render.filterMode = FilterMode.Point;
            render.wrapMode = TextureWrapMode.Clamp;
            render.Create();

            int kernelIndex = slicerShader.FindKernel("CSMain");
            slicerShader.SetTexture(kernelIndex, "voxels", source);
            slicerShader.SetInt("layer", layer);
            slicerShader.SetTexture(kernelIndex, "Result", render);
            slicerShader.Dispatch(kernelIndex, size, size, 1);

            return render;
        }
        Texture2D ConvertFromRenderTexture(RenderTexture rt) {
            Texture2D output = new Texture2D(size * COMPUTE_THREAD_COUNT, size * COMPUTE_THREAD_COUNT);
            output.filterMode = FilterMode.Point;
            output.wrapMode = TextureWrapMode.Clamp;
            RenderTexture.active = rt;
            output.ReadPixels(new Rect(0, 0, size * COMPUTE_THREAD_COUNT, size * COMPUTE_THREAD_COUNT), 0, 0);
            output.Apply();
            return output;
        }
        Texture3D RenderTextureToTexture3D(RenderTexture rt) {
            RenderTexture[] rtLayers = new RenderTexture[size * COMPUTE_THREAD_COUNT];
            for (int i = 0; i < rtLayers.Length; i++) {
                rtLayers[i] = Copy3DSliceToRenderTexture(rt, i);
            }

            Texture2D[] texLayers = new Texture2D[size * COMPUTE_THREAD_COUNT];
            for (int i = 0; i < texLayers.Length; i++) {
                texLayers[i] = ConvertFromRenderTexture(rtLayers[i]);
            }

            Texture3D output = new Texture3D(size * COMPUTE_THREAD_COUNT, size * COMPUTE_THREAD_COUNT, size * COMPUTE_THREAD_COUNT, TextureFormat.RGBA32, false);
            output.filterMode = FilterMode.Point;
            output.wrapMode = TextureWrapMode.Clamp;
            Color[] outputPixels = output.GetPixels();
            for (int k = 0; k < size * COMPUTE_THREAD_COUNT; k++) {
                Color[] layerPixels = texLayers[k].GetPixels();
                for (int i = 0; i < size * COMPUTE_THREAD_COUNT; i++) {
                    for (int j = 0; j < size * COMPUTE_THREAD_COUNT; j++) {
                        outputPixels[i + j * size * COMPUTE_THREAD_COUNT + k * size * COMPUTE_THREAD_COUNT * size * COMPUTE_THREAD_COUNT] = layerPixels[i + j * size * COMPUTE_THREAD_COUNT];
                    }
                }
            }
            output.SetPixels(outputPixels);
            output.Apply();
            return output;
        }
        // Thanks, Nesvi!
    }
}
