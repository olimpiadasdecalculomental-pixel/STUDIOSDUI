import 'dart:async';
import 'dart:convert';
import 'dart:io';

class PuenteSupabaseSdui {
  static const String supabaseUrl = 'https://ifjbfvfrfjbvrihphxws.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlmamJmdmZyZmpidnJpaHBoeHdzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA2NjI4NjYsImV4cCI6MjA4NjIzODg2Nn0.s71662-63883-647483';
  static const String idAdmin = 'admin_san_jose';

  // En STUDIOSDUI (APK #2) el esquema activo por defecto es 'esquema2' (Plano de Control),
  // pero permite alternar en vivo a 'esquema3' (Plano de Producción) desde la barra superior.
  static String esquemaActivo = 'esquema2';

  static File _archivoCacheLocal([String? esquema]) {
    final String esq = esquema ?? esquemaActivo;
    return File('${Directory.systemTemp.path}/cache_studio_sdui_$esq.json');
  }

  static Future leerContratoCacheado([String? esquema]) async {
    try {
      final f = _archivoCacheLocal(esquema);
      if (await f.exists()) {
        return jsonDecode(await f.readAsString()) as Map;
      }
    } catch (_) {}
    return null;
  }

  static Future guardarContratoCacheado(Map contrato, [String? esquema]) async {
    try {
      final f = _archivoCacheLocal(esquema);
      await f.writeAsString(jsonEncode(contrato));
    } catch (_) {}
  }

  static Future ejecutarRpcUniversal(
    String nombreRpc,
    Map payload, {
    String? esquemaOverride,
  }) async {
    final String esq = esquemaOverride ?? esquemaActivo;
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 12);
    try {
      final uri = Uri.parse('$supabaseUrl/rest/v1/rpc/$nombreRpc');
      final req = await client.postUrl(uri);
      req.headers.set('apikey', supabaseAnonKey);
      req.headers.set('Authorization', 'Bearer $supabaseAnonKey');
      req.headers.set('Content-Type', 'application/json; charset=utf-8');
      req.headers.set('Accept-Profile', esq);
      req.headers.set('Content-Profile', esq);
      req.add(utf8.encode(jsonEncode(payload)));

      final res = await req.close();
      final body = await res.transform(utf8.decoder).join();
      if (res.statusCode >= 200 && res.statusCode < 300) {
        if (body.isEmpty) return {'exito': true};
        final decoded = jsonDecode(body);
        return decoded is Map ? decoded : {'exito': true, 'datos': decoded};
      }
      return {'exito': false, 'mensaje': 'HTTP ${res.statusCode} ($esq): $body'};
    } catch (e) {
      return {'exito': false, 'mensaje': 'Modo Offline Activo ($esq): $e'};
    } finally {
      client.close();
    }
  }

  static Future sincronizarConNube([String? esquemaOverride]) async {
    final String esq = esquemaOverride ?? esquemaActivo;
    final String rpcVer = esq == 'esquema2'
        ? 'esq2_rpc_verificar_version'
        : 'esq3_rpc_verificar_version';

    final res = await ejecutarRpcUniversal(
      rpcVer,
      {'p_id_admin': idAdmin},
      esquemaOverride: esq,
    );
    if (res['exito'] == true && res['contrato'] is Map) {
      final contrato = Map.from(res['contrato'] as Map);
      await guardarContratoCacheado(contrato, esq);
      return contrato;
    }
    return null;
  }
}