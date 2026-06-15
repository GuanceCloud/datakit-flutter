import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({Key? key}) : super(key: key);

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  static const int _imageCount = 6;
  final Random _random = Random();
  late List<int> _seeds;

  @override
  void initState() {
    super.initState();
    _seeds = _createSeeds();
  }

  List<int> _createSeeds() {
    return List<int>.generate(
      _imageCount,
      (_) => _random.nextInt(1000000),
    );
  }

  String _picsumUrl(int seed) {
    return 'https://picsum.photos/seed/$seed/100/100';
  }

  void _refreshImages() {
    setState(() {
      _seeds = _createSeeds();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Display"),
        actions: <Widget>[
          IconButton(
            tooltip: "Refresh images",
            icon: Icon(Icons.refresh),
            onPressed: _refreshImages,
          ),
        ],
      ),
      body: GridView.count(
        padding: EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: <Widget>[
          _buildImageTile(context, _seeds[0], "Network Image 1"),
          _buildImageTile(context, _seeds[1], "Network Image 2"),
          _buildImageTile(context, _seeds[2], "Network Image 3"),
          _buildImageTile(context, _seeds[3], "Network Image 4"),
          SessionReplayPrivacy(
            imagePrivacyLevel: ImagePrivacyLevel.maskAll,
            child: _buildImageTile(context, _seeds[4], "Masked Image"),
          ),
          _buildImageTile(context, _seeds[5], "Network Image 6"),
        ],
      ),
    );
  }

  Widget _buildImageTile(BuildContext context, int seed, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: Container(
            color: Colors.black12,
            child: Image.network(
              _picsumUrl(seed),
              key: ValueKey<int>(seed),
              fit: BoxFit.cover,
              loadingBuilder: (
                BuildContext context,
                Widget child,
                ImageChunkEvent? loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
              errorBuilder: (
                BuildContext context,
                Object error,
                StackTrace? stackTrace,
              ) {
                return Center(
                  child: Text("Image load failed"),
                );
              },
            ),
          ),
        ),
        SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
