/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal,deprecated_member_use

import 'package:flutter/widgets.dart';

class $AssetsAppSettingsGen {
  const $AssetsAppSettingsGen();

  /// File path: assets/app_settings/background.png
  AssetGenImage get background =>
      const AssetGenImage('assets/app_settings/background.png');

  /// File path: assets/app_settings/launcher_icon.png
  AssetGenImage get launcherIcon =>
      const AssetGenImage('assets/app_settings/launcher_icon.png');

  /// File path: assets/app_settings/launcher_icon_ios.png
  AssetGenImage get launcherIconIos =>
      const AssetGenImage('assets/app_settings/launcher_icon_ios.png');

  /// File path: assets/app_settings/splash_background.png
  AssetGenImage get splashBackground =>
      const AssetGenImage('assets/app_settings/splash_background.png');

  /// File path: assets/app_settings/splash_icon.png
  AssetGenImage get splashIcon =>
      const AssetGenImage('assets/app_settings/splash_icon.png');

  /// File path: assets/app_settings/splash_icon_android_12.png
  AssetGenImage get splashIconAndroid12 =>
      const AssetGenImage('assets/app_settings/splash_icon_android_12.png');

  /// List of all assets
  List<AssetGenImage> get values => [
        background,
        launcherIcon,
        launcherIconIos,
        splashBackground,
        splashIcon,
        splashIconAndroid12
      ];
}

class $AssetsImagesGen {
  const $AssetsImagesGen();

  /// File path: assets/images/background.png
  AssetGenImage get background =>
      const AssetGenImage('assets/images/background.png');

  /// List of all assets
  List<AssetGenImage> get values => [background];
}

class Assets {
  Assets._();

  static const $AssetsAppSettingsGen appSettings = $AssetsAppSettingsGen();
  static const $AssetsImagesGen images = $AssetsImagesGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({
    AssetBundle? bundle,
    String? package,
  }) {
    return AssetImage(
      _assetName,
      bundle: bundle,
      package: package,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
