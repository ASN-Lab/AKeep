import 'package:hive/hive.dart';

class HiveService {
  static const String assetBox = 'assets';
  static const String queueBox = 'sync_queue';

  static Future<void> init() async {
    await Hive.openBox(assetBox);
    await Hive.openBox(queueBox);
  }

  static Box get assets => Hive.box(assetBox);
  static Box get queue => Hive.box(queueBox);
}
