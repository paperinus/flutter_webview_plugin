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

  @override
  _WebviewGenericState createState() => new _WebviewGenericState();
}

class _WebviewGenericState extends State<WebviewGeneric> {
  final webviewReference = new FlutterWebviewPlugin();
  Rect _rect;
  Timer _resizeTimer;
  var globalKey = RectGetter.createGlobalKey();

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


    return new RectGetter(
      key: globalKey,
      child: new Container(
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
                _resizeTimer = new Timer(new Duration(milliseconds: 300), () {
                  _rect = _buildRect(context);
                  webviewReference.resize(_rect);
                });
              } else {
                Rect rect = new Rect.fromLTWH(0.0, 0.0, 0.0, 0.0);//_buildRect(context);
                if (_rect != rect) {
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
      ),
    );




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
      return RectGetter.getRectFromKey(globalKey);

    }catch(err){
      return new Rect.fromLTWH(0.0, 0.0, 0.0, 0.0);
    }
    //
  }

}

class RectGetter extends StatefulWidget {
  final GlobalKey<_RectGetterState> key;
  final Widget child;

  /// Use this static method to get child`s rectangle information when had a custom globalkey
  static Rect getRectFromKey(GlobalKey<_RectGetterState> globalKey) {
    var object = globalKey?.currentContext?.findRenderObject();
    var translation = object?.getTransformTo(null)?.getTranslation();
    var size = object?.semanticBounds?.size;

    if (translation != null && size != null) {
      return new Rect.fromLTWH(translation.x, translation.y, size.width, size.height);
    } else {
      return null;
    }
  }

  /// create a custom globalkey , use this way to avoid type exception in dart2 .
  static GlobalKey<_RectGetterState> createGlobalKey() {
    return new GlobalKey<_RectGetterState>();
  }
  /// constructor with key passed , and then you can get child`s rect by using RectGetter.getRectFromKey(key)
  RectGetter({@required this.key, @required this.child}) : super(key: key);

  Rect getRect() {
    return getRectFromKey(this.key);
  }

  @override
  _RectGetterState createState() => new _RectGetterState();
}

class _RectGetterState extends State<RectGetter> {
  @override
  Widget build(BuildContext context) => widget.child;
}
