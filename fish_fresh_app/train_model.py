"""
FishCheck ZM — Fish Freshness TFLite Model Trainer
====================================================
Dataset: Freshness Fish Dataset (Kaggle)
- C1 = Fresh        (1-2 days after capture)
- C2 = Acceptable   (3-4 days after capture)
- C3 = Spoiled      (5-6 days after capture)

SETUP (run once in terminal):
  pip install tensorflow pillow numpy scikit-learn matplotlib

HOW TO RUN:
1. Extract your downloaded zip so you have a folder like:
      FreshnessFishDataset/
        C1/   ← fresh fish images
        C2/   ← moderate fish images
        C3/   ← spoiled fish images

2. Update DATASET_PATH below to point to that folder

3. Run:
      python train_model.py

4. When done, copy fish_freshness.tflite to:
      fish_fresh_app/assets/ml/fish_freshness.tflite
"""

import os, sys, shutil
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from pathlib import Path

# ── Configuration ─────────────────────────────────────────────────────────────

# ⚠️  UPDATE THIS to the folder where you extracted the dataset zip
DATASET_PATH  = 'C:/Users/imaka/Downloads/archive/Freshness Fish Dataset'

OUTPUT_MODEL  = './fish_freshness.tflite'
OUTPUT_LABELS = './fish_freshness_labels.txt'
IMG_SIZE      = (224, 224)
BATCH_SIZE    = 32
EPOCHS        = 25
LEARNING_RATE = 0.001

# Maps dataset folder names → our FreshnessLevel enum index in Flutter
# Keep this order — it must match how Flutter reads the model output
CLASS_MAP = {
    'C1': ('fresh',      0),   # FreshnessLevel.fresh
    'C2': ('acceptable', 1),   # FreshnessLevel.acceptable
    'C3': ('spoiled',    2),   # FreshnessLevel.spoiled
}

# ── Check dependencies ─────────────────────────────────────────────────────────

def check_deps():
    missing = []
    try:
        import tensorflow as tf
        print(f"  ✓ TensorFlow {tf.__version__}")
    except ImportError:
        missing.append('tensorflow')

    try:
        from PIL import Image
        print(f"  ✓ Pillow ready")
    except ImportError:
        missing.append('pillow')

    try:
        import sklearn
        print(f"  ✓ scikit-learn ready")
    except ImportError:
        missing.append('scikit-learn')

    if missing:
        print(f"\n✗ Missing packages. Run:")
        print(f"  pip install {' '.join(missing)}")
        sys.exit(1)

# ── Load dataset ───────────────────────────────────────────────────────────────

def load_dataset(dataset_path):
    import tensorflow as tf
    from PIL import Image

    dataset_dir = Path(dataset_path)
    if not dataset_dir.exists():
        print(f"\n✗ Dataset folder not found: {dataset_path}")
        print(f"  Please extract your zip and update DATASET_PATH in train_model.py")
        print(f"  Expected structure:")
        print(f"    {dataset_path}/")
        print(f"      C1/  (fresh fish images)")
        print(f"      C2/  (moderate fish images)")
        print(f"      C3/  (spoiled fish images)")
        sys.exit(1)

    images, labels = [], []
    class_counts = {}

    for folder_name, (label_name, label_idx) in CLASS_MAP.items():
        class_dir = dataset_dir / folder_name
        if not class_dir.exists():
            print(f"  ⚠ Folder not found: {class_dir} — skipping")
            continue

        img_files = (list(class_dir.glob('*.jpg')) +
                     list(class_dir.glob('*.jpeg')) +
                     list(class_dir.glob('*.png')) +
                     list(class_dir.glob('*.JPG')) +
                     list(class_dir.glob('*.JPEG')))

        print(f"  Loading {len(img_files):4d} images from {folder_name}/ ({label_name})")
        class_counts[label_name] = 0

        for img_path in img_files:
            try:
                img = Image.open(img_path).convert('RGB')
                img = img.resize(IMG_SIZE, Image.LANCZOS)
                arr = np.array(img, dtype=np.float32) / 255.0
                images.append(arr)
                labels.append(label_idx)
                class_counts[label_name] += 1
            except Exception as e:
                pass  # Skip corrupted images silently

    if len(images) == 0:
        print("\n✗ No images loaded. Check your dataset folder path.")
        sys.exit(1)

    print(f"\n  Total: {len(images)} images")
    print(f"  Distribution: {class_counts}")

    return np.array(images, dtype=np.float32), np.array(labels, dtype=np.int32)

