import 'package:flutter/material.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';
import 'package:ft_session_replay_flutter/ft_session_replay_flutter.dart';

class SessionReplayPage extends StatefulWidget {
  @override
  _SessionReplayPageState createState() => _SessionReplayPageState();
}

class _SessionReplayPageState extends State<SessionReplayPage> {
  final TextEditingController _textController =
      TextEditingController(text: "Replay input sample");
  final List<String> _gallerySeeds = <String>[
    "flutter-sr-0",
    "flutter-sr-1",
    "flutter-sr-2",
    "flutter-sr-3",
    "flutter-sr-4",
    "flutter-sr-5",
  ];

  int _round = 0;
  bool _showHiddenBlock = false;
  bool _checked = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Session Replay"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildControlSection(context),
            SizedBox(height: 16),
            _buildImageCaptureSection(),
            SizedBox(height: 16),
            _buildMaskedImageSection(),
            SizedBox(height: 16),
            _buildFormSection(),
            SizedBox(height: 16),
            _buildGallerySection(),
            SizedBox(height: 16),
            _buildHiddenSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlSection(BuildContext context) {
    return _Section(
      title: "Replay frame controls",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
              "Round $_round: tap controls to generate visible replay changes."),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              ElevatedButton(
                child: Text("Generate Frame"),
                onPressed: _generateReplayFrame,
              ),
              ElevatedButton(
                child: Text("Dialog"),
                onPressed: () {
                  FTRUMManager().startAction("SR Dialog", "click");
                  showDialog<void>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: Text("Session Replay Dialog"),
                        content:
                            Text("Dialog content should be visible in replay."),
                        actions: <Widget>[
                          TextButton(
                            child: Text("OK"),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              ElevatedButton(
                child: Text("SnackBar"),
                onPressed: () {
                  FTRUMManager().startAction("SR SnackBar", "click");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Session Replay SnackBar $_round")),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageCaptureSection() {
    return SessionReplayPrivacy(
      imagePrivacyLevel: ImagePrivacyLevel.maskNone,
      child: _Section(
        title: "Image capture",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text("This block overrides image privacy to record image content."),
            SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _imageUrl("hero-$_round", 640, 360),
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaskedImageSection() {
    return SessionReplayPrivacy(
      imagePrivacyLevel: ImagePrivacyLevel.maskNone,
      child: _Section(
        title: "Visible image",
        child: Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _imageUrl("private-$_round", 180, 180),
                width: 88,
                height: 88,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "This image is wrapped with SessionReplayPrivacy(maskNone), so replay should record the image content.",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return _Section(
      title: "Text, input, toggles",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text("Visible text changes when replay frames are generated."),
          SizedBox(height: 8),
          TextField(
            controller: _textController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Replay input",
            ),
          ),
          CheckboxListTile(
            value: _checked,
            title: Text("Checkbox state"),
            onChanged: (bool? value) {
              setState(() => _checked = value ?? false);
              FTRUMManager().startAction("SR Checkbox", "click");
            },
          ),
          SwitchListTile(
            value: _showHiddenBlock,
            title: Text("Show hidden content source"),
            onChanged: (bool value) {
              setState(() => _showHiddenBlock = value);
              FTRUMManager().startAction("SR Toggle Hidden", "click");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    return SessionReplayPrivacy(
      imagePrivacyLevel: ImagePrivacyLevel.maskNone,
      child: _Section(
        title: "Image list",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text("A scrolling list with changing remote images."),
            SizedBox(height: 12),
            SizedBox(
              height: 320,
              child: ListView.builder(
                itemCount: _gallerySeeds.length,
                itemBuilder: (BuildContext context, int index) {
                  final seed = "${_gallerySeeds[index]}-$_round";
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _imageUrl(seed, 120, 120),
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text("Replay image item $index"),
                    subtitle: Text(seed),
                    onTap: () {
                      FTRUMManager()
                          .startAction("SR Image Item $index", "click");
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHiddenSection() {
    return SessionReplayPrivacy(
      hide: !_showHiddenBlock,
      child: _Section(
        title: "Hidden privacy block",
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text("Sensitive account: 6222 0000 0000 $_round"),
            SizedBox(height: 8),
            Text(
                "Toggle above controls whether the original widget is shown locally; replay should capture a hidden placeholder while hide is true."),
          ],
        ),
      ),
    );
  }

  void _generateReplayFrame() {
    setState(() {
      _round++;
      _checked = !_checked;
      _textController.text = "Replay input sample $_round";
    });
    FTRUMManager().startAction("SR Generate Frame", "click",
        property: <String, Object?>{"round": _round});
  }

  String _imageUrl(String seed, int width, int height) {
    return "https://picsum.photos/seed/$seed/$width/$height";
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
