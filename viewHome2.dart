// ignore_for_file: avoid_print, file_names, deprecated_member_use, avoid_unnecessary_containers

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:apptvshow/constant.dart';
import 'package:apptvshow/model/modelMovies.dart';
import 'package:apptvshow/model/modelch.dart';
import 'package:apptvshow/screen/tvShow.dart';
import 'package:apptvshow/videoplayer/flag.dart';
import 'package:apptvshow/videoplayer/intent.dart';
import 'package:device_apps/device_apps.dart';
import 'package:external_video_player_launcher/external_video_player_launcher.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ViewHome2 extends GetxController {
  late List<List<String>> parsedList;
  late WebSocketChannel _channel = WebSocketChannel.connect(
    //Uri.parse('ws://34.72.67.6:8089'),
    Uri.parse('ws://104.155.99.100:8089'),
  );
  List<Channel> get catindex => _catindex;
  final List<Channel> _catindex = [];
  // Létrehozunk egy Completert
  Completer<void> completer_1 = Completer<void>();


  List<Posts> get moviesSlider => _moviesSlider;
  final List<Posts> _moviesSlider = [];

  List<Posts> get movieshome => _movieshome;
  final List<Posts> _movieshome = [];

  List<Channel> get lastch => _lastch;
  final List<Channel> _lastch = [];
  List<Channel> get series => _series;
  final List<Channel> _series = [];

  Future sliderhome() async {
    var url = Uri.parse('$UrlApp$getmovies$count2$apikey');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List movis = [];
      movis.addAll(data["posts"]);

      for (int i = 0; i < movis.length; i++) {
        _moviesSlider.add(
          Posts(
              categoryId: movis[i]["category_id"],
              categoryName: movis[i]["category_name"],
              channelDescription: movis[i]["channel_description"],
              channelId: movis[i]["channel_id"],
              channelName: movis[i]["channel_name"],
              channelImage: movis[i]["channel_image"],
              channelType: movis[i]["channel_type"],
              channelUrl: movis[i]["channel_url"],
              userAgent: movis[i]["user_agent"],
              videoId: movis[i]["video_id"]),
        );
      }

      // print(moviesSlider.length);
    } else {
      print("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
    }

    update();
  }

  List movis = [];
  Future moviesHomeapp() async {
    _channel = WebSocketChannel.connect(
      //Uri.parse('ws://34.72.67.6:8089'),
      Uri.parse('ws://104.155.99.100:8089'),
    );
    //kerdes = "catimages|mindegymivanitt";
    _channel.sink.add("catitem|51");
    print("AWEBSOCKET RESULT Received message AA");
    _channel.stream.listen(
          (message) {
        print(message);
        // A lista kinyerése a message stringből
        // A zárójelek szögletes zárójelekre cserélése
        String modifiedMessage = message.replaceAll('(', '[').replaceAll(')', ']');

        // Az egyes idézőjelek cseréje dupla idézőjelekre
        modifiedMessage = modifiedMessage.replaceAll("'", '"');

        // A lista kinyerése és listák listájává alakítása dinamikus típusokkal
        List<dynamic> parsedDynamicList = jsonDecode(modifiedMessage);

        // Minden belső lista átkonvertálása List<String>-gé
        parsedList = parsedDynamicList.map((dynamic innerList) {
          return List<String>.from(innerList);
        }).toList();

        print('WEBSOCKET RESULT Received message AA: $message');
        print(parsedList);



        for (int i = 0; i < parsedList.length; i++) {
          _movieshome.add(
            Posts(
                categoryId: 2,//ch[i]["category_id"],
                categoryName: parsedList[i][4],//ch[i]["category_name"],
                channelDescription: parsedList[i][5],
                channelId: 2,
                channelName: parsedList[i][0],//ch[i]["channel_name"],
                channelImage: parsedList[i][1],//"https://storage.googleapis.com/lomeeibucket/krumplielem.jpg",
                channelType: "Matek",
                channelUrl: parsedList[i][1],
                userAgent: "ali",
                videoId: parsedList[i][3]),
          );
        }


        update();

        completer_1.complete();

        _channel.sink.close();
      },
      onDone: () {
        print('WebSocket channel closed');
      },
      onError: (error) {
        print('WebSocket server not found');
      },
    );

    /*
    var url = Uri.parse('$UrlApp$getmovies$count3$apikey');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      movis.addAll(data["posts"]);
      movis.shuffle();

      for (int i = 0; i < movis.length; i++) {
        _movieshome.add(
          Posts(
              categoryId: movis[i]["category_id"],
              categoryName: movis[i]["category_name"],
              channelDescription: movis[i]["channel_description"],
              channelId: movis[i]["channel_id"],
              channelName: movis[i]["channel_name"],
              channelImage: movis[i]["channel_image"],
              channelType: movis[i]["channel_type"],
              channelUrl: movis[i]["channel_url"],
              userAgent: movis[i]["user_agent"],
              videoId: movis[i]["video_id"]),
        );
      }

      // print(movis.length);

      // print("==========================Home");
    } else {
      print("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
    }

    print(_movieshome.length);

    update();

     */
  }

  /////
  Future lastChHome() async {
    final temakorService = TemakorService();
    temakorService
        .fetchTemakorok()
        .then((data) {
          final temakorMap = Map<String, dynamic>.from(data);

          // Use 'hang' section instead of 'long' for different content
          final hangMap = Map<String, dynamic>.from(temakorMap['hang']);

          final elemekLista = List<Map<String, dynamic>>.from(
            (hangMap['Irodalom'] as Map)['6'] // Different grade level
                .map((e) => Map<String, dynamic>.from(e)),
          );

          final modulId = elemekLista[0]['id'];
          print('lastChHome modulId: $modulId');

          for (int i = 0; i < elemekLista.length; i++) {
            _lastch.add(
              Channel(
                categoryId: 2,
                categoryName: elemekLista[i]['chapter'],
                channelDescription: elemekLista[i]['description'],
                channelId: i,
                channelName: elemekLista[i]['title'],
                channelImage: elemekLista[i]['picture_URL'],
                channelType: modulId,
                channelUrl: elemekLista[i]['picture_URL'],
                userAgent: "ali",
                videoId: elemekLista[i]['video_URL'],
              ),
            );
          }

          update();
          completer_2.complete();
        })
        .catchError((error) {
          print('Hiba a lastChHome beolvasásakor: $error');
        });
  }

    /*
    var url = Uri.parse('$UrlApp$gettvshow$count3$apikey');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List ch = [];
      ch.addAll(data["posts"]);
      // movis.shuffle();

      for (int i = 0; i < ch.length; i++) {
        _lastch.add(
          Channel(
              categoryId: ch[i]["category_id"],
              categoryName: ch[i]["category_name"],
              channelDescription: ch[i]["channel_description"],
              channelId: ch[i]["channel_id"],
              channelName: ch[i]["channel_name"],
              channelImage: "https://storage.googleapis.com/lomeeibucket/krumplielem.jpg",
              channelType: ch[i]["channel_type"],
              channelUrl: "https://storage.googleapis.com/lomeeibucket/transzformator.jpg",//ch[i]["channel_url"],
              userAgent: ch[i]["user_agent"],
              videoId: ch[i]["video_id"]),
        );
      }

      // print(lastch.length);

      print("==========================");
      // print("$UrlApp$gettvshow$count3$apikey");
    } else {
      // print("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
    }

     */


  }

  Future seriesHome() async {
    var url = Uri.parse('$UrlApp$gettvseries$count3$apikey');

    var response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List ch = [];
      ch.addAll(data["posts"]);
      // movis.shuffle();

      for (int i = 0; i < ch.length; i++) {
        _series.add(
          Channel(
              categoryId: 2,//ch[i]["category_id"],
              categoryName: parsedList[i][4],//ch[i]["category_name"],
              channelDescription: parsedList[i][5],
              channelId: 2,
              channelName: parsedList[i][0],//ch[i]["channel_name"],
              channelImage: parsedList[i][1],//"https://storage.googleapis.com/lomeeibucket/krumplielem.jpg",
              channelType: "Matek",
              channelUrl: parsedList[i][1],
              userAgent: "ali",
              videoId: parsedList[i][3]),
        );
      }

      // print(lastch.length);

      print("==========================");
      // print("$UrlApp$gettvshow$count3$apikey");
    } else {
      // print("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
    }

    update();
  }

  bool? get asd => _asd;
  bool? _asd;

  getdata(String topic) async {
    //  للاشعارات للتحقق من اختيار المستخدام
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getBool('ahmed') == null) {
      _asd = true;
      if (_asd == true) {
        FirebaseMessaging.instance.subscribeToTopic(topic);
      } else {
        FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      }
    } else {
      _asd = pref.getBool('ahmed')!;
      if (_asd == true) {
        FirebaseMessaging.instance.subscribeToTopic(topic);
      } else {
        FirebaseMessaging.instance.unsubscribeFromTopic(topic);
      }
    }

    update();
  }

  // bool? get s => _s;
  // bool? _s;
  // internet() async {
  //   var url = Uri.parse('https://www.google.com/');

  //   var response = await http.get(url);

  //   if (response.statusCode == 200) {
  //     return Get.to(MyApp1());
  //   } else {
  //     return Get.to(InterNetApp());
  //   }
  // }
  // getdatachek() async {
  //   SharedPreferences pref = await SharedPreferences.getInstance();

  //   not = pref.getBool('ahmed')!;
  //   update();
  //   return not;
  // }
  static launchWebVideoCasttt(
      String url, String? mime, Map<String, dynamic>? args) {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        package: 'com.instantbits.cast.webvideo',
        type: mime ?? MIME.applicationXMpegURL,
        action: 'action_view',
        data: Uri.parse(url).toString(),
        arguments: args,
        flags: <int>[
          Flag.FLAG_ACTIVITY_NEW_TASK,
          Flag.FLAG_GRANT_PERSISTABLE_URI_PERMISSION
        ],
      );

      intent.launch();
    }
  }

  void checkVLCInstallation2(
      String url,
      ) async {
    bool isMXInstalled =
    await DeviceApps.isAppInstalled("com.instantbits.cast.webvideo");
    if (isMXInstalled) {
      print('webvideo is installed on the device!');
      launchWebVideoCasttt(url, MIME.applicationMp4, {});

      // start = true;
      lisner = true;
    } else {
      print('Web Video Cast is not installed on the device!');
      Get.defaultDialog(
          title:
          "Web Video Cast is not installed on the device! \n install the application",
          content: Container(
            // height: 100,
            // width: 100,
            // color: Colors.red,
            child: MaterialButton(
              color: Colors.yellow,
              textColor: Colors.black,
              onPressed: () async {
                // var url = Uri.parse(appcast);

                await launch(appcast);
                // await launchUrl(url, mode: LaunchMode.externalApplication);
                // await launchUrlString(appcast);
              },
              child: const Text("install App"),
            ),
          ));
    }
    update();
  }
}
