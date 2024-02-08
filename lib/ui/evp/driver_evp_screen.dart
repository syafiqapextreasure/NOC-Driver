import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nocdriver/model/User.dart';

class DriverEVPScreen extends StatefulWidget {
  final User user;

  DriverEVPScreen({Key? key, required this.user}) : super(key: key);

  @override
  _DriverEVPScreenState createState() => _DriverEVPScreenState();
}

class _DriverEVPScreenState extends State<DriverEVPScreen> {
  late User user;
  late CachedNetworkImageProvider _imageProvider;

  @override
  void initState() {
    super.initState();
    user = widget.user;
    _imageProvider = CachedNetworkImageProvider(user.evpPictureURL);
  }

  @override
  void dispose() {
    // Dispose the CachedNetworkImageProvider when the widget is disposed
    _imageProvider.evict();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Hero(
          tag: 'evpImage_${user.userID}', // Use a unique tag for each image
          child: CachedNetworkImage(
            width: 400,
            imageUrl: user.evpPictureURL ?? '',
            placeholder: (context, url) =>
                Image.asset('assets/images/img_placeholder.png', fit: BoxFit.fill),
            errorWidget: (context, url, error) =>
                Image.asset('assets/images/img_placeholder.png', fit: BoxFit.fill),
          ),
        ),
      ),
    );
  }
}
