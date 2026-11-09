// Platform asset conversion only. The selected artwork is not regenerated.
import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final source = img.decodePng(
    File('assets/branding/selected_sprout_source.png').readAsBytesSync(),
  )!;
  final lockup = img.decodePng(
    File('assets/branding/sprout_lockup.png').readAsBytesSync(),
  )!;
  void save(String path, img.Image image) {
    final file = File(path)..parent.createSync(recursive: true);
    file.writeAsBytesSync(img.encodePng(image));
  }

  save(
    'assets/branding/save_goals_icon.png',
    img.copyResize(
      source,
      width: 1024,
      height: 1024,
      interpolation: img.Interpolation.average,
    ),
  );
  final foreground = img.Image(width: 1024, height: 1024, numChannels: 4);
  img.compositeImage(
    foreground,
    img.copyResize(
      lockup,
      width: 716,
      height: 716,
      interpolation: img.Interpolation.average,
    ),
    dstX: 154,
    dstY: 154,
  );
  save('assets/branding/save_goals_adaptive.png', foreground);
  save('android/app/src/main/res/drawable/splash_android12.png', foreground);
  for (final scale in [1, 2, 3]) {
    save(
      'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage${scale == 1 ? '' : '@${scale}x'}.png',
      img.copyResize(
        lockup,
        width: 260 * scale,
        height: 260 * scale,
        interpolation: img.Interpolation.average,
      ),
    );
  }
  for (final density in {
    'mdpi': 1.0,
    'hdpi': 1.5,
    'xhdpi': 2.0,
    'xxhdpi': 3.0,
    'xxxhdpi': 4.0,
  }.entries) {
    final size = (260 * density.value).round();
    save(
      'android/app/src/main/res/drawable-${density.key}/splash_logo.png',
      img.copyResize(
        lockup,
        width: size,
        height: size,
        interpolation: img.Interpolation.average,
      ),
    );
  }
  stdout.writeln(
    'Prepared launcher and native splash assets from the selected sprout.',
  );
}
