import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'escudo_aislamiento.dart';
import 'puente_supabase_sdui.dart';
import 'modales_candado_y_editor.dart';
import 'despachador_acciones.dart';
import 'inspector_stitch.dart';
import '../microservicios/ms_01_header_y_grids.dart';
import '../microservicios/ms_02_catalogo_y_drag_drop.dart';
import '../microservicios/ms_03_wechat_y_ciencias.dart';
import '../microservicios/ms_04_cine_4dx_y_ar_vr.dart';
import '../microservicios/ms_05_uber_gps_y_binance.dart';
import '../microservicios/ms_06_pizarra_qr_optico.dart';
import '../microservicios/ms_07_kahoot_lumosity_iot.dart';
import '../microservicios/ms_08_cine_cristal_html5.dart';
import '../microservicios/ms_09_tarjeta_neon_base.dart';
import '../microservicios/ms_10_motores_stac_y_jdw.dart';
import '../microservicios/ms_11_stitch_diseno_1_muro.dart';
import '../microservicios/ms_14_studio_prd_rfc_pdf.dart';

class LienzoMaestroSdui extends StatefulWidget {
  const LienzoMaestroSdui({super.key});
  @override
  State createState() => _LienzoMaestroSduiState();
}

class _LienzoMaestroSduiState extends State with WidgetsBindingObserver {
  final PageController _pageCtrl = PageController();
  int _indicePagina = 0;
  bool _esAdmin = true;
  bool _modoStitchEdit = false;
  int _toquesEsquina = 0;
  Timer? _timerToques;
  Timer? _timer4DX;
  bool _modo4DXActivo = false;
  int _episodioCineActual = 0;
  String _modoRealidad = 'VR';
  double _offsetVrX = 0.0;
  bool _arduinoLed1 = true;
  bool _arduinoRele2 = false;
  final Set _celdasLumosity = {0, 4, 8};
  int _xpDuolingo = 120;
  String _feedback = '';
  final Map _estadoForm = {};
  final List _trazosPizarra = [];
  Color _colorLapizActual = const Color(0xFF00FF66);

