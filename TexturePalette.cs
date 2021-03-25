using System.Collections.Generic;
using UnityEngine;

namespace QuickDither {

    [RequireComponent(typeof(PaletteTextureGenerator))]
    public class TexturePalette : MonoBehaviour {
        public Texture2D texture;
        public void SetPalette() {
            if (!texture || !texture.isReadable) {
                return;
            }

            PaletteTextureGenerator gen = GetComponent<PaletteTextureGenerator>();
            HashSet<Color> palette = new HashSet<Color>();
            for (int y = 0; y < texture.height; y++) {
                for (int x = 0; x < texture.width; x++) {
                    palette.Add(texture.GetPixel(x, y));
                }
            }
            gen.palette = new Color[palette.Count];
            int i = 0;
            foreach (Color c in palette) {
                gen.palette[i] = c;
                i++;
            }
        }
    }
}
