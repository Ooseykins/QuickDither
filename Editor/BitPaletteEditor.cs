using UnityEditor;
using UnityEngine;

namespace QuickDither {
    [CustomEditor(typeof(BitPalette))]
    public class BitPaletteEditor : Editor {
        public override void OnInspectorGUI() {
            base.OnInspectorGUI();
            if (GUILayout.Button("Set Palette")) {
                ((BitPalette)target).SetPalette();
                EditorUtility.SetDirty(((BitPalette)target));
            }
        }
    }
}
