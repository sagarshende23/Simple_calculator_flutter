import 'package:flutter/material.dart';
import 'package:gradient_widgets/gradient_widgets.dart';
import 'package:math_expressions/math_expressions.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}
String strInput = "";
final textControllerInput = TextEditingController();
final textControllerResult = TextEditingController();

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    textControllerInput.addListener(() {});
    textControllerResult.addListener(() {});
  }
  @override
  void dispose() {
    textControllerInput.dispose();
    textControllerResult.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          new Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: new TextField(
                decoration: new InputDecoration.collapsed(
                    hintText: "0",
                    hintStyle: TextStyle(
                      fontSize: 30,
                      fontFamily: 'RobotoMono',
                    )),
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'RobotoMono',
                ),
                textAlign: TextAlign.right,
                controller: textControllerInput,
                onTap: () =>
                    FocusScope.of(context).requestFocus(new FocusNode()),
              )),
          new Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                decoration: new InputDecoration.collapsed(
                    hintText: "Result",
                    // fillColor: Colors.deepPurpleAccent,
                    hintStyle: TextStyle(fontFamily: 'RobotoMono')),
                textInputAction: TextInputAction.none,
                keyboardType: TextInputType.number,
                style: TextStyle(
                    fontSize: 32,
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.bold
                    // color: Colors.deepPurpleAccent
),
                textAlign: TextAlign.right,
                controller: textControllerResult,
                onTap: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  // ClipboardManager.copyToClipBoard(textControllerResult.text).then((result) {
                  //   Fluttertoast.showToast(
                  //       msg: "Value copied to clipboard!",
                  //       toastLength: Toast.LENGTH_SHORT,
                  //       gravity: ToastGravity.CENTER,
                  //       timeInSecForIos: 1,
                  //       backgroundColor: Colors.blueAccent,
                  //       textColor: Colors.white,
                  //       fontSize: 16.0
                  //   );
                  // });
                },)),
          SizedBox( height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              btnAC('AC',const Color(0xFFF5F7F9),),
              btnClear(),
              btn('%',const Color(0xFFF5F7F9),),
              btn('/',const Color(0xFFF5F7F9),),],),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              btn('7', Colors.white),
              btn('8', Colors.white),
              btn('9', Colors.white),
              btn('*',const Color(0xFFF5F7F9),),],),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              btn('4', Colors.white),
              btn('5', Colors.white),
              btn('6', Colors.white),
              btn('-',const Color(0xFFF5F7F9),),],),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              btn('1', Colors.white),
              btn('2', Colors.white),
              btn('3', Colors.white),
              btn('+', const Color(0xFFF5F7F9)),],),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              btn('0', Colors.white),
              btn('.', Colors.white),
              btnEqual('='),],),
          SizedBox(height: 10.0,)],),
    );
  }
  Widget btn(btntext, Color btnColor) {
    return Container(
      padding: EdgeInsets.only(bottom: 10.0),
      child: FlatButton(
        child: Text(
          btntext,
          style: TextStyle(
              fontSize: 28.0, color: Colors.black, fontFamily: 'RobotoMono'),
        ),
        onPressed: () {
          setState(() {
            textControllerInput.text = textControllerInput.text + btntext;
          });
        },
        color: btnColor,
        padding: EdgeInsets.all(18.0),
        splashColor: Colors.black,
        shape: CircleBorder(),
      ),
    );
  }

  Widget btnClear() {
    return Container(
      padding: EdgeInsets.only(bottom: 10.0),
      child: FlatButton(
        child: Icon(Icons.backspace, size: 35, color: Colors.blueGrey),
        onPressed: () {
          textControllerInput.text = (textControllerInput.text.length > 0)
              ? (textControllerInput.text
                  .substring(0, textControllerInput.text.length - 1))
              : "";
        },
        color: const Color(0xFFF5F7F9),
        padding: EdgeInsets.all(18.0),
        splashColor: Colors.black,
        shape: CircleBorder(),
      ),
    );
  }
  Widget btnAC(btntext, Color btnColor) {
    return Container(
      padding: EdgeInsets.only(bottom: 10.0),
      child: FlatButton(
        child: Text(
          btntext,
          style: TextStyle(
              fontSize: 28.0, color: Colors.black, fontFamily: 'RobotoMono'),
        ),
        onPressed: () {
          setState(() {
            textControllerInput.text = "";
            textControllerResult.text = "";
          });
        },
        color: btnColor,
        padding: EdgeInsets.all(18.0),
        splashColor: Colors.black,
        shape: CircleBorder(),
      ),
    );
  }
  Widget btnEqual(btnText) {
    return GradientButton(
      child: Text(
        btnText,
        style: TextStyle(fontSize: 35.0),
      ),
      increaseWidthBy: 40.0,
      increaseHeightBy: 10.0,
      callback: () {
        //Calculate everything here
        // Parse expression:
        Parser p = new Parser();
        // Bind variables:
        ContextModel cm = new ContextModel();
        Expression exp = p.parse(textControllerInput.text);
        setState(() {
          textControllerResult.text =
              exp.evaluate(EvaluationType.REAL, cm).toString();
              });
      },
      gradient: Gradients.jShine,
    );
  }
}
