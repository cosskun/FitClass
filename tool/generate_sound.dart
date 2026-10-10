import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

Uint8List u32(int value) => (ByteData(4)..setUint32(0, value, Endian.little)).buffer.asUint8List();
Uint8List u16(int value) => (ByteData(2)..setUint16(0, value, Endian.little)).buffer.asUint8List();
Uint8List i16(int value) => (ByteData(2)..setInt16(0, value, Endian.little)).buffer.asUint8List();

void main() {
  final soundDir = Directory('assets/sounds');
  if (!soundDir.existsSync()) {
    soundDir.createSync(recursive: true);
  }

  const sampleRate = 44100;
  const duration = 1.3;
  final numSamples = (sampleRate * duration).toInt();

  final byteData = BytesBuilder();

  // Generate PCM data (16-bit Mono, Little Endian)
  for (int i = 0; i < numSamples; i++) {
    final t = i / sampleRate;
    double val = 0.0;

    if (t < 0.22) {
      // Beep 1 (G5 - 784 Hz)
      final env = exp(-8.0 * t);
      val = sin(2 * pi * 783.99 * t) * env;
      val += 0.25 * sin(2 * pi * 1567.98 * t) * env;
    } else if (t >= 0.25 && t < 0.47) {
      // Beep 2 (B5 - 987.77 Hz)
      final tRel = t - 0.25;
      final env = exp(-8.0 * tRel);
      val = sin(2 * pi * 987.77 * tRel) * env;
      val += 0.25 * sin(2 * pi * 1975.54 * tRel) * env;
    } else if (t >= 0.50 && t < 1.3) {
      // Chime / Gong (E6 - 1318.51 Hz with rich harmonic shimmer)
      final tRel = t - 0.50;
      final env = exp(-3.8 * tRel);
      val = sin(2 * pi * 1318.51 * tRel) * env;
      val += 0.35 * sin(2 * pi * 2637.02 * tRel) * env;
      val += 0.15 * sin(2 * pi * 3955.53 * tRel) * env;
    }

    final sampleInt = (val * 24000).clamp(-32767, 32767).toInt();
    byteData.add(i16(sampleInt));
  }

  final pcmBytes = byteData.toBytes();

  // Build WAV Header
  final wavHeader = BytesBuilder();
  // "RIFF" chunk
  wavHeader.add('RIFF'.codeUnits);
  final fileSize = 36 + pcmBytes.length;
  wavHeader.add(u32(fileSize));
  wavHeader.add('WAVE'.codeUnits);

  // "fmt " sub-chunk
  wavHeader.add('fmt '.codeUnits);
  wavHeader.add(u32(16)); // Subchunk1Size (16 for PCM)
  wavHeader.add(u16(1)); // AudioFormat (1 = PCM)
  wavHeader.add(u16(1)); // NumChannels (1 = Mono)
  wavHeader.add(u32(sampleRate)); // SampleRate
  wavHeader.add(u32(sampleRate * 2)); // ByteRate
  wavHeader.add(u16(2)); // BlockAlign
  wavHeader.add(u16(16)); // BitsPerSample

  // "data" sub-chunk
  wavHeader.add('data'.codeUnits);
  wavHeader.add(u32(pcmBytes.length));

  final wavFile = File('assets/sounds/timer_complete.wav');
  wavFile.writeAsBytesSync([...wavHeader.toBytes(), ...pcmBytes]);

  print('assets/sounds/timer_complete.wav successfully created! Size: ${wavFile.lengthSync()} bytes');
}
