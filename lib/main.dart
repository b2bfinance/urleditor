import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL Editor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Editor(title: 'URL Editor'),
    );
  }
}

class Editor extends StatefulWidget {
  Editor({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _EditorState createState() => _EditorState();
}

class _EditorState extends State<Editor> {
  Uri uri;
  TextEditingController urlTxt = TextEditingController();
  TextEditingController schemeTxt = TextEditingController();
  TextEditingController hostTxt = TextEditingController();
  TextEditingController pathTxt = TextEditingController();
  Map<String, String> queryParams;

  void rebuildPartsFromURI() {
    setState(() {
      schemeTxt.text = uri.scheme.toString();
      hostTxt.text = uri.host.toString();
      pathTxt.text = uri.path.toString();
      queryParams = uri.queryParameters;
    });
  }

  void rebuildURIFromParts() {
    setState(() {
      urlTxt.text = uri.toString();
    });
  }

  Widget createQueryParam(String key, String val, void Function(String, String) callback) {
    var keyTxt = TextEditingController(text: key);
    var valTxt = TextEditingController(text: val);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: keyTxt,
                decoration: const InputDecoration(
                  labelText: 'Key:',
                ),
                enabled: uri != null && key == "",
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              Text("="),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: valTxt,
                decoration: const InputDecoration(
                  labelText: 'Value:',
                ),
                enabled: uri != null,
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.add),
          tooltip: 'Set',
          onPressed: () {
            callback(keyTxt.text.toString(), valTxt.text.toString());
          },
        ),
        IconButton(
          icon: Icon(Icons.remove),
          tooltip: 'Remove',
          onPressed: () {
            callback(keyTxt.value.toString(), "");
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var widgets = <Widget>[
      TextFormField(
        controller: urlTxt,
        onChanged: (newValue) {
            setState(() {
              try {
                uri = Uri.parse(newValue);
              } on FormatException catch (_) {
                debugPrint("URL input not yet valid.");
              }
            });
            rebuildPartsFromURI();
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.add_location),
          hintText: 'What URL do you want to edit?',
          labelText: 'URL *',
        ),
      ),
      Padding(padding: EdgeInsets.all(5)),
      TextFormField(
        controller: schemeTxt,
        onChanged: (newValue) {
          setState(() {
            uri = uri.replace(scheme: newValue);
          });
          rebuildURIFromParts();
        },
        decoration: const InputDecoration(
          labelText: 'Scheme:',
        ),
        enabled: uri != null,
      ),
      Padding(padding: EdgeInsets.all(5)),
      TextFormField(
        controller: hostTxt,
        onChanged: (newValue) {
          setState(() {
            uri = uri.replace(host: newValue);
          });
          rebuildURIFromParts();
        },
        decoration: const InputDecoration(
          labelText: 'Host:',
        ),
        enabled: uri != null,
      ),
      Padding(padding: EdgeInsets.all(5)),
      TextFormField(
        controller: pathTxt,
        onChanged: (newValue) {
          setState(() {
            uri = uri.replace(path: newValue);
          });
          rebuildURIFromParts();
        },
        decoration: const InputDecoration(
          labelText: 'Path:',
        ),
        enabled: uri != null,
      ),
      Padding(padding: EdgeInsets.all(5)),
      Text("Query params:"),
    ];

    if (queryParams != null && queryParams.isNotEmpty) {
      queryParams.forEach((key, val) {
        widgets.add(createQueryParam(key, val, (_, val) {
          setState(() {
            var newParams = Map<String, String>();
            newParams.addAll(queryParams);

            if (val == "") {
              newParams.remove(key);
            } else {
              newParams[key] = val;
            }
            
            queryParams = newParams;
          });
          uri = uri.replace(queryParameters: queryParams);
          rebuildURIFromParts();
        }));
      });
    }

    // Add an empty query param placeholder.
    widgets.add(createQueryParam("", "", (key, val) {
      setState(() {
        var newParams = Map<String, String>();
        newParams.addAll(queryParams);

        if (val == "") {
          newParams.remove(key);
        } else {
          newParams[key] = val;
        }
        
        queryParams = newParams;
      });
      uri = uri.replace(queryParameters: queryParams);
      rebuildURIFromParts();
    }));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: widgets,
        ),
      ),
    );
  }
}