# ── Build model ────────────────────────────────────────────────────────────────

def build_model(num_classes):
    import tensorflow as tf
    from tensorflow import keras
    from tensorflow.keras import layers

    print(f"\n  Building MobileNetV3Small ({IMG_SIZE[0]}x{IMG_SIZE[1]} input, {num_classes} classes)")

    base = keras.applications.MobileNetV3Small(
        input_shape=(*IMG_SIZE, 3),
        include_top=False,
        weights='imagenet',
        include_preprocessing=True,
    )
    base.trainable = False  # Freeze in phase 1

    inputs  = keras.Input(shape=(*IMG_SIZE, 3))
    x       = base(inputs, training=False)
    x       = layers.GlobalAveragePooling2D()(x)
    x       = layers.BatchNormalization()(x)
    x       = layers.Dense(256, activation='relu')(x)
    x       = layers.Dropout(0.4)(x)
    x       = layers.Dense(128, activation='relu')(x)
    x       = layers.Dropout(0.2)(x)
    outputs = layers.Dense(num_classes, activation='softmax')(x)

    model = keras.Model(inputs, outputs)
    model.compile(
        optimizer=keras.optimizers.Adam(LEARNING_RATE),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy'],
    )
    return model, base

# ── Data augmentation ──────────────────────────────────────────────────────────

def augment_dataset(X, y):
    """Apply simple augmentation to increase dataset diversity."""
    import tensorflow as tf

    print("  Applying data augmentation...")
    aug_images, aug_labels = list(X), list(y)

    for i in range(len(X)):
        img = X[i]
        label = y[i]

        # Horizontal flip
        aug_images.append(np.fliplr(img))
        aug_labels.append(label)

        # Slight brightness variation
        bright = np.clip(img * np.random.uniform(0.8, 1.2), 0, 1)
        aug_images.append(bright.astype(np.float32))
        aug_labels.append(label)

    result_X = np.array(aug_images, dtype=np.float32)
    result_y = np.array(aug_labels, dtype=np.int32)
    print(f"  After augmentation: {len(result_X)} images")
    return result_X, result_y

# ── Train ──────────────────────────────────────────────────────────────────────

def train(model, base, X_train, X_val, y_train, y_val):
    from tensorflow import keras

    callbacks = [
        keras.callbacks.EarlyStopping(
            patience=5, restore_best_weights=True, verbose=1),
        keras.callbacks.ReduceLROnPlateau(
            factor=0.5, patience=3, verbose=1),
        keras.callbacks.ModelCheckpoint(
            'best_model.keras', save_best_only=True, verbose=0),
    ]

    # Phase 1 — train top layers only
    print("\n── Phase 1: Training classification head ────────────────────────")
    h1 = model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=EPOCHS // 2,
        batch_size=BATCH_SIZE,
        callbacks=callbacks,
        verbose=1,
    )

    # Phase 2 — unfreeze last 30 layers and fine-tune
    print("\n── Phase 2: Fine-tuning base model ──────────────────────────────")
    base.trainable = True
    for layer in base.layers[:-30]:
        layer.trainable = False

    model.compile(
        optimizer=keras.optimizers.Adam(LEARNING_RATE / 10),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy'],
    )

    h2 = model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=EPOCHS,
        batch_size=BATCH_SIZE,
        callbacks=callbacks,
        verbose=1,
    )

    # Load the best weights saved during training
    if Path('best_model.keras').exists():
        model.load_weights('best_model.keras')

    return h1, h2

# ── Export to TFLite ───────────────────────────────────────────────────────────

