import 'package:drivers/global/global.dart';
import 'package:drivers/infoHandler/app_info.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingsTabPage extends StatefulWidget {
  const RatingsTabPage({super.key});

  @override
  State<RatingsTabPage> createState() => _RatingsTabPageState();
}

class _RatingsTabPageState extends State<RatingsTabPage> {
  double ratingsNumber = 0;

  @override
  void initState() {
    super.initState();
    getRatingsNumber();
  }

  void getRatingsNumber() {
    setState(() {
      ratingsNumber = double.parse(Provider.of<AppInfo>(context, listen: false).driverAverageRatings);
    });
    setupRatingsTitle();
  }

  void setupRatingsTitle() {
    if (ratingsNumber >= 0) {
      setState(() {
        titleStarsRating = "Very Bad";
      });
    }
    if (ratingsNumber >= 1) {
      setState(() {
        titleStarsRating = "Bad";
      });
    }
    if (ratingsNumber >= 2) {
      setState(() {
        titleStarsRating = "Good";
      });
    }
    if (ratingsNumber >= 3) {
      setState(() {
        titleStarsRating = "Very Good";
      });
    }
    if (ratingsNumber >= 4) {
      setState(() {
        titleStarsRating = "Excellent";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor:Colors.white60,
        child: Container(
          margin: const EdgeInsets.all(4),
          width: double.infinity,
          decoration: BoxDecoration(
            color:Colors.white54,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 22.0),

              Text(
                "Таны үнэлгээ",
                style: TextStyle(
                  fontSize: 22,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                  color:Colors.blue,
                ),
              ),

              const SizedBox(height: 20),

              RatingBar.builder(
                initialRating: ratingsNumber,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 46,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color:Colors.blue,
                ),
                onRatingUpdate: (rating) {
                  // Read-only, no update needed
                },
                ignoreGestures: true, // Make it non-interactive
              ),

              const SizedBox(height: 12.0),

              Text(
                titleStarsRating,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color:Colors.blue,
                ),
              ),

              const SizedBox(height: 18.0),
            ],
          ),
        ),
      ),
    );
  }
}