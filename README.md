# QuickDither
Customizable limited palette dithering library for Unity

![C64](https://raw.githubusercontent.com/Ooseykins/QuickDither/main/Examples/example_C64.png)


## Usage
This library was tested using the standard renderer and gamma colour. Use the post processing v2 dithered effect with the pattern, primary, and secondary textures set. 4 Bayer patterns are included. Alternatively, use the dithered material on a "Raw Image" component with a render texture.

### Creating 3D dither textures
Add the PaletteTextureGenerator component to an empty gameobject. Pressing "Generate & Save Palette" will save the current palette to a 3D texture asset in "Assets/Dithered Palettes", with the name of the attached gameobject.
- **Size:**
Determines the size of the output texture. The size in pixels will be 8x this value, with a size 8 texture being 64x64x64 pixels and about 2MB in size.
- **Dither Depth:**
Determines the number of steps in the gradient during the generation process. A 4x4 Bayer pattern has 17 steps. Values higher than this are generally difficult to notice. Set to 1 if you want to limit the palette with no dithering at all.
- **Difference Factor:**
This prevents very different colours from blending during generation. Low values will increase visual noise, high values will increase colour banding.
- **Gamma:**
A gamma of 2.2 should work fine for almost every palette.
- **Palette:**
Edit the palette array manually, or use one of the palette generators "BitPalette" or "TexturePalette". Alpha is ignored.
