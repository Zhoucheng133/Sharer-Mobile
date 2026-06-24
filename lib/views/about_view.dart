import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatefulWidget {

  final String version;

  const AboutView({super.key, required this.version});

  @override
  State<AboutView> createState() => _AboutViewState();
}

class _AboutViewState extends State<AboutView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('about'.tr),
      ),
      body: Center(
        child: Column(
          mainAxisSize: .min,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/icon.png")
                )
              ),
            ),
            const SizedBox(height: 10,),
            Text(
              'Sharer',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 25,
              ),
            ),
            const SizedBox(height: 10,),
            Text(
              "v${widget.version}",
              style: TextStyle(
                fontWeight: FontWeight.w300,
                color: Colors.grey[600],
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20,),
            GestureDetector(
              onTap: (){
                final url=Uri.parse('https://github.com/Zhoucheng133/Sharer-Mobile');
                launchUrl(url);
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.github,
                    size: 15,
                  ),
                  const SizedBox(width: 5,),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      'projectURL'.tr,
                      style: TextStyle(
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10,),
            GestureDetector(
              onTap: ()=>showLicensePage(
                applicationName: 'Sharer',
                applicationVersion: widget.version,
                context: context,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FaIcon(
                    FontAwesomeIcons.certificate,
                    size: 15,
                  ),
                  const SizedBox(width: 5,),
                  Text('license'.tr)
                ],
              )
            ),
            const SizedBox(height: 100,),
          ],
        ),
      ),
    );
  }
}