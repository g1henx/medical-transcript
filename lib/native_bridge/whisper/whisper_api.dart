/* <!-- START LICENSE -->


Program Ini Di buat Oleh DEVELOPER Dari PERUSAHAAN GLOBAL CORPORATION
Social Media:

- Youtube: https://youtube.com/@Global_Corporation
- Github: https://github.com/globalcorporation
- TELEGRAM: https://t.me/GLOBAL_CORP_ORG_BOT

Seluruh kode disini di buat 100% murni tanpa jiplak / mencuri kode lain jika ada akan ada link komment di baris code

Jika anda mau mengedit pastikan kredit ini tidak di hapus / di ganti!

Jika Program ini milik anda dari hasil beli jasa developer di (Global Corporation / apapun itu dari turunan itu jika ada kesalahan / bug / ingin update segera lapor ke sub)

Misal anda beli Beli source code di Slebew CORPORATION anda lapor dahulu di slebew jangan lapor di GLOBAL CORPORATION!

Jika ada kendala program ini (Pastikan sebelum deal project tidak ada negosiasi harga)
Karena jika ada negosiasi harga kemungkinan

1. Software Ada yang di kurangin
2. Informasi tidak lengkap
3. Bantuan Tidak Bisa remote / full time (Ada jeda)

Sebelum program ini sampai ke pembeli developer kami sudah melakukan testing

jadi sebelum nego kami sudah melakukan berbagai konsekuensi jika nego tidak sesuai ?
Bukan maksud kami menipu itu karena harga yang sudah di kalkulasi + bantuan tiba tiba di potong akhirnya bantuan / software kadang tidak lengkap


<!-- END LICENSE --> */
// ignore_for_file: non_constant_identifier_names, unnecessary_string_interpolations

import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';
import 'package:medical_transcript/native_bridge/whisper/scheme/whisper_response.dart';
import 'package:medical_transcript/native_bridge/whisper/whisper_request.dart';
import 'package:universal_io/io.dart';
import 'package:ffi/ffi.dart';
import "./api/api.dart" as whisper_api;
import "./scheme/scheme.dart" as whisper_scheme;
// ignore: camel_case_types
typedef whisper_request_native = Pointer<Utf8> Function(Pointer<Utf8> body);

class Whisper {
  String whisper_lib = "libwhisper.so";
  Whisper({
    String? whisperLib,
  }) {
    if (whisperLib != null) {
      whisper_lib = whisperLib;
    }
  }

  DynamicLibrary openLib({
    String? whisperLib,
  }) {
    whisperLib ??= whisper_lib;
    if (Platform.isIOS || Platform.isMacOS) {
      return DynamicLibrary.open(whisperLib);
    } else {
      return DynamicLibrary.open(whisperLib);
    }
  }

  Future<WhisperResponse> request({
    required WhisperRequest whisperRequest,
    String? whisperLib,
  }) async {
    whisperLib ??= whisper_lib;
    Map result = await Isolate.run(() async {
      Pointer<Utf8> data = whisperRequest.toString().toNativeUtf8();
      var res = openLib(whisperLib: whisperLib)
          .lookupFunction<whisper_request_native, whisper_request_native>(
          "request")
          .call(data);
      Map result = json.decode(res.toDartString());
      malloc.free(data);
      return result;
    });
    return WhisperResponse(result);
  }

  Future<whisper_scheme.Transcribe> transcribe({
    required String audio,
    required String model,
    bool is_translate = false,
    int threads = 6,
    bool is_verbose = false,
    String language = "id",
    bool is_special_tokens = false,
    bool is_no_timestamps = false,
    String? whisperLib,
    int n_processors = 1,
    bool split_on_word = false,
    bool no_fallback = false,
    bool diarize = false,
    bool speed_up = false,
    String prompt = "",
  }) async {
    // whisperLib ??= whisper_lib;
    WhisperResponse result = await request(
      whisperRequest: WhisperRequest(
        whisper_api.GetTextFromWavFile.create(
          special_type: "getTextFromWavFile",
          audio: audio,
          model: model,
          is_no_timestamps: is_no_timestamps,
          is_special_tokens: is_special_tokens,
          is_translate: is_translate,
          is_verbose: is_verbose,
          language: language,
          threads: threads,
          n_processors: n_processors,
          split_on_word: split_on_word,
          no_fallback: no_fallback,
          diarize: diarize,
          speed_up: speed_up,
          prompt: prompt,
        ).toJson(),
      ),
      whisperLib: whisperLib,
    );
    print(result.toJson());
    return whisper_scheme.Transcribe(result.toJson());
  }
  Future<void> load({
    required String model,
  }) async {
    // whisperLib ??= whisper_lib;
    WhisperResponse result = await request(
      whisperRequest: WhisperRequest(
          {"@type": "loadModel",
            "model": model}
      ),
      whisperLib: whisper_lib,
    );
    print(result.rawData.toString());
    return;
  }
  Future<void> unload() async {
    // whisperLib ??= whisper_lib;
    WhisperResponse result = await request(
      whisperRequest: WhisperRequest(
          {"@type": "unloadModel"}
      ),
      whisperLib: whisper_lib,
    );
    print(result.rawData.toString());
    return;
  }
  Future<whisper_scheme.Version> getVersion({
    String? whisperLib,
  }) async {
    // whisperLib ??= whisper_lib;
    WhisperResponse result = await request(
      whisperRequest: WhisperRequest(
        whisper_api.GetVersion.create(
          special_type: "getVersion",
        ).toJson(),
      ),
      whisperLib: whisperLib,
    );
    return whisper_scheme.Version(result.toJson());
  }
}
