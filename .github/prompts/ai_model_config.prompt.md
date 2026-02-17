---
name: ai_model_config
description: Describe when to use this prompt
---

TASK: 1

Check current implementation so far and check the instructions and prompts file `parent-prompt.prompt.md` to see if the implementation is following the instructions and requirements. If not, identify the gaps and suggest improvements to align with the requirements. 

TASK: 2 

First phase: 
- Load local model from asset and manage input and output predicted results. 
- For now image input is generic for every model. define input type and image processing pipeline should be defined after choosing the diagnostic model.

Let me provide the python code for input: 

##CHEST CT SCAN CLASSIFICATION MODEL
['adenocarcinoma', 'large.cell.carcinoma', 'normal', 'squamous.cell.carcinoma']

```python:



#     x.append(features)
#     y.append(label)
for label, cls in enumerate(category):
    class_path = os.path.join(Directory, cls)
    for img in os.listdir(class_path):
        img_path = os.path.join(class_path, img)
        imarr = cv2.imread(img_path)
        if imarr is None:
            continue
        imarr = cv2.resize(imarr, (224,224))
        imarr = sharpen_image(imarr)
        data.append([imarr, label])

x = [img for img, label in data]
y = [label for _, label in data]

import tensorflow as tf

def augment(image):
    image = tf.image.random_flip_left_right(image)
    image = tf.image.random_flip_up_down(image)
    image = tf.image.random_brightness(image, 0.2)
    image = tf.image.random_contrast(image, 0.8, 1.2)
    image = tf.image.random_saturation(image, 0.8, 1.2)
    image = tf.image.random_hue(image, 0.05)
    # Random rotation
    image = tf.image.rot90(image, k=tf.random.uniform(shape=[], minval=0, maxval=4, dtype=tf.int32))
    return image

# Convert X_train, y_train to tf.data.Dataset
batch_size = 32
AUTOTUNE = tf.data.AUTOTUNE

train_data = tf.data.Dataset.from_tensor_slices((X_train, y_train))

def preprocess(image, label):
    image = augment(image)
    return image, label

train_data = train_data.map(preprocess, num_parallel_calls=AUTOTUNE)
train_data = train_data.shuffle(1000).batch(batch_size).prefetch(AUTOTUNE)

# Now train_ds is fully augmented and GPU-accelerated
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import (Conv2D, MaxPooling2D, Flatten, Dense, Dropout,
                                     BatchNormalization, Activation)
from tensorflow.keras import regularizers
from tensorflow.keras.optimizers import Adam

def create_cnn(input_shape=(224,224,3), num_classes=4):
    model = Sequential()

    # 1st Conv Layer
    model.add(Conv2D(32, 3, activation='relu'))
    model.add(MaxPooling2D())

    # 2nd Conv Layer
    model.add(Conv2D(64, 3, activation='relu'))
    model.add(MaxPooling2D())

    # 3rd Conv Layer
    model.add(Conv2D(128, 3, activation='relu'))
    model.add(MaxPooling2D())

    # # 4th Conv Layer
    # model.add(Conv2D(24, kernel_size=(3,3), strides=(1,1), activation='relu'))
    # model.add(BatchNormalization())
    # model.add(MaxPooling2D(pool_size=2, strides=2))
    # model.add(Dropout(0.3))

    # # 5th Conv Layer
    # model.add(Conv2D(64, kernel_size=(3,3), strides=(1,1), activation='relu'))
    # model.add(MaxPooling2D(pool_size=2, strides=2))
    # model.add(Dropout(0.3))

    # Flatten and Dense layers
    model.add(Flatten())
    model.add(Dense(256, activation='relu', kernel_regularizer=regularizers.l1(1e-4)))
    model.add(Dropout(0.5))

    # Output layer
    model.add(Dense(num_classes, activation='softmax'))

    # Compile model
    model.compile(optimizer=Adam(learning_rate=1e-4),
                  loss='sparse_categorical_crossentropy',
                  metrics=['accuracy'])

    return model


TEST: 

import tensorflow as tf
from tensorflow.keras.preprocessing import image
import numpy as np

IMG_SIZE = 224
model_path = "/content/Chest_CT_Scan_cnn_model37.h5"
test_image_path = "/content/combined_dataset/squamous.cell.carcinoma/test_000127 (6).png"

model = tf.keras.models.load_model(model_path)

img = image.load_img(test_image_path, target_size=(IMG_SIZE, IMG_SIZE))
img_array = image.img_to_array(img)
img_array = np.expand_dims(img_array, axis=0)

pred_probs = model.predict(img_array)
pred_class_index = np.argmax(pred_probs)

class_labels = ["adenocarcinoma", "large.cell.carcinoma", "normal", "squamous.cell.carcinoma"]

pred_class_label = class_labels[pred_class_index]

print(f"Predicted class: {pred_class_label}")
print(f"Class probabilities: {pred_probs[0]}")

1/1 ━━━━━━━━━━━━━━━━━━━━ 1s 1s/step
Predicted class: squamous.cell.carcinoma
Class probabilities: [7.9911076e-02 7.4108008e-05 8.8189267e-07 9.2001396e-01]
```