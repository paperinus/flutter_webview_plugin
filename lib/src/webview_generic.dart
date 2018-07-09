import 'dart:async';
import 'base.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebviewGeneric extends StatefulWidget {
  final String url;
  final bool withJavascript;
  final bool clearCache;
  final bool clearCookies;
  final bool enableAppScheme;
  final String userAgent;
  final bool withZoom;
  final bool withLocalStorage;
  final bool withLocalUrl;
  final GlobalKey<_WebviewGenericState> key;

  WebviewGeneric({
    Key key,
    @required this.url,
    this.withJavascript,
    this.clearCache,
    this.clearCookies,
    this.enableAppScheme,
    this.userAgent,
    this.withZoom,
    this.withLocalStorage,
    this.withLocalUrl,
  }) : super(key: key);

  static Rect getRectFromKey(GlobalKey<_WebviewGenericState> globalKey) {
    var object = globalKey?.currentContext?.findRenderObject();
    var translation = object?.getTransformTo(null)?.getTranslation();
    var size = object?.semanticBounds?.size;

    if (translation != null && size != null) {
      return new Rect.fromLTWH(translation.x, translation.y, size.width, size.height);
    } else {
      return null;
    }
  }

  @override
  _WebviewGenericState createState() => new _WebviewGenericState();
}

class _WebviewGenericState extends State<WebviewGeneric> {
  final webviewReference = new FlutterWebviewPlugin();
  Rect _rect;
  Timer _resizeTimer;
  var globalKey = new GlobalKey<_WebviewGenericState>();
  bool isIOs;

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
      isIOs = Theme.of(context).platform == TargetPlatform.iOS;
      return new Container(
        key: globalKey,
        child: new LayoutBuilder(builder:
            (BuildContext context, BoxConstraints constraints) {
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
                _resizeTimer = new Timer(new Duration(milliseconds: 100), () {
                  _rect = _buildRect(context);
                  webviewReference.resize(_rect);
                });
              } else {
                Rect rect = _buildRect(context); //new Rect.fromLTWH(0.0, 0.0, 0.0, 0.0);;
                if (_rect != rect && (!isIOs || (isIOs && rect != new Rect.fromLTWH(0.0, 0.0, 0.0, 0.0)))) {
                  _rect = rect;
                  webviewReference.resize(_rect);
                  _resizeTimer?.cancel();
                  _resizeTimer = new Timer(new Duration(milliseconds: 100), () {
                    // avoid resizing to fast when build is called multiple time
                    _rect = _buildRect(context);
                    webviewReference.resize(_rect);
                  });
                }
              }
              return new Container();
        }),
    );
  }

  Rect _buildRect(BuildContext context) {
    try{
      return WebviewGeneric.getRectFromKey(globalKey);

    }catch(err){
      return new Rect.fromLTWH(0.0, 0.0, 0.0, 0.0);
    }
    //
  }

}
