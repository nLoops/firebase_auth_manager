import 'dart:async';

import 'package:firebase_auth_manager/src/auth_constants.dart';
import 'package:firebase_auth_manager/src/data/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:general_utilities/general_utilities.dart';

class PhoneLoginWidget extends StatefulWidget {
  const PhoneLoginWidget({Key key, @required this.message}) : super(key: key);

  final String message;
  @override
  _PhoneLoginWidgetState createState() => _PhoneLoginWidgetState();
}

class _PhoneLoginWidgetState extends State<PhoneLoginWidget> {
  final AuthProvider _provider = AuthProvider();

  @override
  void initState() {
    super.initState();

    _provider.verifyStream.stream.listen((state) {
      if (state == kVFailed) {
        SnackBarWidget.show(context, 'Failed');
      }

      if (state == kVComplete) {
        SnackBarWidget.show(context, 'Success');
      }

      if (state == kVCodeSent) {
        SnackBarWidget.show(context, 'Code sent');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).size.height * 0.15;

    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.only(
            top: topPadding, left: kDimenNormal, right: kDimenNormal),
        child: buildBody(context),
      ),
    );
  }

  Column buildBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Log-in by phone number',
          style: Theme.of(context).textTheme.headline6,
          textAlign: TextAlign.center,
        ),
        SpaceWidget(
          space: kDimenSmall,
        ),
        Text(
          'A 6 digits code will sent to your mobile device to complete your process',
          style: Theme.of(context).textTheme.bodyText2,
          textAlign: TextAlign.center,
        ),
        SpaceWidget(),
        TextField(
          decoration: InputDecoration(hintText: 'Enter your number'),
        ),
        SpaceWidget(),
        SizedBox(
          width: double.infinity,
          child: RaisedButton(
            padding: EdgeInsets.symmetric(
                horizontal: kDimenNormal, vertical: kDimenMedium),
            onPressed: () => _provider.verifyPhoneNumber('0549022834'),
            child: Text('Confirm'),
          ),
        )
      ],
    );
  }
}
