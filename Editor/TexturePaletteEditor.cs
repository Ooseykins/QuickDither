using UnityEditor;
using UnityEngine;

namespace QuickDither {

    [CustomEditor(typeof(TexturePalette))]
    public class TexturePaletteEditor : Editor {
        public override void OnInspectorGUI() {
            base.OnInspectorGUI();
            if (((TexturePalette)target).texture && !((TexturePalette)target).texture.isReadable) {
                EditorGUILayout.HelpBox("The input texture must be read-write enabled in import settings", MessageType.Warning);
            }
            if (GUILayout.Button("Set Palette")) {
                ((TexturePalette)target).SetPalette();
            }
        }
    }
}
