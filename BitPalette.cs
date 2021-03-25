using UnityEngine;

namespace QuickDither {
    [RequireComponent(typeof(PaletteTextureGenerator))]
    public class BitPalette : MonoBehaviour {
        [Range(0, 3)]
        public int redDepth = 1;
        [Range(0, 3)]
        public int greenDepth = 1;
        [Range(0, 3)]
        public int blueDepth = 1;
        public void SetPalette() {
            PaletteTextureGenerator gen = GetComponent<PaletteTextureGenerator>();
            int rDepth = (int)Mathf.Pow(2, redDepth);
            int gDepth = (int)Mathf.Pow(2, greenDepth);
            int bDepth = (int)Mathf.Pow(2, blueDepth);
            Color[] cols = new Color[rDepth * gDepth * bDepth];
            int index = 0;
            for (int r = 0; r < rDepth; r++) {
                for (int g = 0; g < gDepth; g++) {
                    for (int b = 0; b < bDepth; b++) {
                        float red = 0f;
                        if (rDepth > 1) {
                            red = r / (rDepth - 1f);
                        }
                        float green = 0f;
                        if (gDepth > 1) {
                            green = g / (gDepth - 1f);
                        }
                        float blue = 0f;
                        if (bDepth > 1) {
                            blue = b / (bDepth - 1f);
                        }
                        cols[index] = new Color(red, green, blue, 1f);
                        index++;
                    }
                }
            }
            gen.palette = cols;
        }
    }
}