

---
title: Quantization
date: 2024-01-02 12:00:00
categories:[AI, Text Processing, Quantization]
tags: [ML, AI, GenAI]
author: "Amit Tiwari"
---

**Quantization** is a technique for reducing the model size by compressing the model weights from a **high-precision** value to a **low-precision** value. The weights of a language model are the vectors that can be represented in different data types based on the availability of computational resources and required precision. The default data type of most of the models is a 32-bit floating number (float32), which means each weight of such models takes 4 bytes of space in the memory.

**Quantization** reduces the number of bits required for each weight of the model by changing the data type from a 32-bit floating number (float32), which holds more information, to an 8-bit (int8) or a 4-bit integer (int4), which holds less.

Imagine you're packing for a trip. You've got a big suitcase, and you're stuffing it with clothes that take up a lot of space---like bulky sweaters and thick jeans. This is like a language model's weights stored as 32-bit floating numbers (float32): they're detailed and precise, but they take up a lot of room (4 bytes per weight). Now, suppose you realize you need to fit everything into a smaller bag. You start folding your clothes tighter, swapping out the sweaters for thinner shirts, and squeezing things down to essentials. You lose some of the fluffiness and detail, but you still have functional outfits. That's quantization---shrinking those weights down to something like 8-bit integers (int8, 1 byte) or even 4-bit integers (int4, half a byte), where they take up way less space but still get the job done.

For example, let's say a weight in a model is originally a float32 value like 3.14159 (a precise number stored in 4 bytes). After quantization to int8, it might get rounded to 3 (a less precise integer stored in just 1 byte). You lose some granularity---like going from a high-def photo to a slightly pixelated one---but the model can still understand and generate text, just with a smaller memory footprint. This is super useful for running models on devices with limited resources, like phones or edge hardware, where you can't afford to lug around that big suitcase of float32 weights.

Below is a table which clearly explains how the data changes.

|

Matrix (float32):

[ 3.14159, -0.7854 ]\
[ 2.71828, 1.4142 ]

 |

Matrix (float16):

[ 3.1416, -0.7854 ]

[ 2.7183,  1.4142 ]

 |

Matrix (float8):

[ 3.0,   -0.75 ]

[ 2.5,    1.5  ]

 |
|

Matrix (int8):

[ 127,  -50 ]

[ 110,   58 ]

 |

Matrix (int4):

[ 7, -2 ]

[ 6,  3 ]

 |  |

**Why use quantization?**[#]
Quantization is an important technique for fine-tuning and deploying large language models in real-world applications. As the models increase in size and complexity, quantization becomes essential for managing resource consumption without compromising accuracy. The following are some key benefits of using quantization:

**Reduced resource consumption:**

**Fast inference:** Quantization increases the training and inference speed of the model due to less computation and memory required for low-precision weights. This increased speed is beneficial when deploying models in real-time applications.

**Increased scalability:** Quantization allows the large-size model to be more scalable without increasing resource requirements. This enables the deployment of the model on various platforms, including hardware-constrained devices.

**Lower latency**: Quantization helps reduce latency in real-time applications. Since the model processes information more quickly using low-precision operations, it's perfect for situations where speed is crucial, like in self-driving cars or language translation.
