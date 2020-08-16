import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth_manager/src/auth_constants.dart';
import 'package:firebase_auth_manager/src/auth_utilities.dart';
import 'package:firebase_auth_manager/src/data/providers/auth_provider.dart';
import 'package:firebase_auth_manager/src/widgets/otp_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:general_utilities/general_utilities.dart';

class PhoneLoginWidget extends StatefulWidget {
  const PhoneLoginWidget(
      {Key key,
      @required this.notValidNumberMsg,
      @required this.failedToAuthMsg,
      @required this.authCompletedMsg,
      @required this.codeSentToTheDeviceMsg,
      this.onAuthCompleted,
      this.logo})
      : assert(notValidNumberMsg != null),
        assert(failedToAuthMsg != null),
        assert(authCompletedMsg != null),
        assert(codeSentToTheDeviceMsg != null),
        super(key: key);

  final String notValidNumberMsg;
  final String failedToAuthMsg;
  final String authCompletedMsg;
  final String codeSentToTheDeviceMsg;
  final ImageProvider logo;
  final Function onAuthCompleted;

  @override
  _PhoneLoginWidgetState createState() => _PhoneLoginWidgetState();
}

class _PhoneLoginWidgetState extends State<PhoneLoginWidget> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
  final AuthProvider _provider = AuthProvider();
  final TextEditingController _phoneController = TextEditingController();

  String _countryCode = '+1';
  FocusNode _phoneFieldFocusNode;

  @override
  void initState() {
    super.initState();

    _phoneFieldFocusNode = FocusNode();

    _provider.verifyStream.stream.listen((state) {
      if (state == kNotValidPhoneNo) {
        _scaffoldKey.currentState
            .showSnackBar(getSnackBar(widget.notValidNumberMsg));
      }

      if (state == kVFailed) {
        _scaffoldKey.currentState
            .showSnackBar(getSnackBar(widget.failedToAuthMsg));
      }

      if (state == kVComplete) {
        _scaffoldKey.currentState
            .showSnackBar(getSnackBar(widget.authCompletedMsg));
      }

      if (state == kVCodeSent) {
        _scaffoldKey.currentState
            .showSnackBar(getSnackBar(widget.codeSentToTheDeviceMsg));
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => _OtpInputWidget(
                  authCompletedMsg: widget.authCompletedMsg,
                  logo: widget.logo,
                  authProvider: _provider,
                  onAuthCompleted: widget.onAuthCompleted,
                )));
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.symmetric(horizontal: kDimenNormal),
        child: SingleChildScrollView(child: buildBody(context)),
      ),
    );
  }

  Column buildBody(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _AppBarWidget(),
        SizedBox(width: 200.0, height: 200.0, child: Image(image: widget.logo)),
        SpaceWidget(),
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
        buildNumberField(),
        SpaceWidget(),
        SizedBox(
          width: double.infinity,
          child: RaisedButton(
            padding: EdgeInsets.symmetric(
                horizontal: kDimenNormal, vertical: kDimenMedium),
            onPressed: () {
              FocusScope.of(context).requestFocus(new FocusNode());
              _provider.verifyPhoneNumber(_getEnteredPhoneNumber());
            },
            child: Text('Confirm'),
          ),
        )
      ],
    );
  }

  Widget buildNumberField() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: CountryCodePicker(
              onChanged: (code) {
                setState(() {
                  _countryCode = code.dialCode;
                });
                _phoneFieldFocusNode.requestFocus();
              },
              initialSelection: 'US',
              favorite: ['+1', 'US'],
            ),
          ),
          SpaceWidget(
            isVertical: false,
            space: kDimenMedium,
          ),
          Expanded(
            flex: 7,
            child: TextField(
              focusNode: _phoneFieldFocusNode,
              controller: _phoneController,
              decoration: InputDecoration(hintText: 'Enter your number'),
              inputFormatters: [WhitelistingTextInputFormatter.digitsOnly],
              keyboardType: TextInputType.phone,
            ),
          ),
        ],
      ),
    );
  }

  String _getEnteredPhoneNumber() {
    String _phone = _phoneController.text;

    if (_phone.isNotEmpty && _phone.startsWith('0')) {
      _phone = _phone.substring(1);
    }
    return _countryCode + _phone;
  }

  SnackBar getSnackBar(String content) {
    return SnackBar(
      content: Text(content),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    );
  }
}

class _OtpInputWidget extends StatefulWidget {
  const _OtpInputWidget(
      {Key key,
      this.authCompletedMsg,
      this.logo,
      @required this.authProvider,
      this.onAuthCompleted})
      : super(key: key);

  final String authCompletedMsg;
  final ImageProvider logo;
  final AuthProvider authProvider;
  final Function onAuthCompleted;

  @override
  __OtpInputWidgetState createState() => __OtpInputWidgetState();
}

class __OtpInputWidgetState extends State<_OtpInputWidget> {
  @override
  void initState() {
    super.initState();

    widget.authProvider.verifyStream.stream.listen((state) {
      if (state == kVComplete) {
        SnackBarWidget.show(context, widget.authCompletedMsg);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    int fieldsCount = 6;
    double otpWidth = mediaQuery.size.width - (kDimenNormal * 2);
    double otpFieldWidth = otpWidth / fieldsCount;

    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        padding: EdgeInsets.symmetric(horizontal: kDimenNormal),
        child: buildWidgetBody(context, fieldsCount, otpWidth, otpFieldWidth),
      ),
    );
  }

  SingleChildScrollView buildWidgetBody(BuildContext context, int fieldsCount,
      double otpWidth, double otpFieldWidth) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _AppBarWidget(),
          SizedBox(
              width: 200.0, height: 200.0, child: Image(image: widget.logo)),
          SpaceWidget(),
          Text(
            'Verification code',
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.center,
          ),
          SpaceWidget(
            space: kDimenSmall,
          ),
          Text(
            'Please enter verification sent to your mobile phone',
            style: Theme.of(context).textTheme.bodyText2,
            textAlign: TextAlign.center,
          ),
          SpaceWidget(),
          OtpWidget(
            count: fieldsCount,
            width: otpWidth,
            fieldWidth: otpFieldWidth,
            onComplete: (pin) =>
                widget.authProvider.authByPhoneNumber(pin).then((value) {
              if (value) {
                widget.onAuthCompleted();
              } else {
                SnackBarWidget.show(context, 'Invalid verification code');
              }
            }),
          ),
          SpaceWidget(),
        ],
      ),
    );
  }
}

class _AppBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 24.0), // status bar height
      height: kToolbarHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
              icon: Icon(
                Icons.arrow_back,
              ),
              onPressed: () => Navigator.of(context).pop())
        ],
      ),
    );
  }
}
