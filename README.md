# QuickDither
Customizable limited palette dithering library for Unity

![C64](https://raw.githubusercontent.com/Ooseykins/QuickDither/main/Examples/example_C64.png)

[Video example with included Mode13h palette](https://www.youtube.com/watch?v=rj8jCh_k3ns)

[Video example with other palettes on Reddit](https://www.reddit.com/r/Unity3D/comments/mak26f/retro_pc_graphics_post_processing_i_made/)

I always love to see people putting this to use! Please share projects using this effect with me on twitter [@Ooseykins](https://twitter.com/ooseykins)! If you need help, post an issue here on github or message me on twitter or discord Oose#2504!

## Usage for standard renderer
This library was tested using the standard renderer and gamma colour. Use the post processing v2 dithered effect with the pattern, primary, and secondary textures set. You can import post processing v2 from the Unity package manager. 4 Bayer patterns are included. Alternatively, use the dithered material on a "Raw Image" component with a render texture.

## Usage for universal render pipeline (URP)
The functionality using URP requires outputting to a render texture of the desired resolution, then rendering it to a seperate camera-space UI image using the dithered shader/material. The shader graph source is included as well as an example scene with a working camera setup.

#### Things to modify when starting from scratch
- **Main Camera:** output texture
- **Output Camera:** culling mask (to UI only)
- **Canvas:** render mode, render camera (to output camera)
- **Canvas Scaler:** UI scale mode, reference resolution, screen match mode (expand)

#### URP Specific tips
- Modify the palette in use on the dithered material
- The dithered material can be used with any texture, it doesn't have to be a render texture
- Quickly remap dark/light areas of the image using the remap property on the dithered material
- When adding the render texture image to the canvas the "Set Native Size" button helps to keep everything pixel perfect

## Creating 3D dither textures
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
