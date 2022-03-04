import 'package:flutter/material.dart';

import 'package:dooz_color_picker/dooz_color_picker.dart';

void main() => runApp(const ColorPickerApp());

class ColorPickerApp extends StatefulWidget {
  const ColorPickerApp({Key? key}) : super(key: key);

  @override
  _ColorPickerAppState createState() => _ColorPickerAppState();
}

class _ColorPickerAppState extends State<ColorPickerApp> {
  Color? pickerColor;

  //
  Color? kelvinColor;
  int? kelvinValue;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ColorPicker",
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("ColorPicker"),
        ),
        body: Builder(
          builder: (c) {
            return Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    CircleColorPicker(
                      thumbRadius: 15,
                      radius: MediaQuery.of(c).size.width / 2 - 40,
                      initialColor: Colors.red,
                      child: Text(pickerColor?.toString() ?? ''),
                      colorListener: (Color value) {
                        setState(() {
                          pickerColor = value;
                        });
                      },
                    ),
                    CircleTemperaturePicker(
                      thumbRadius: 15,
                      radius: MediaQuery.of(c).size.width / 2 - 40,
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
                        '${kelvinColor?.toString() ?? ''}\n'
                        '${kelvinValue?.toString() ?? ''}',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
