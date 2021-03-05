import 'package:flutter/material.dart';

import 'package:dooz_color_picker/dooz_color_picker.dart';

void main() => runApp(ColorPickerApp());

class ColorPickerApp extends StatefulWidget {
  @override
  _ColorPickerAppState createState() => _ColorPickerAppState();
}

class _ColorPickerAppState extends State<ColorPickerApp> {
  Color pickerColor;

  //
  Color kelvinColor;
  int kelvinValue;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ColorPicker",
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text("ColorPicker"),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 20),
              CircleColorPicker(
                radius: 140,
                thumbRadius: 15,
                initialColor: Colors.red,
                child: Text(pickerColor?.toString() ?? ''),
                colorListener: (Color value) {
                  setState(() {
                    pickerColor = value;
                  });
                },
              ),
              SizedBox(height: 20),
              CircleTemperaturePicker(
                radius: 140,
                thumbRadius: 25,
                initialTemperature: 2600,
                startTemperature: 2600,
                endTemperature: 10600,
                colorListener: (Color value, int kDegree) {
                  setState(() {
                    kelvinColor = value;
                    kelvinValue = kDegree;
                  });
                },
                child: Text(
                  (kelvinColor?.toString() ?? '') +
                      '\n' +
                      (kelvinValue?.toString() ?? ''),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
