import 'package:UNISTOCK/screen_breakpoint.dart';
import 'package:flutter/widgets.dart';

extension ScreenSize on BuildContext {
  Size get deviceSize => MediaQuery.of(this).size;

  double get deviceHeight => deviceSize.height;

  double get deviceWidth => deviceSize.width;

  bool get isMobileDevice => deviceWidth < ScreenBreakpoint.mobileMaxWidth;

  bool get isTabletDevice =>
      !isMobileDevice && deviceWidth < ScreenBreakpoint.tabletMaxWidth;

  bool get isDesktopDevice => deviceWidth >= ScreenBreakpoint.desktopMinWidth;

  bool get isDesktopDeviceMaxWidth =>
      deviceWidth >= ScreenBreakpoint.desktopMaxWidth;

  bool get isLargeDesktopDevice =>
      deviceWidth >= ScreenBreakpoint.largeDesktopMaxWidth;
}

