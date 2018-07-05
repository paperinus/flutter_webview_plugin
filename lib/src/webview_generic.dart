import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'base.dart';
import 'package:rect_getter/rect_getter.dart';


class WebviewGeneric extends StatefulWidget {
  final String url;
  final bool withJavascript;
  final bool clearCache;
  final bool clearCookies;
  final bool enableAppScheme;
  final String userAgent;
  final bool primary;
  final bool withZoom;
  final bool withLocalStorage;
  final bool withLocalUrl;
  final double height;
  final double width;
  final Rect rect;
  final GlobalKey keyGlobal;

  WebviewGeneric({
    Key key,
    @required this.url,
    @required this.width,
    @required this.height,
    this.rect,
    this.keyGlobal,
    this.withJavascript,
    this.clearCache,
    this.clearCookies,
    this.enableAppScheme,
    this.userAgent,
    this.primary: true,
    this.withZoom,
    this.withLocalStorage,
    this.withLocalUrl,
  }) : super(key: key);

  @override
  _WebviewGenericState createState() => new _WebviewGenericState();
}

class _WebviewGenericState extends State<WebviewGeneric> {
  final webviewReference = new FlutterWebviewPlugin();
  Rect _rect;
  Timer _resizeTimer;

  void initState() {
    super.initState();
    webviewReference.close();
  }

  void dispose() {
    super.dispose();
    webviewReference.close();
    webviewReference.dispose();
  }

  @override
  Widget build(BuildContext context) {

    if (_rect == null) {
      _rect = _buildRect(context);
      _resizeTimer?.cancel();

      webviewReference.launch(widget.url,
          withJavascript: widget.withJavascript,
          clearCache: widget.clearCache,
          clearCookies: widget.clearCookies,
          enableAppScheme: widget.enableAppScheme,
          userAgent: widget.userAgent,
          rect: _rect,
          withZoom: widget.withZoom,
          withLocalStorage: widget.withLocalStorage,
          withLocalUrl: widget.withLocalUrl);
      _resizeTimer = new Timer(new Duration(milliseconds: 300), () {
        _rect = _buildRect(context);
        webviewReference.resize(_rect);
      });
    } else {
      Rect rect = _buildRect(context);
      if (_rect != rect) {
        _rect = rect;
        _resizeTimer?.cancel();
        _resizeTimer = new Timer(new Duration(milliseconds: 300), () {
          // avoid resizing to fast when build is called multiple time
          _rect = _buildRect(context);
          webviewReference.resize(_rect);
        });
      }
    }

    return  new Container(
        child: new Center(child: new CircularProgressIndicator()));
  }

  Rect _buildRect(BuildContext context) {

/*
    if (widget.bottomNavigationBar != null) {
      height -=
          56.0 + mediaQuery.padding.bottom; // todo(lejard_h) find a way to determine bottomNavigationBar programmatically
    }

    if (widget.persistentFooterButtons != null) {
      height -=
          53.0; // todo(lejard_h) find a way to determine persistentFooterButtons programmatically
      if (widget.bottomNavigationBar == null){
         height -= mediaQuery.padding.bottom;
      }
    }
*/
    try{
      return RectGetter.getRectFromKey(widget.keyGlobal);

    }catch(err){
      return new Rect.fromLTWH(0.0, 0.0, 0.0, 0.0);
    }
    //
  }

}
