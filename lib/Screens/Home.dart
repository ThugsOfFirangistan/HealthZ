import 'package:flutter/material.dart';
import 'package:healthz/Models/newsmodel.dart';
import 'package:healthz/Screens/Donate.dart';
import 'package:healthz/Services/news.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ArtContent> articles;
  @override
  void initState() {
    super.initState();
    initialise();
  }

  void initialise() async {
    List<ArtContent> _temp = await News().getNews();
    print(_temp);
    setState(() {
      articles = _temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return articles != null
        ? Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: Text(
                'Home',
                style: TextStyle(color: Colors.black),
              ),
              leading: IconButton(
                icon: const Icon(Icons.monetization_on),
                onPressed: () { 
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Donate()));
                            
                },
              ),
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.error, color: Colors.red),
                  onPressed: () => launch("tel://+91-11-23978046"),
                ),
                SizedBox(width: 20,)
              ],
              centerTitle: true,
              backgroundColor: Colors.white,
              iconTheme: IconThemeData(color: Colors.black),
              elevation: 0.0,
            ),
            body: Column(
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    itemCount: articles.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: GestureDetector(
                              onTap: () => {launchUrl(articles[index].newsUrl)},
                              child: Card(
                                  semanticContainer: true,
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  child: Stack(
                                    children: <Widget>[
                                      Image.network(
                                          articles[index].newsimage.toString(),
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              40,
                                          color: Color.fromRGBO(
                                              255, 255, 255, 0.6),
                                          colorBlendMode: BlendMode.modulate),
                                      Positioned.fill(
                                          child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 15, horizontal: 5),
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Text(articles[index].title,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 15)),
                                        ),
                                      ))
                                    ],
                                  ))));
                    },
                  ),
                )
              ],
            ))
        : Scaffold(
            body: Center(
              child: Image(
                image: new AssetImage("assets/images/loader.gif"),
                height: 100,
                width: 100,
              ),
            ),
          );
  }
}

void launchUrl(url) async {
  print(url);
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}
