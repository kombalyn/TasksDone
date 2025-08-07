// ignore_for_file: avoid_print, file_names, deprecated_member_use, avoid_unnecessary_containers
//viewhome2 - Firebase integration
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

// Firebase imports
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

// Firebase service class
class TemakorService {
  final databaseRef = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://lumeei-test-default-rtdb.europe-west1.firebasedatabase.app',
  ).ref();

  Future<Map<String, dynamic>> fetchTemakorok() async {
    final snapshot = await databaseRef.child('Video_hang_DB').get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    } else {
      throw Exception('A temakorok nem található');
    }
  }
}

class ViewHome2 extends GetxController {
  late List<List<String>> parsedList;

  List<Channel> get catindex => _catindex;
  final List<Channel> _catindex = [];

  // Completers for async operations
  Completer<void> completer_1 = Completer<void>();
  Completer<void> completer_2 = Completer<void>();
  Completer<void> completer_3 = Completer<void>();

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
            videoId: movis[i]["video_id"],
          ),
        );
      }

      // print(moviesSlider.length);
    } else {
      print("eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee");
    }

    update();
  }

  List movis = [];

  // Updated moviesHomeapp method with Firebase integration
  Future moviesHomeapp() async {
    final temakorService = TemakorService();
    temakorService
        .fetchTemakorok()
        .then((data) {
          final temakorMap = Map<String, dynamic>.from(data);
          final LongMap = Map<String, dynamic>.from(temakorMap['long']);

          final elemekLista = List<Map<String, dynamic>>.from(
            (LongMap['Matematika'] as Map)['5'].map(
              (e) => Map<String, dynamic>.from(e),
            ),
          );

          final modulId = elemekLista[0]['id'];
          print('modulId');
          print(modulId);
          print('modulId típusa: ${modulId.runtimeType}');
          print('Temakorok adatok: $data');

          for (int i = 0; i < elemekLista.length; i++) {
            _movieshome.add(
              Posts(
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
          completer_1.complete();
        })
        .catchError((error) {
          print('Hiba a temakorok beolvasásakor: $error');
        });
  }

  // Updated lastChHome method with Firebase integration
  Future lastChHome() async {
    final temakorService = TemakorService();
    temakorService
        .fetchTemakorok()
        .then((data) {
          final temakorMap = Map<String, dynamic>.from(data);

          // Use 'hang' section instead of 'long' for different content
          final hangMap = Map<String, dynamic>.from(temakorMap['hang']);

          final elemekLista = List<Map<String, dynamic>>.from(
            (hangMap['Történelem'] as Map)['5'] // Different grade level
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

  // Updated seriesHome method with Firebase integration
  Future seriesHome() async {
    final temakorService = TemakorService();
    temakorService
        .fetchTemakorok()
        .then((data) {
          final temakorMap = Map<String, dynamic>.from(data);
          final LongMap = Map<String, dynamic>.from(temakorMap['long']);

          final elemekLista = List<Map<String, dynamic>>.from(
            (LongMap['Történelem'] as Map)['5'].map(
              (e) => Map<String, dynamic>.from(e),
            ),
          );

          final modulId = elemekLista[0]['id'];
          print('modulId');
          print(modulId);
          print('modulId típusa: ${modulId.runtimeType}');
          print('Temakorok adatok: $data');

          for (int i = 0; i < elemekLista.length; i++) {
            _series.add(
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
          completer_3.complete();
        })
        .catchError((error) {
          print('Hiba a temakorok beolvasásakor: $error');
        });
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

  static launchWebVideoCasttt(
    String url,
    String? mime,
    Map<String, dynamic>? args,
  ) {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        package: 'com.instantbits.cast.webvideo',
        type: mime ?? MIME.applicationXMpegURL,
        action: 'action_view',
        data: Uri.parse(url).toString(),
        arguments: args,
        flags: <int>[
          Flag.FLAG_ACTIVITY_NEW_TASK,
          Flag.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
        ],
      );

      intent.launch();
    }
  }

  void checkVLCInstallation2(String url) async {
    bool isMXInstalled = await DeviceApps.isAppInstalled(
      "com.instantbits.cast.webvideo",
    );
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
        ),
      );
    }
    update();
  }
}

