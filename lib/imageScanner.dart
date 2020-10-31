import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Scanner extends StatefulWidget {
  @override
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  int _cameraOcr = FlutterMobileVision.CAMERA_BACK;
  bool _autoFocusOcr = true;
  bool _torchOcr = false;
  bool _multipleOcr = true;
  bool _waitTapOcr = true;
  bool _showTextOcr = true;
  Size _previewOcr;
  List<OcrText> _textsOcr = [];
  //Product
  String cardbody = "Please go ahead and scan your item!";
  String type, category, calory, name;

  @override
  void initState() {
    super.initState();
    FlutterMobileVision.start().then((previewSizes) => setState(() {
          _previewOcr = previewSizes[_cameraOcr].first;
        }));
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<DropdownMenuItem<int>> _getCameras() {
    List<DropdownMenuItem<int>> cameraItems = [];

    cameraItems.add(new DropdownMenuItem(
      child: new Text('BACK'),
      value: FlutterMobileVision.CAMERA_BACK,
    ));

    cameraItems.add(new DropdownMenuItem(
      child: new Text('FRONT'),
      value: FlutterMobileVision.CAMERA_FRONT,
    ));

    return cameraItems;
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.keyboard_arrow_left,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(context, '0.0'),
        ),
        title: const Text(
          'Food Scan',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: Column(
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(20),
              child: new Text("Which camera would you like to use?",
                  style: TextStyle(fontSize: 18))),
          Padding(
            padding: const EdgeInsets.only(
              left: 18.0,
              right: 18.0,
            ),
            child: new DropdownButton(
              items: _getCameras(),
              onChanged: (value) {
                _previewOcr = null;
                setState(() => _cameraOcr = value);
              },
              value: _cameraOcr,
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(20),
              child: new Text("Please turn on if in low light environemnts.",
                  style: TextStyle(fontSize: 18))),
          SwitchListTile(
            title: const Text('Torch'),
            value: _torchOcr,
            onChanged: (value) => setState(() => _torchOcr = value),
          ),
          Center(
            child: RaisedButton(
              color: Colors.blue,
              padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
              onPressed: _read,
              child: Text(
                "Let's Scan",
                style: TextStyle(color: Colors.white),
              ),
              shape: StadiumBorder(),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  DecoratedBox(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.0),
                          color: Colors.white),
                      child: Container(
                        width: (0.8) * MediaQuery.of(context).size.width,
                        height: 0.43 * MediaQuery.of(context).size.height,
                        child: Text(cardbody,
                        style: TextStyle(
                          fontSize: 25
                        )),
                      )),
                  Container(height: 20.0)
                ],
              ),
              Column(children: <Widget>[
                Container(height: 0.4 * MediaQuery.of(context).size.height),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    FlatButton(
                      shape: StadiumBorder(),
                      color: Colors.red,
                      child: Text("No",
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                      onPressed: () => Navigator.pop(context, '0.0'),
                    ),
                    SizedBox(
                      width: 25,
                    ),
                    FlatButton(
                      shape: StadiumBorder(),
                      color: Colors.blue,
                      child: Text("Yes",
                          style: TextStyle(color: Colors.white, fontSize: 15)),
                      onPressed: () => Navigator.pop(context, calory),
                    ),
                  ],
                )
              ])
            ],
          )
        ],
      ),
    );
  }

  Future<Null> _read() async {
    List<OcrText> texts = [];
    try {
      texts = await FlutterMobileVision.read(
        flash: _torchOcr,
        autoFocus: _autoFocusOcr,
        multiple: _multipleOcr,
        waitTap: _waitTapOcr,
        showText: _showTextOcr,
        preview: _previewOcr,
        camera: _cameraOcr,
        fps: 2.0,
      );
    } on Exception {
      texts.add(new OcrText('Failed to recognize text.'));
    }

    if (!mounted) return;
    setState(() => _textsOcr = texts);
    for (var items in _textsOcr) getData(items.value);
  }

  Future<Null> getData(proname) async {
    var response = await http.get(
        Uri.encodeFull("http://192.168.137.1:8080/calories/" + proname),
        headers: {"Accept": "application/json"});
    print(response.body);
    if (response.body != "") {
      setState(() {
        name = jsonDecode(response.body.split(',')[0].split(":")[1]);
        category = jsonDecode(response.body.split(',')[1].split(":")[1]);
        type = jsonDecode(response.body.split(',')[2].split(":")[1]);
        calory = jsonDecode(response.body.split(',')[3].split(":")[1]).toString();
        cardbody = "The item you selected is " +
            name.toUpperCase() +
            ", it belongs to the category of " +
            category +
            ". It has " +
            calory +
            " calories per gram." +
            "Please let us know that are you going to consume this product?";
      });
    }
    print(cardbody);
  }
}