import 'dart:typed_data';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:painter/painter.dart';
//import 'package:path_provider/path_provider.dart';
//import 'package:gallery_saver/gallery_saver.dart';
import 'image_file.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Painter Example',
      home: PainterCanvas(),
    );
  }
}

class PainterCanvas extends StatefulWidget {
  const PainterCanvas({Key? key}) : super(key: key);

  @override
  _PainterCanvasState createState() => _PainterCanvasState();
}

class _PainterCanvasState extends State<PainterCanvas> {
  bool _finished = false;

  PainterController _controller = _newController();

  ImageFile? imageFile;

  static PainterController _newController() {
    PainterController controller = PainterController();
    controller.thickness = 5.0;
    controller.backgroundColor = Colors.deepOrange;
    return controller;
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actions;
    if (_finished) {
      actions = <Widget>[
        IconButton(
          icon: const Icon(Icons.layers_clear_rounded),
          tooltip: 'New Painting',
          onPressed: () => setState(() {
            _finished = false;
            _controller = _newController();
          }),
        ),
      ];
    } else {
      actions = <Widget>[
        IconButton(
            icon: const Icon(
              Icons.undo,
            ),
            tooltip: 'Undo',
            onPressed: () {
              if (_controller.isEmpty) {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) =>
                        const Text('Nothing to undo'));
              } else {
                _controller.undo();
              }
            }),
        IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Clear',
            onPressed: _controller.clear),
        IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => _show(_controller.finish(), context)),
      ];
    }
    return Scaffold(
      appBar: AppBar(
          title: const Text('Painter Example'),
          actions: actions,
          bottom: PreferredSize(
            child: DrawBar(_controller),
            preferredSize: Size(MediaQuery.of(context).size.width, 30.0),
          )),
      body: Center(
          child: AspectRatio(aspectRatio: 1.0, child: Painter(_controller))),
    );
  }

  _show(PictureDetails picture, BuildContext context) {
    setState(() {
      _finished = true;
    });
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('View your image'),
        ),
        body: Container(
            alignment: Alignment.center,
            child: FutureBuilder<Uint8List>(
              future: picture.toPNG(),
              builder:
                  (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.done:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      ImageFile(imageFile: Image.memory(snapshot.data!));

                      return Image.memory(snapshot.data!);
                      /* var imageFile = Image.memory(snapshot.data!);
                      return imageFile; */
                    }
                  default:
                    return const FractionallySizedBox(
                      widthFactor: 0.1,
                      child: AspectRatio(
                          aspectRatio: 1.0, child: CircularProgressIndicator()),
                      alignment: Alignment.center,
                    );
                }
              },
            )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _saveFileImage(),
          tooltip: 'Save to gallery',
          child: const Icon(Icons.save_alt_outlined),
        ),
      );
    }));
  }

  // Future<dynamic> _saveImage(imageFile) async {
  //   String dir = (await getApplicationDocumentsDirectory()).path;
  //   debugPrint('Save button pressed');
  //   final result = await ImageGallerySaver.saveFile(dir + imageFile);

  //   return result;
  // }

  _saveFileImage() async {
    //Request permissions if not already granted
    if (!(await Permission.storage.status.isGranted)) {
      await Permission.storage.request();
    }

    Future result = await ImageGallerySaver.saveImage(
      _show(_controller.finish(), context),
      name: 'Canvas Image',
    );
    debugPrint('Reached here');
    return result;
  }
}

class DrawBar extends StatelessWidget {
  final PainterController _controller;

  DrawBar(this._controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
          return Slider(
            value: _controller.thickness,
            onChanged: (double value) => setState(() {
              _controller.thickness = value;
            }),
            min: 1.0,
            max: 20.0,
            activeColor: Colors.white,
          );
        })),
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
          return RotatedBox(
              quarterTurns: _controller.eraseMode ? 2 : 0,
              child: IconButton(
                  icon: const Icon(Icons.create),
                  tooltip: (_controller.eraseMode ? 'Disable' : 'Enable') +
                      ' eraser',
                  onPressed: () {
                    setState(() {
                      _controller.eraseMode = !_controller.eraseMode;
                    });
                  }));
        }),
        ColorPickerButton(_controller, false),
        ColorPickerButton(_controller, true),
      ],
    );
  }
}

class ColorPickerButton extends StatefulWidget {
  final PainterController _controller;
  final bool _background;

  const ColorPickerButton(this._controller, this._background, {Key? key})
      : super(key: key);

  @override
  _ColorPickerButtonState createState() => _ColorPickerButtonState();
}

class _ColorPickerButtonState extends State<ColorPickerButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(_iconData, color: _color),
        tooltip: widget._background
            ? 'Change background color'
            : 'Change draw color',
        onPressed: _pickColor);
  }

  void _pickColor() {
    Color pickerColor = _color;
    Navigator.of(context)
        .push(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (BuildContext context) {
              return Scaffold(
                  appBar: AppBar(
                    title: const Text('Pick color'),
                  ),
                  body: Container(
                      alignment: Alignment.center,
                      child: ColorPicker(
                        pickerColor: pickerColor,
                        onColorChanged: (Color c) => pickerColor = c,
                      )));
            }))
        .then((_) {
      setState(() {
        _color = pickerColor;
      });
    });
  }

  Color get _color => widget._background
      ? widget._controller.backgroundColor
      : widget._controller.drawColor;

  IconData get _iconData =>
      widget._background ? Icons.format_color_fill : Icons.brush;

  set _color(Color color) {
    if (widget._background) {
      widget._controller.backgroundColor = color;
    } else {
      widget._controller.drawColor = color;
    }
  }
}