  Map _contrato = {
    'geometria': {
      'modo_clon_stitch_puro': false,
      'color_fondo': '#071326',
      'color_tarjeta': '#142033',
      'color_primario': '#A9C7FF',
      'color_secundario': '#FBB400',
      'color_terciario': '#00509D',
      'margen_arriba': 34,
      'margen_abajo': 48,
      'margen_izquierda': 0,
      'margen_derecha': 0
    },
    'pestanas': [
      {'id': 'RAIZ', 'titulo': '📘 1. PRD / RFC & PDF', 'visible': true},
      {'id': 'PANTALLA_SANDBOX', 'titulo': '🧪 2. SANDBOX & NODOS', 'visible': true},
      {'id': 'PANTALLA_CODIGO_SQL', 'titulo': '🗄️ 3. CÓDIGO, TABLAS Y RPCS', 'visible': true},
      {'id': 'PANTALLA_VISTA_STITCH', 'titulo': '🎨 4. SIMULADOR STITCH', 'visible': true},
    ],
    'pantallas_json': {
      'RAIZ': [
        {
          'id': 'studio_panel_prd_rfc_completo',
          'visible': true,
          'tipo': 'STUDIO_PRD_RFC_INSPECTOR',
          'titulo': '📘 FÁBRICA DE PRD, RFC, CÓDIGO SQL Y EXPORTADOR PDF'
        }
      ],
      'PANTALLA_SANDBOX': [],
      'PANTALLA_CODIGO_SQL': [],
      'PANTALLA_VISTA_STITCH': [
        {
          'id': 'studio_preview_stitch_5_pantallas',
          'visible': true,
          'tipo': 'STITCH_DISENO_1_EXACTO',
          'header_titulo': 'SAN JOSÉ',
          'header_anio': '1942',
          'header_rango': 'MODO STUDIO ESQ2',
          'header_puntos': '350',
        }
      ]
    }
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    sincronizarContratoSdui();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timerToques?.cancel();
    _timer4DX?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) sincronizarContratoSdui();
  }

  Future sincronizarContratoSdui() async {
    final local = await PuenteSupabaseSdui.leerContratoCacheado();
    if (local != null && mounted) setState(() => _contrato = local);
    final nube = await PuenteSupabaseSdui.sincronizarConNube();
    if (nube != null && mounted) setState(() => _contrato = nube);
  }

  Future _alternarEsquemaEnVivo() async {
    HapticFeedback.heavyImpact();
    final nuevoEsq = PuenteSupabaseSdui.esquemaActivo == 'esquema2' ? 'esquema3' : 'esquema2';
    setState(() {
      PuenteSupabaseSdui.esquemaActivo = nuevoEsq;
      _indicePagina = 0;
      _feedback = '🔄 Conectando en vivo con [$nuevoEsq]...';
    });
    await sincronizarContratoSdui();
    if (mounted) {
      setState(() {
        _feedback = nuevoEsq == 'esquema2'
            ? '🛠️ MODO FÁBRICA STUDIO ACTIVO (esquema2)'
            : '📱 MODO INSPECCIÓN PRODUCCIÓN ACTIVO (esquema3)';
      });
    }
  }

  void _tocarEsquinaCincoVeces() {
    _toquesEsquina++;
    _timerToques?.cancel();
    if (_toquesEsquina >= 5) {
      _toquesEsquina = 0;
      ModalesCandadoYEditor.abrirCandadoNegroCamuflado(
        context: context,
        alDesbloquearAdmin: () async {
          setState(() => _esAdmin = true);
          await sincronizarContratoSdui();
          _abrirEditorJson();
        },
      );
    } else {
      _timerToques = Timer(const Duration(milliseconds: 1800), () => _toquesEsquina = 0);
    }
  }

  void _abrirEditorJson() {
    ModalesCandadoYEditor.abrirModalEditorJson(
      context: context,
      contratoActual: _contrato,
      alActualizarContrato: (nuevo) => setState(() => _contrato = nuevo),
      alMostrarFeedback: (msg) => setState(() => _feedback = msg),
    );
  }

  Future _ejecutarBoton(Map btn, Map bloquePadre) async {
    await DespachadorAccionesSdui.dispararAccion(
      context: context,
      btn: btn,
      bloquePadre: bloquePadre,
      estadoForm: _estadoForm,
      xpDuolingoActual: _xpDuolingo,
      modo4DXActual: _modo4DXActivo,
      onFeedback: (msg) => setState(() => _feedback = msg),
      onXpChanged: (xp) => setState(() => _xpDuolingo = xp),
      on4DXChanged: (activo) {
        _timer4DX?.cancel();
        setState(() => _modo4DXActivo = activo);
        if (activo) _timer4DX = Timer.periodic(const Duration(milliseconds: 900), (_) => HapticFeedback.heavyImpact());
      },
      onAbrirEditorJson: _abrirEditorJson,
      onSincronizar: sincronizarContratoSdui,
    );
  }

  Widget _enrutarMicroservicio(Map b, Map geo, double anchoUtil) {
    final tipo = b['tipo']?.toString() ?? 'TARJETA_NEON';
    final idMod = b['id']?.toString() ?? tipo;
    return ejecutarConEscudoMicroservicio(idMod, () {
      switch (tipo) {
        case 'STUDIO_PRD_RFC_INSPECTOR':
          return Ms14StudioPrdRfcPdf(
            bloque: b,
            onFeedback: (m) => setState(() => _feedback = m),
            onSincronizar: sincronizarContratoSdui,
          );
        case 'STITCH_DISENO_1_EXACTO':
          return SizedBox(height: 820, child: Ms11StitchDiseno1Muro(bloque: b));
        case 'STAC_STITCH':
          return Ms10MotoresStacYJdw.construirMotorStacStitch(b: b, anchoPantalla: anchoUtil, onDispararBoton: _ejecutarBoton);
        case 'JSON_DYNAMIC_HIBRIDO':
          return Ms10MotoresStacYJdw.construirMotorJsonDynamicHibrido(
            b: b,
            constructorMotorNativoPorNombre: (configNativo) => _enrutarMicroservicio(configNativo, geo, anchoUtil),
            onDispararBoton: _ejecutarBoton,
          );
        case 'HEADER_IMPERIO':
          return Ms01HeaderYGrids.construirHeaderImperio(b);
        case 'GRID_ICONOS_4_COL':
          return Ms01HeaderYGrids.construirGridIconos4Col(b: b, anchoPantalla: anchoUtil, onDispararBoton: _ejecutarBoton, onFeedback: (m) => setState(() => _feedback = m));
        case 'GRID_TARJETAS_2_COL':
          return Ms02CatalogoYDragDrop.construirGridTarjetas2Col(b: b, anchoPantalla: anchoUtil, onFeedback: (m) => setState(() => _feedback = m));
        case 'DRAG_AND_DROP_LISTA':
          return Ms02CatalogoYDragDrop.construirDragAndDropLista(b: b, onFeedback: (m) => setState(() => _feedback = m), onRefrescarUi: () => setState(() {}));
        case 'CHAT_WECHAT_P2P':
          return Ms03WechatYCiencias.construirChatWechatP2P(b: b, estadoForm: _estadoForm, onDispararBoton: _ejecutarBoton);
        case 'LAB_CIENCIAS_MATEMATICAS':
          return Ms03WechatYCiencias.construirLabCiencias(b: b, onFeedback: (m) => setState(() => _feedback = m));
        case 'VISOR_AR_VR_360':
          return Ms04Cine4dxYArVr.construirVisorArVr360(
            b: b, modoRealidad: _modoRealidad, offsetVrX: _offsetVrX,
            onDragVrX: (dx) => setState(() => _offsetVrX = (_offsetVrX + dx).clamp(-80.0, 80.0)),
            onCambiarModo: (m) => setState(() => _modoRealidad = m),
            onGuardarOffline: () => _ejecutarBoton({'accion': 'DESCARGAR_VIDEO_OFFLINE'}, b),
          );
        case 'UBER_MAPA_RADAR_GPS':
          return Ms05UberGpsYBinance.construirUberMapaRadarGps(b);
        case 'BINANCE_CRIPTO_TRADING':
          return Ms05UberGpsYBinance.construirBinanceCriptoTrading(b);
        case 'PIZARRA_TACTIL_SVG':
        case 'PIZARRA_TACTIL_DIBUJO':
          return Ms06PizarraQrOptico.construirPizarraTactil(
            b: b, trazosPizarra: _trazosPizarra, colorLapizActual: _colorLapizActual,
            onCambiarColor: (col) => setState(() => _colorLapizActual = col),
            onLimpiar: () => setState(() => _trazosPizarra.clear()),
            onIniciarTrazo: (pos) => setState(() => _trazosPizarra.add([pos])),
            onActualizarTrazo: (pos) => setState(() => (_trazosPizarra.last as List).add(pos)),
          );
        case 'MOTOR_JUEGO_COGNITIVO':
          return Ms07KahootLumosityIot.construirMotorJuegoCognitivo(
            b: b, anchoPantalla: anchoUtil, celdasLumosity: _celdasLumosity, arduinoLed1: _arduinoLed1, arduinoRele2: _arduinoRele2,
            onFeedback: (m) => setState(() => _feedback = m),
            onToggleLumosity: (idx) => setState(() {
              _celdasLumosity.contains(idx) ? _celdasLumosity.remove(idx) : _celdasLumosity.add(idx);
              if (_celdasLumosity.length == 5) _feedback = '⚡ ¡PATRÓN LUMOSITY COMPLETADO! Velocidad cognitiva +25 XP';
            }),
            onToggleArduinoLed: (v) => setState(() { _arduinoLed1 = v; _feedback = v ? '🔵 Arduino Pin 13 ENCENDIDO (HIGH)' : '⚪ Arduino Pin 13 APAGADO (LOW)'; }),
            onToggleArduinoRele: (v) => setState(() { _arduinoRele2 = v; _feedback = v ? '📡 Relé IoT MQTT ACTIVADO' : '📡 Relé IoT MQTT DESACTIVADO'; }),
            onDispararBoton: _ejecutarBoton,
          );
        case 'LIENZO_WEBAR_HTML5':
          return Ms08CineCristalHtml5.construirCineCristalHtml5(
            b: b, episodioActual: _episodioCineActual, anchoPantalla: anchoUtil,
            onCambiarEpisodio: (ep) => setState(() { _episodioCineActual = ep; _feedback = '🎬 Reproduciendo Ep. ${ep + 1} en Cristal Orbe TV'; }),
            onDispararBoton: _ejecutarBoton,
          );
        default:
          return Ms09TarjetaNeonBase.construirTarjetaNeonBase(
            b: b, anchoPantalla: anchoUtil, estadoForm: _estadoForm,
            onActualizarCampo: (k, v) => setState(() => _estadoForm[k] = v),
            onDispararBoton: _ejecutarBoton,
          );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final geo = Map.from((_contrato['geometria'] as Map?) ?? {});
    final listaPestanas = ((_contrato['pestanas'] as List?) ?? []).where((p) {
      final mp = Map.from(p as Map);
      if (mp['visible'] == false) return false;
      if (mp['rol_permitido'] == 'superadmin' && !_esAdmin) return false;
      return true;
    }).toList();
    final pantallasMap = Map.from((_contrato['pantallas_json'] as Map?) ?? {});
    final bool enEsq2 = PuenteSupabaseSdui.esquemaActivo == 'esquema2';

    return Scaffold(
      backgroundColor: hexAColor(geo['color_fondo']?.toString(), const Color(0xFF071326)),
      body: LayoutBuilder(
        builder: (ctx, constraints) {
          final double anchoUtil = math.max(300.0, constraints.maxWidth);
          return Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 4,
                  bottom: MediaQuery.of(context).padding.bottom + 8,
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF030E21),
                        border: Border(bottom: BorderSide(color: Color(0xFF295186))),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(listaPestanas.length, (idx) {
                                  final p = Map.from(listaPestanas[idx] as Map);
                                  final activa = _indicePagina == idx;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: InkWell(
                                      onTap: () {
                                        setState(() => _indicePagina = idx);
                                        _pageCtrl.animateToPage(idx, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: activa ? const Color(0xFFFBB400) : const Color(0xFF142033),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: activa ? Colors.white : const Color(0xFF2A3549)),
                                        ),
                                        child: Text(
                                          p['titulo']?.toString() ?? p['id'].toString(),
                                          style: TextStyle(
                                            color: activa ? const Color(0xFF071326) : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10.5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: _alternarEsquemaEnVivo,
                            child: Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: enEsq2 ? const Color(0xFF00509D) : const Color(0xFF00C853),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFFBB400)),
                              ),
                              child: Text(
                                enEsq2 ? '🛠️ ESQ2' : '📱 ESQ3',
                                style: TextStyle(
                                  color: enEsq2 ? Colors.white : const Color(0xFF071326),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              DespachadorAccionesSdui.generarYMostrarLibroPdfMaestro(
                                context: context,
                                tituloPdf: 'Libro Maestro PRD + RFC + SQL + Tablas (Esquema 2 y 3)',
                                itemsExtra: const [],
                                onFeedback: (m) => setState(() => _feedback = m),
                              );
                            },
                            child: Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFF00C853), borderRadius: BorderRadius.circular(12)),
                              child: const Text('📄 PDF', style: TextStyle(color: Color(0xFF071326), fontSize: 10, fontWeight: FontWeight.w900)),
                            ),
                          ),
                          InkWell(
                            onTap: _abrirEditorJson,
                            child: Container(
                              margin: const EdgeInsets.only(left: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(12)),
                              child: const Text('{ }', style: TextStyle(color: Colors.black, fontSize: 10.5, fontWeight: FontWeight.w900)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_feedback.isNotEmpty)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF142033),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFBB400)),
                        ),
                        child: Text(
                          _feedback,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFFFFD795), fontWeight: FontWeight.bold, fontSize: 11.5),
                        ),
                      ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageCtrl,
                        itemCount: listaPestanas.length,
                        onPageChanged: (idx) => setState(() => _indicePagina = idx),
                        itemBuilder: (ctx, idx) {
                          final p = Map.from(listaPestanas[idx] as Map);
                          final String idPant = p['id'].toString();
                          final List bloquesVisibles = List.from(((pantallasMap[idPant] as List?) ?? []).where((b) => (b as Map)['visible'] != false));

                          return ListView(
                            padding: const EdgeInsets.all(10),
                            children: List.generate(bloquesVisibles.length, (bIdx) {
                              final Map bloqueMap = Map.from(bloquesVisibles[bIdx] as Map);
                              return InspectorStitchSdui.envolverConMarcoStitch(
                                modoEditActivo: _modoStitchEdit,
                                bloque: bloqueMap,
                                indice: bIdx,
                                totalBloques: bloquesVisibles.length,
                                child: _enrutarMicroservicio(bloqueMap, geo, anchoUtil),
                                onZoomInspeccionar: () {},
                                onSubirLugar: () {},
                                onBajarLugar: () {},
                                onQuitarComponente: () {},
                              );
                            }),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _tocarEsquinaCincoVeces,
                  child: const SizedBox(width: 60, height: 45),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}