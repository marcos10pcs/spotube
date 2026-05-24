import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:spotube/services/kv_store/kv_store.dart';
import 'package:spotube/utils/platform.dart';
import 'package:yt_dlp_dart/yt_dlp_dart.dart';
import 'package:spotube/models/database/database.dart';

class YtDlpDownloader {
  static const String ytDlpUrl =
      "https://github.com/yt-dlp/yt-dlp/releases/download/2026.03.17/yt-dlp_x86.exe";

  static Future<void> ensureInitialized() async {
    if (!kIsWindows) return;

    final supportDir = await getApplicationSupportDirectory();
    final ytDlpDir = Directory(p.join(supportDir.path, "bin"));

    if (!await ytDlpDir.exists()) {
      await ytDlpDir.create(recursive: true);
    }

    final ytDlpPath = p.join(ytDlpDir.path, "yt-dlp.exe");
    final file = File(ytDlpPath);

    if (!await file.exists()) {
      print("Baixando yt-dlp...");
      try {
        final dio = Dio();
        await dio.download(ytDlpUrl, ytDlpPath);
        print("yt-dlp baixado com sucesso em: $ytDlpPath");
      } catch (e) {
        print("Erro ao baixar yt-dlp: $e");
        return;
      }
    }

    // Configura o caminho no engine
    await YtDlp.instance.setBinaryLocation(ytDlpPath);
    // Salva no KVStore para que o app saiba onde está
    await KVStoreService.setYoutubeEnginePath(YoutubeClientEngine.ytDlp, ytDlpPath);
  }
}
