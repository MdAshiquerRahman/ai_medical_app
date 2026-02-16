import 'package:flutter/foundation.dart';

@immutable
class ModelConfig {
  final String modelPath;
  final List<String> classLabels;
  final int inputWidth;
  final int inputHeight;
  final int inputChannels;
  final int batchSize;

  const ModelConfig({
    required this.modelPath,
    required this.classLabels,
    this.inputWidth = 224,
    this.inputHeight = 224,
    this.inputChannels = 3,
    this.batchSize = 1,
  });

  int get numClasses => classLabels.length;

  List<int> get inputShape => [
    batchSize,
    inputHeight,
    inputWidth,
    inputChannels,
  ];
}
