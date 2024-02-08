import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nocdriver/constants.dart';
import 'package:flutter/material.dart';

class ParcelImagesShow extends StatefulWidget {
  List<dynamic> images;

  ParcelImagesShow({Key? key, required this.images}) : super(key: key);

  @override
  State<ParcelImagesShow> createState() => _ParcelImagesShowState();
}

class _ParcelImagesShowState extends State<ParcelImagesShow> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back))),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: widget.images.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: (MediaQuery.of(context).orientation == Orientation.portrait) ? 2 : 3),
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: widget.images[index].toString(),
                        imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                        placeholder: (context, url) => Center(
                            child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
                        )),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context, "orderCancel");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 15.0,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'Reject'.tr(),
                        style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 16),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context, "pickup");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(COLOR_PRIMARY),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 15.0,
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        'Pickup Parcel'.tr(),
                        style: TextStyle(fontFamily: "GlacialIndifference",fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}
