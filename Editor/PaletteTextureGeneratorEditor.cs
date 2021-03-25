using UnityEditor;
using UnityEngine;


namespace QuickDither {
    [CustomEditor(typeof(PaletteTextureGenerator))]
    public class PaletteTextureGeneratorEditor : Editor {
        const int COMPLEXITY_WARNING_THRESHOLD = 262144;
        const string ASSET_PATH = "Assets";
        const string DITHERED_PATH = "Dithered Palettes";
        public int warningOverride = 5;
        public override void OnInspectorGUI() {
            base.OnInspectorGUI();
            PaletteTextureGenerator gen = (PaletteTextureGenerator)target;
            int expectedSize = gen.ExpectedPaletteComplexity();
            if (expectedSize >= COMPLEXITY_WARNING_THRESHOLD) {
                EditorGUILayout.HelpBox("These settings will generate a very complex dithered palette (" + expectedSize + " entries) and may crash Unity and your GPU. Consider lowering the dither depth or using a smaller palette", MessageType.Warning);
                if (warningOverride > 0 && GUILayout.Button("Override warning " + warningOverride)) {
                    warningOverride--;
                }
            }
            else {
                warningOverride = 5;
            }
            if ((warningOverride <= 0 || expectedSize < COMPLEXITY_WARNING_THRESHOLD) && GUILayout.Button("Generate & Save Palette")) {
                Texture3D[] textures = gen.Generate();

                if (!AssetDatabase.IsValidFolder(ASSET_PATH + "/" + DITHERED_PATH)) {
                    AssetDatabase.CreateFolder(ASSET_PATH, DITHERED_PATH);
                }
                AssetDatabase.CreateAsset(textures[0], ASSET_PATH + "/" + DITHERED_PATH + "/" + gen.name + "_primary.asset");
                AssetDatabase.CreateAsset(textures[1], ASSET_PATH + "/" + DITHERED_PATH + "/" + gen.name + "_secondary.asset");
                Debug.Log("Saved palettes to " + ASSET_PATH + "/" + DITHERED_PATH + "/" + gen.name);
            }
        }
    }
}
