
import 'package:flutter/material.dart';
import 'package:wfto_change_agent/reources/strings_resource.dart';
import 'package:wfto_change_agent/utils/widget_util.dart';

// ignore: must_be_immutable
class BlogStory extends StatelessWidget {
  final _minimumPadding = 8.0;
  BuildContext _buildContext;

  @override
  Widget build(BuildContext context) {
    _buildContext = context;
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: Colors.white10,
          centerTitle: true,
          title: Text(StringsResource.aboutAppTitle),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                moveToPreviousScreen(true);
              }),
        ),
        body: WidgetUtil()
            .getGradientBackgroundContainer(Form(child: getDetailsScreen())),
      ),
      // ignore: missing_return
      onWillPop: () {
        moveToPreviousScreen(false);
      },
    );
  }

  Widget getDetailsScreen() {
    return ListView(
      children: <Widget>[getTextWidget(), getButtonRow()],
    );
  }

  Widget getTextWidget() {
    return Padding(
      padding: EdgeInsets.all(_minimumPadding * 2),
      child: new Text(
        StringsResource.about_us_description,
        style: TextStyle(color: Colors.white70),
      ),
    );
  }

  Widget getButtonRow() {
    return Padding(
      padding: EdgeInsets.all(_minimumPadding),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                  left: _minimumPadding, right: _minimumPadding),
              child: RaisedButton(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(
                          color: Theme.of(_buildContext).accentColor),
                      borderRadius: BorderRadius.circular(20)),
                  textColor: Colors.white70,
                  child: Text(
                    StringsResource.done,
                    textScaleFactor: 1.5,
                  ),
                  onPressed: () {
                    moveToPreviousScreen(false);
                  }),
            ),
          ),
        ],
      ),
    );
  }

  void moveToPreviousScreen(bool hasChanged) {
    Navigator.pop(_buildContext, hasChanged);
  }
}
