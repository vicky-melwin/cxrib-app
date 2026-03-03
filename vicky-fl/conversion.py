# ============================================================
# 🚀 CerviScan FINAL Model Converter
# .keras → .h5 → .tflite (iOS SAFE)
# ============================================================

import tensorflow as tf
import os

# ------------------------------------------------------------
# 1️⃣ PATHS (EDIT ONLY IF NEEDED)
# ------------------------------------------------------------
KERAS_PATH = "/content/drive/MyDrive/CRIB/PDD/CERVISCAN_FINAL.keras"

OUTPUT_DIR = "/content/drive/MyDrive/CRIB/PDD"
TFLITE_PATH = os.path.join(OUTPUT_DIR, "CERVISCAN_model_FINAL (2).tflite")
H5_PATH     = os.path.join(OUTPUT_DIR, "CERVISCAN_FINAL.h5")

# ------------------------------------------------------------
# 2️⃣ LOAD KERAS MODEL
# ------------------------------------------------------------
print("📂 Loading model:", KERAS_PATH)
model = tf.keras.models.load_model(KERAS_PATH, compile=False)
print("✅ Keras model loaded")

model.summary()

# ------------------------------------------------------------
# 3️⃣ SAVE H5 (OPTIONAL BUT GOOD PRACTICE)
# ------------------------------------------------------------
model.save(H5_PATH, save_format="h5")
print("💾 Saved H5 model:", H5_PATH)

# ------------------------------------------------------------
# 4️⃣ CONVERT TO TFLITE (🔥 NO OPTIMIZATION)
# ------------------------------------------------------------
print("🔄 Converting to TFLite (iOS locked)...")

converter = tf.lite.TFLiteConverter.from_keras_model(model)

# ❌ DO NOT enable optimizations
converter.optimizations = []

# ✅ Keep float32 exactly
converter.target_spec.supported_types = [tf.float32]

# ✅ Stable converter
converter.experimental_new_converter = True

tflite_model = converter.convert()

# ------------------------------------------------------------
# 5️⃣ SAVE TFLITE
# ------------------------------------------------------------
with open(TFLITE_PATH, "wb") as f:
    f.write(tflite_model)

print("🎉 TFLite model saved:", TFLITE_PATH)
print("✅ READY FOR iOS (TensorFlowLiteSwift)")