def export_tflite(model, X_sample):
    import tensorflow as tf

    print(f"\n── Exporting to TFLite ──────────────────────────────────────────")

    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.target_spec.supported_types = [tf.float16]

    # Representative dataset for quantisation calibration
    def rep_data():
        for i in range(min(200, len(X_sample))):
            yield [X_sample[i:i+1]]

    converter.representative_dataset = rep_data

    tflite_bytes = converter.convert()

    with open(OUTPUT_MODEL, 'wb') as f:
        f.write(tflite_bytes)

    size_kb = len(tflite_bytes) / 1024
    print(f"  ✓ Model saved: {OUTPUT_MODEL} ({size_kb:.0f} KB)")

    # Save labels file
    labels = [name for name, _ in sorted(CLASS_MAP.values(), key=lambda x: x[1])]
    with open(OUTPUT_LABELS, 'w') as f:
        f.write('\n'.join(labels))
    print(f"  ✓ Labels saved: {OUTPUT_LABELS}")

    # Clean up temp files
    for f in ['best_model.keras']:
        if Path(f).exists():
            os.remove(f)

# ── Plot ───────────────────────────────────────────────────────────────────────

def plot(h1, h2):
    acc  = h1.history['accuracy']      + h2.history['accuracy']
    vacc = h1.history['val_accuracy']  + h2.history['val_accuracy']
    loss = h1.history['loss']          + h2.history['loss']
    vloss= h1.history['val_loss']      + h2.history['val_loss']

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(13, 4))
    fig.suptitle('FishCheck ZM — Training Results', fontsize=14)

    ax1.plot(acc,  label='Train', color='#0A7B5C')
    ax1.plot(vacc, label='Val',   color='#0A7B5C', linestyle='--')
    ax1.axvline(len(h1.history['accuracy'])-1, color='grey',
                linestyle=':', label='Fine-tune start')
    ax1.set_title('Accuracy'); ax1.set_xlabel('Epoch')
    ax1.set_ylabel('Accuracy'); ax1.legend(); ax1.grid(alpha=0.3)

    ax2.plot(loss,  label='Train', color='#E53935')
    ax2.plot(vloss, label='Val',   color='#E53935', linestyle='--')
    ax2.axvline(len(h1.history['loss'])-1, color='grey',
                linestyle=':', label='Fine-tune start')
    ax2.set_title('Loss'); ax2.set_xlabel('Epoch')
    ax2.set_ylabel('Loss'); ax2.legend(); ax2.grid(alpha=0.3)

    plt.tight_layout()
    plt.savefig('training_results.png', dpi=120)
    print(f"  ✓ Chart saved: training_results.png")

# ── Main ───────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    print("=" * 55)
    print("  FishCheck ZM — Fish Freshness Model Trainer")
    print("=" * 55)

    print("\n── Checking dependencies ────────────────────────────────────────")
    check_deps()

    from sklearn.model_selection import train_test_split

    print("\n── Loading dataset ──────────────────────────────────────────────")
    X, y = load_dataset(DATASET_PATH)

    print("\n── Augmenting data ──────────────────────────────────────────────")
    X, y = augment_dataset(X, y)

    # Shuffle
    idx = np.random.permutation(len(X))
    X, y = X[idx], y[idx]

    # Split 80/20
    X_train, X_val, y_train, y_val = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y)
    print(f"  Train: {len(X_train)} | Val: {len(X_val)}")

    num_classes = len(CLASS_MAP)

    print("\n── Building model ───────────────────────────────────────────────")
    model, base = build_model(num_classes)

    print("\n── Training ─────────────────────────────────────────────────────")
    h1, h2 = train(model, base, X_train, X_val, y_train, y_val)

    print("\n── Evaluating ───────────────────────────────────────────────────")
    loss, acc = model.evaluate(X_val, y_val, verbose=0)
    print(f"  Validation accuracy: {acc * 100:.1f}%")
    print(f"  Validation loss:     {loss:.4f}")

    export_tflite(model, X_val)

    try:
        plot(h1, h2)
    except Exception as e:
        print(f"  (Chart skipped: {e})")

    print("\n" + "=" * 55)
    print("  ✓ Training complete!")
    print("=" * 55)
    print(f"\nNext steps:")
    print(f"  1. Copy  fish_freshness.tflite")
    print(f"     →  fish_fresh_app/assets/ml/fish_freshness.tflite")
    print(f"  2. Copy  fish_freshness_labels.txt")
    print(f"     →  fish_fresh_app/assets/ml/fish_freshness_labels.txt")
    print(f"  3. Run:  flutter run -d chrome")
