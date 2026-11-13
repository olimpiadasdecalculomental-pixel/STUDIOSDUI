import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../nucleo/puente_supabase_sdui.dart';
import '../nucleo/despachador_acciones.dart';

class Ms14StudioPrdRfcPdf extends StatefulWidget {
  final Map bloque;
  final Function(String) onFeedback;
  final Future Function() onSincronizar;

  const Ms14StudioPrdRfcPdf({
    super.key,
    required this.bloque,
    required this.onFeedback,
    required this.onSincronizar,
  });

  @override
  State createState() => _Ms14StudioPrdRfcPdfState();
}

class _Ms14StudioPrdRfcPdfState extends State {
  int _subTab = 0; // 0=PRD/RFC, 1=Constructor IF/FOR/RPC, 2=ADN Tablas/Botones, 3=Prompt IA y PDF
  int _idxProyecto = 0;
  bool _temaWireframe = false;

  final TextEditingController _ctrlIdAccion = TextEditingController(text: 'ACCION_BLINDAR_BOVEDA_PIN_REAL');
  final TextEditingController _ctrlPantalla = TextEditingController(text: 'RAIZ');
  final TextEditingController _ctrlPregunta1Trigger = TextEditingController(
    text: 'Usuario toca el botón "Blindar Bóveda Ahora" en Pantalla Bóveda QR',
  );
  final TextEditingController _ctrlPregunta2CondicionIf = TextEditingController(
    text: 'LENGTH(v_pin) = 4 AND LENGTH(v_apodo) >= 3',
  );
  final TextEditingController _ctrlPregunta3AccionSql = TextEditingController(
    text: "INSERT INTO esquema3.usuarios_estado (id_usuario, id_admin, rol, descripcion_registro_texto, memoria_datos, updated_at)\n"
        "VALUES (v_apodo, 'admin_san_jose', 'SOCIO_REGISTRADO', 'Bóveda blindada', jsonb_build_object('pin', v_pin, 'puntos', 480), NOW())\n"
        "ON CONFLICT (id_usuario) DO UPDATE SET rol = 'SOCIO_REGISTRADO', memoria_datos = EXCLUDED.memoria_datos, updated_at = NOW();",
  );
  final TextEditingController _ctrlMensajeOk = TextEditingController(
    text: '🔒 ¡Bóveda blindada en Esquema 3 con PIN de 4 dígitos (480 pts protegidos)!',
  );

  List _tablasDetectadas = [
    'esquema2.proyectos_prd_rfc ➔ id_proyecto, nombre_app, estado_fase, prd_objetivo, rfc_diagrama_mermaid',
    'esquema2.sandbox_datos_prueba ➔ id_simulador, nombre_entidad, tipo_modelo, registros_simulados',
    'esquema2.nodos_logica_visual ➔ id_nodo, tipo_bloque, config_nodo, sql_dinamico_generado',
    'esquema2.mapeo_wireframe_stitch ➔ id_mapeo, tema_activo, componente_generico, componente_stitch_esq3',
    'esquema2.mensajes_sistema_vivo ➔ codigo_mensaje, texto_wireframe_debug, texto_stitch_final',
    'esquema3.apps_master ➔ id_admin, version_numero, config_geometria, contrato_actual_json',
    'esquema3.sdui_pantallas ➔ id_pantalla, titulo_pestana, esta_bloqueada, componentes_json',
    'esquema3.sdl_logica_acciones ➔ id_accion, pantalla_origen, ux_ui_boton_disparador, codigo_ejecucion',
    'esquema3.usuarios_estado ➔ id_usuario, rol, descripcion_registro_texto, memoria_datos',
    'esquema3.inventario_premios ➔ id_premio, titulo_premio, dueno_usuario_id, estado_qr',
  ];
  List _rpcsDetectados = [
    'esquema2.esq2_rpc_obtener_mapa_completo_bd() ➔ jsonb',
    'esquema2.esq2_rpc_publicar_logica_en_esq3() ➔ jsonb',
    'esquema2.fn_publicar_sdui_en_apk() ➔ void',
    'esquema3.fn_publicar_sdui_en_apk() ➔ void',
    'esquema3.esq3_rpc_actualizar_sdui() ➔ jsonb',
    'esquema3.procesar_evento_sdui() ➔ jsonb',
  ];
  List _pantallasEsq3 = [
    '📱 [RAIZ] (Muro - Suite 5 Pantallas Stitch: Muro, Ganadores, Bóveda, Aportes, Zona Socio)',
    '📱 [PANTALLA_ADMIN] (👑 ADMIN - Control de Pantallas, Joystick % y Roles)',
    '📱 [PANTALLA_LOGICA_UXUI] (📘 LÓGICA Y UX/UI - Manual exportable a PDF)',
  ];

  static const List _catalogoProyectosPrdRfc = [
    {
      'id': 'PROY_01_INVITADO_VS_REGISTRADO',
      'titulo': '1. Registro Invitado (#89F2A) vs. Socio con Contraseña/PIN',
      'fase': 'APROBADO EN ESQUEMA 2 Y 3',
      'prd_objetivo': 'Permitir que cualquier hincha explore todo el contenido de la app sin barreras iniciales (Modo Invitado #89F2A), pero motivarlo a registrar su Apodo + PIN/Contraseña de 4 dígitos (Modo Socio Registrado) para desbloquear Bóveda QR, Transferencias y Voto en el Parlamento.',
      'prd_roles': [
        '👤 Usuario Invitado (Sin Login - #89F2A): Entra directo sin bloqueo. Ve el Muro Santo y lanza el Dado Santo. Sus puntos se reservan temporalmente.',
        '🏅 Usuario Registrado (Con Login y PIN): Completa su formulario de blindaje. Desbloquea transferencia de premios QR, cupones seriados y voto certificado.'
      ],
      'prd_reglas': [
        'Regla 1 (Acceso libre): Al abrir la APK no se muestra pantalla de bloqueo; entra directo como Invitado.',
        'Regla 2 (Detección de acción protegida): Si un Invitado toca "Transferir a Hincha" o "Emitir Voto", se abre el modal de Registro/Blindaje.',
        'Regla 3 (Validación): Nombre/Apodo obligatorio (>= 3 caracteres) y PIN/Contraseña (>= 4 dígitos).',
        'Regla 4 (Desbloqueo inmediato): Al guardar en Supabase, el contrato SDUI habilita las opciones VIP sin reiniciar la APK.'
      ],
      'rfc_mermaid': 'graph TD;\n  A[Abrir APK] --> B{¿Tiene Sesión/PIN?};\n  B -- No --> C[Modo Invitado #89F2A: Acceso Lectura + Dado];\n  B -- Sí --> D[Modo Socio Registrado: Bóveda QR + Parlamento +51%];\n  C --> E[Toca Botón Protegido];\n  E --> F[Abre Modal Registro / Blindaje PIN];\n  F --> G[INSERT en esquema3.usuarios_estado];\n  G --> D;',
      'rfc_json_invitado': '{\n  "pantalla": "home_muro_santo",\n  "estado_usuario": "invitado",\n  "dispositivo_temp": "#89F2A",\n  "boton_transferir_qr": {"estado": "bloqueado", "abrir_modal": "blindar_boveda_pin"},\n  "menu_opciones_extra": {"visible": false}\n}',
      'rfc_json_registrado': '{\n  "pantalla": "home_muro_santo",\n  "estado_usuario": "registrado",\n  "datos_usuario": {"nombre": "Alejandro Choque M.", "rol": "SOCIO_VIP_1942"},\n  "boton_transferir_qr": {"estado": "activo", "operacion": "rpc_transferir_qr"},\n  "menu_opciones_extra": {"visible": true, "items": ["Bóveda QR", "Parlamento +51%", "Sorteos VIP"]}\n}',
    },
    {
      'id': 'PROY_02_PARLAMENTO_QUORUM_51',
      'titulo': '2. Parlamento Santo Vinculante (+51% del Padrón Total)',
      'fase': 'LISTO PARA INYECTAR',
      'prd_objetivo': 'Asegurar que toda moción institucional del Club San José requiera superar estrictamente el 51% del total de 3,420 socios habilitados.',
      'prd_roles': [
        '🗳️ Socio Habilitado (#1942): Emite 1 sufragio único firmado con huella/PIN (A Favor o En Contra).',
        '⚖️ Tribunal Electoral: Audita en cadena el hash del voto (0x9b42...1942SJ).'
      ],
      'prd_reglas': [
        'Regla 1: El porcentaje se calcula sobre 3,420 socios (100% del padrón), no solo sobre los presentes.',
        'Regla 2: Si A Favor es menor al 51%, barra en color Ámbar (#FFB703). Si A Favor >= 51%, barra en Verde (#00C853) con sello "¡Moción Aprobada!".'
      ],
      'rfc_mermaid': 'graph LR;\n  V[Toque Emitir Voto] --> H[Generar Hash 0x9b42];\n  H --> T[Guardar en api_comunicacion];\n  T --> Q{¿Votos Favor / 3420 >= 0.51?};\n  Q -- Sí --> OK[Estado: MOCIÓN APROBADA #00C853];\n  Q -- No --> PR[Estado: EN PROGRESO #FFB703];',
      'rfc_json_invitado': '{\n  "modulo": "parlamento_santo",\n  "quorum_meta": 0.51,\n  "socios_habilitados": 3420,\n  "puede_votar": false\n}',
      'rfc_json_registrado': '{\n  "modulo": "parlamento_santo",\n  "quorum_meta": 0.51,\n  "votos_favor": 2134,\n  "porcentaje_favor": 62.4,\n  "mocion_aprobada": true,\n  "puede_votar": true\n}',
    },
    {
      'id': 'PROY_03_LIKES_TIKTOK_TIEMPO_REAL',
      'titulo': '3. Sistema "Me Gusta" y Dado en Tiempo Real (Estilo TikTok)',
      'fase': 'ACTIVO EN DISEÑO 1',
      'prd_objetivo': 'Incrementar la retención en el Muro Santo mediante reacción instantánea de corazón (14.2k ➔ 14.3k) y lanzamiento de dado (1 al 6) con recompensa inmediata.',
      'prd_roles': [
        '🎬 Creador Oficial (@clubsanjose_oficial): Publica jugadas en formato vertical 9:16.',
        '💙 Hincha Activo: Reacciona con 1 toque y lanza el Dado Santo cada 10 Bs de aporte.'
      ],
      'prd_reglas': [
        'Regla 1: 1 voto de corazón activo por sesión; si vuelve a tocar, alterna entre 14.2k y 14.3k.',
        'Regla 2: Al llegar a 6/6 tiros del dado, desbloquea recompensa épica en la Bóveda QR.'
      ],
      'rfc_mermaid': 'graph TD;\n  L[Toque Corazón / Dado] --> A[Animación 360ms + Vibración Háptica];\n  A --> M[Abrir Modal +120 Puntos];\n  M --> B[Guardar Cupón 20% OFF en Bóveda];',
      'rfc_json_invitado': '{"accion": "toggle_like", "post_id": "bermudez_vivo_01", "contador_actual": "14.2k"}',
      'rfc_json_registrado': '{"accion": "roll_dice_reward", "tiro_salido": 6, "puntos_ganados": 120, "cupon_serie": "SN-772910"}',
    },
    {
      'id': 'PROY_04_HORARIO_Y_AUDITORIA_DUAL',
      'titulo': '4. Pantalla Dinámica 06:00 AM y Tribunal de Comprobantes',
      'fase': 'ACTIVO EN DISEÑO 4 Y 5',
      'prd_objetivo': 'Ejecutar la Tómbola Cuántica todos los días a las 06:00 AM y permitir validar comprobantes bancarios de 70 BS con regla dual automática.',
      'prd_roles': [
        '🛡️ Admin Central: Aprueba o rechaza lotes de comprobantes (#BNB-88319) y ajusta precios (270 BS / 70 BS).',
        '🏪 Tienda Aliada: Solo ve el Escáner Óptico QR para entregar poleras y descontar stock (14/50).'
      ],
      'prd_reglas': [
        'Regla 1: En modo Tienda Aliada se ocultan automáticamente los módulos financieros del Tribunal y Gestor Paramétrico.',
        'Regla 2: Al quemar un QR en tienda, el stock baja de 14 a 13 en tiempo real.'
      ],
      'rfc_mermaid': 'graph LR;\n  S[Escanear Token #SJ-9942] --> V{¿QR Válido?};\n  V -- Sí --> Q[Quemar Premio + Restar 1 Stock];\n  V -- No --> E[Alerta QR Ya Redimido];',
      'rfc_json_invitado': '{"modo_operativo": "store", "mostrar_tribunal": false, "stock_sucursal": 14}',
      'rfc_json_registrado': '{"modo_operativo": "admin", "mostrar_tribunal": true, "lote_pendientes": 12, "cuota_inscripcion_bs": 270, "mensualidad_bs": 70}',
    },
  ];

  String _generarCodigoSqlCompleto() {
    return '''DO \$BODY\$
DECLARE
    v_p JSONB := current_setting('sdui.payload', true)::jsonb;
    v_apodo TEXT := TRIM(COALESCE(v_p->>'p_apodo_hincha', 'MineroSanto_77'));
    v_pin TEXT := TRIM(COALESCE(v_p->>'p_pin_secreto', '1942'));
BEGIN
    -- 1. DISPARADOR: ${_ctrlPregunta1Trigger.text}
    -- 2. CONDICIÓN IF:
    IF NOT (${_ctrlPregunta2CondicionIf.text}) THEN
        PERFORM set_config('sdui.resultado_json', '{"exito":false,"mensaje":"⚠️ No se cumplió la condición IF de validación."}', true);
        RETURN;
    END IF;

    -- 3. ACCIÓN EN SUPABASE (ESQUEMA 3):
    ${_ctrlPregunta3AccionSql.text}

    PERFORM set_config('sdui.resultado_json', jsonb_build_object(
        'exito', true,
        'limpiar_inputs', true,
        'mensaje', '${_ctrlMensajeOk.text}'
    )::text, true);
END;
\$BODY\$;''';
  }

  Future _escanearAdnAmbosEsquemas() async {
    (widget as Ms14StudioPrdRfcPdf).onFeedback('🔍 Escaneando tablas, columnas y RPCs de Esquema 2 y Esquema 3...');
    final res = await PuenteSupabaseSdui.ejecutarRpcUniversal(
      'esq2_rpc_obtener_mapa_completo_bd',
      {},
      esquemaOverride: 'esquema2',
    );
    if (res['exito'] == true && mounted) {
      setState(() {
        if (res['tablas_y_columnas'] is List && (res['tablas_y_columnas'] as List).isNotEmpty) {
          _tablasDetectadas = List.from(res['tablas_y_columnas'] as List);
        }
        if (res['funciones_rpc'] is List && (res['funciones_rpc'] as List).isNotEmpty) {
          _rpcsDetectados = List.from(res['funciones_rpc'] as List);
        }
        if (res['pantallas_esq3'] is List && (res['pantallas_esq3'] as List).isNotEmpty) {
          _pantallasEsq3 = List.from(res['pantallas_esq3'] as List);
        }
      });
      (widget as Ms14StudioPrdRfcPdf).onFeedback('✅ ADN actualizado: ${_tablasDetectadas.length} columnas y ${_rpcsDetectados.length} RPCs en vivo.');
    } else {
      (widget as Ms14StudioPrdRfcPdf).onFeedback('ℹ️ Mostrando catálogo local de Esquema 2 y Esquema 3.');
    }
  }

  Future _inyectarLogicaDirectoAEsquema3() async {
    HapticFeedback.heavyImpact();
    final String sqlFinal = _generarCodigoSqlCompleto();
    (widget as Ms14StudioPrdRfcPdf).onFeedback('🚀 Inyectando [${_ctrlIdAccion.text}] desde Esquema 2 hacia Esquema 3...');
    final res = await PuenteSupabaseSdui.ejecutarRpcUniversal(
      'esq2_rpc_publicar_logica_en_esq3',
      {
        'p_id_accion': _ctrlIdAccion.text.trim(),
        'p_pantalla_origen': _ctrlPantalla.text.trim(),
        'p_boton_disparador': _ctrlPregunta1Trigger.text.trim(),
        'p_explicacion': 'IF (${_ctrlPregunta2CondicionIf.text.trim()}) -> ${_ctrlMensajeOk.text.trim()}',
        'p_tablas': 'esquema3.usuarios_estado, esquema3.api_comunicacion',
        'p_sql_dinamico': sqlFinal,
      },
      esquemaOverride: 'esquema2',
    );
    (widget as Ms14StudioPrdRfcPdf).onFeedback(res['mensaje']?.toString() ?? '🚀 Lógica publicada en Esquema 3.');
    await (widget as Ms14StudioPrdRfcPdf).onSincronizar();
  }

  @override
  Widget build(BuildContext context) {
    final Map proy = Map.from(_catalogoProyectosPrdRfc[_idxProyecto] as Map);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF00509D), Color(0xFF142033), Color(0xFF071326)]),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFBB400), width: 1.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'logo.png',
                          width: 34,
                          height: 34,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.architecture, color: Color(0xFFFBB400), size: 28),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STUDIO SDUI · FÁBRICA PRD / RFC / SQL',
                            style: TextStyle(color: Color(0xFFFBB400), fontSize: 13.5, fontWeight: FontWeight.w900, letterSpacing: 0.6),
                          ),
                          Text(
                            'Plano de Control (esquema2) y Producción Stitch (esquema3)',
                            style: TextStyle(color: Color(0xFFA9C7FF), fontSize: 10.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      foregroundColor: const Color(0xFF071326),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.picture_as_pdf, size: 16),
                    label: const Text('EXPORTAR PDF', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)),
                    onPressed: () {
                      DespachadorAccionesSdui.generarYMostrarLibroPdfMaestro(
                        context: context,
                        tituloPdf: 'Libro Maestro PRD + RFC + SQL + Tablas (Esquema 2 y 3)',
                        itemsExtra: _tablasDetectadas,
                        onFeedback: (widget as Ms14StudioPrdRfcPdf).onFeedback,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFF030E21), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    _botonSubTab(0, '📘 1. PRD & RFC'),
                    _botonSubTab(1, '⚙️ 2. IF/FOR/RPC'),
                    _botonSubTab(2, '🗄️ 3. TABLAS/ADN'),
                    _botonSubTab(3, '🤖 4. PROMPT/PDF'),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (_subTab == 0) ...[
          const Text(
            '🎯 SELECCIONA EL MÓDULO PRD / RFC A REVISAR O AUDITAR:',
            style: TextStyle(color: Color(0xFFA9C7FF), fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(_catalogoProyectosPrdRfc.length, (i) {
              final Map item = Map.from(_catalogoProyectosPrdRfc[i] as Map);
              final bool sel = _idxProyecto == i;
              return ChoiceChip(
                label: Text(
                  item['titulo'].toString(),
                  style: TextStyle(color: sel ? const Color(0xFF071326) : Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                ),
                selected: sel,
                selectedColor: const Color(0xFFFBB400),
                backgroundColor: const Color(0xFF142033),
                onSelected: (_) => setState(() => _idxProyecto = i),
              );
            }),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF142033),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFBB400), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '📋 PARTE 1: EL PRD (QUÉ CONSTRUIMOS Y REGLAS DE NEGOCIO)',
                      style: TextStyle(color: Color(0xFFFBB400), fontSize: 12, fontWeight: FontWeight.w900),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFF00C853), borderRadius: BorderRadius.circular(999)),
                      child: Text(proy['fase'].toString(), style: const TextStyle(color: Color(0xFF071326), fontSize: 9, fontWeight: FontWeight.w900)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '🎯 Objetivo del Módulo:\n${proy['prd_objetivo']}',
                  style: const TextStyle(color: Color(0xFFD7E3FD), fontSize: 12, height: 1.35),
                ),
                const Divider(color: Color(0xFF2A3549), height: 18),
                const Text('👥 Roles de Usuario:', style: TextStyle(color: Color(0xFFA9C7FF), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...((proy['prd_roles'] as List?) ?? []).map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(r.toString(), style: const TextStyle(color: Colors.white, fontSize: 11.5)),
                    )),
                const Divider(color: Color(0xFF2A3549), height: 18),
                const Text('⚖️ Historias de Usuario y Reglas de Negocio:', style: TextStyle(color: Color(0xFFA9C7FF), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...((proy['prd_reglas'] as List?) ?? []).map((reg) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $reg', style: const TextStyle(color: Color(0xFFFFD795), fontSize: 11.5)),
                    )),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF101C2F),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF00F3FF), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '⚙️ PARTE 2: EL RFC TÉCNICO (DIAGRAMA MERMAID + CONTRATOS JSON SDUI)',
                  style: TextStyle(color: Color(0xFF00F3FF), fontSize: 12, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                const Text('🗺️ 1. Diagrama de Flujo Lógico (Código Mermaid):', style: TextStyle(color: Color(0xFFA9C7FF), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF030E21), borderRadius: BorderRadius.circular(8)),
                  child: SelectableText(
                    proy['rfc_mermaid'].toString(),
                    style: const TextStyle(color: Color(0xFF00FF66), fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('📦 2. Caso A — Contrato JSON que recibe el Usuario Invitado (Sin Login):', style: TextStyle(color: Color(0xFFA9C7FF), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF030E21), borderRadius: BorderRadius.circular(8)),
                  child: SelectableText(
                    proy['rfc_json_invitado'].toString(),
                    style: const TextStyle(color: Color(0xFFFFD795), fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('🔓 3. Caso B — Contrato JSON que recibe el Socio Registrado (Con Contraseña/PIN):', style: TextStyle(color: Color(0xFFA9C7FF), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF030E21), borderRadius: BorderRadius.circular(8)),
                  child: SelectableText(
                    proy['rfc_json_registrado'].toString(),
                    style: const TextStyle(color: Color(0xFFA9C7FF), fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (_subTab == 1) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF142033),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF00C853), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🧩 METODOLOGÍA DE LAS 3 PREGUNTAS ➔ GENERADOR AUTOMÁTICO SQL_DINAMICO',
                  style: TextStyle(color: Color(0xFF00C853), fontSize: 12.5, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Programa cualquier botón de Google Stitch respondiendo las 3 preguntas y publícalo directo hacia Esquema 3:',
                  style: TextStyle(color: Colors.white70, fontSize: 11.5),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _cajaTextoStudio('ID de la Acción RPC:', _ctrlIdAccion),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _cajaTextoStudio('Pantalla Destino:', _ctrlPantalla),
                    ),
                  ],
                ),
                _cajaTextoStudio('1️⃣ ¿Qué lo activa? (Disparador / Trigger en Stitch):', _ctrlPregunta1Trigger),
                _cajaTextoStudio('2️⃣ ¿Qué debe comprobarse antes? (Condición IF en SQL):', _ctrlPregunta2CondicionIf),
                _cajaTextoStudio('3️⃣ ¿Qué ocurre después en Supabase? (INSERT / UPDATE / FOR):', _ctrlPregunta3AccionSql, maxLines: 4),
                _cajaTextoStudio('✅ Mensaje de Éxito que verá el usuario en la APK #1:', _ctrlMensajeOk),
                const SizedBox(height: 8),
                const Text('💻 CÓDIGO SQL_DINAMICO GENERADO EN VIVO (LISTO PARA ESQUEMA 3):', style: TextStyle(color: Color(0xFFFBB400), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF030E21),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF00509D)),
                  ),
                  child: SelectableText(
                    _generarCodigoSqlCompleto(),
                    style: const TextStyle(color: Color(0xFF00FF66), fontFamily: 'monospace', fontSize: 10.5, height: 1.35),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFBB400),
                          foregroundColor: const Color(0xFF071326),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        icon: const Icon(Icons.rocket_launch, size: 18),
                        label: const Text('🚀 PUBLICAR EN ESQUEMA 3 (APK USUARIOS)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                        onPressed: _inyectarLogicaDirectoAEsquema3,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00509D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                      ),
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('COPIAR SQL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _generarCodigoSqlCompleto()));
                        (widget as Ms14StudioPrdRfcPdf).onFeedback('📋 Bloque DO \$BODY\$ copiado al portapapeles.');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        if (_subTab == 2) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF142033),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFA9C7FF), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        '🔍 INTROSPECCIÓN EN VIVO (21 TABLAS ESQ2 + 16 TABLAS ESQ3)',
                        style: TextStyle(color: Color(0xFFFBB400), fontSize: 12, fontWeight: FontWeight.w900),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00509D), foregroundColor: Colors.white),
                      icon: const Icon(Icons.sync, size: 16),
                      label: const Text('ESCANEAR BD', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                      onPressed: _escanearAdnAmbosEsquemas,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF030E21), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🎨 MAPEADOR DE CONTRATOS SDUI (IDEA 5):', style: TextStyle(color: Color(0xFFA9C7FF), fontSize: 10.5, fontWeight: FontWeight.bold)),
                          Text(
                            _temaWireframe ? 'Modo Activo: "tema": "wireframe" (Cajas Grises CRUD)' : 'Modo Activo: "tema": "stitch_v1" (Diseño Final Google Stitch)',
                            style: const TextStyle(color: Color(0xFF00FF66), fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Switch(
                        value: !_temaWireframe,
                        activeColor: const Color(0xFFFBB400),
                        onChanged: (v) => setState(() => _temaWireframe = !v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text('📱 Pantallas Detectadas en Esquema 3 (APK Usuarios):', style: TextStyle(color: Color(0xFFA9C7FF), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ..._pantallasEsq3.map((p) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text(p.toString(), style: const TextStyle(color: Colors.white, fontSize: 11)),
                    )),
                const Divider(color: Color(0xFF2A3549), height: 18),
                const Text('⚡ Funciones RPC y Puentes Activos:', style: TextStyle(color: Color(0xFFA9C7FF), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ..._rpcsDetectados.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Text('• $r', style: const TextStyle(color: Color(0xFFFFD795), fontSize: 11, fontFamily: 'monospace')),
                    )),
                const Divider(color: Color(0xFF2A3549), height: 18),
                Text('🗄️ Columnas Detectadas en information_schema (${_tablasDetectadas.length}):', style: const TextStyle(color: Color(0xFFA9C7FF), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF030E21), borderRadius: BorderRadius.circular(8)),
                  child: ListView.builder(
                    itemCount: _tablasDetectadas.length,
                    itemBuilder: (_, idx) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        _tablasDetectadas[idx].toString(),
                        style: const TextStyle(color: Color(0xFFD7E3FD), fontSize: 10.5, fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (_subTab == 3) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF142033),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFBB400), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🤖 PROMPT MAESTRO Y REGLAS PARA LA IA (ESQUEMA 2 Y ESQUEMA 3)',
                  style: TextStyle(color: Color(0xFFFBB400), fontSize: 12.5, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF030E21), borderRadius: BorderRadius.circular(10)),
                  child: const SelectableText(
                    'ACTÚA COMO ARQUITECTO DE SOFTWARE SENIOR ESPECIALISTA EN FLUTTER (DART 3.5+) + SDUI (STAC + JSON_DYNAMIC_WIDGET) + PRD/RFC + SUPABASE DUAL (ESQUEMA 2 STUDIO y ESQUEMA 3 PRODUCCIÓN).\n\n'
                    'REGLAS INQUEBRANTABLES:\n'
                    '1. ARQUITECTURA DE 2 APKS SEPARADAS: APK #1 (FLUTTERSDUI en esquema3) es para los usuarios finales con el diseño Stitch 1:1 congelado. APK #2 (STUDIOSDUI en esquema2) es la fábrica privada de PRD, RFC, Sandbox y lógica RPC.\n'
                    '2. REGLA DE LAS 3 PREGUNTAS: Cada botón se define por: (1) Disparador, (2) Condición IF, y (3) Acción en Supabase + Respuesta SDUI.\n'
                    '3. ESTRUCTURA SQL_DINAMICO: Todo bloque DO \$BODY\$ lee entradas con current_setting(\'sdui.payload\', true)::jsonb y responde con set_config(\'sdui.resultado_json\', ...).\n'
                    '4. PUBLICACIÓN EN VIVO: Para enviar lógica probada de esquema2 a esquema3 se invoca esquema2.esq2_rpc_publicar_logica_en_esq3(), que ejecuta automáticamente SELECT esquema3.fn_publicar_sdui_en_apk(\'admin_san_jose\');',
                    style: TextStyle(color: Color(0xFFD7E3FD), fontSize: 11, fontFamily: 'monospace', height: 1.4),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFBB400),
                          foregroundColor: const Color(0xFF071326),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                        icon: const Icon(Icons.picture_as_pdf, size: 18),
                        label: const Text('📄 GENERAR LIBRO PDF COMPLETO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                        onPressed: () {
                          DespachadorAccionesSdui.generarYMostrarLibroPdfMaestro(
                            context: context,
                            tituloPdf: 'Libro Maestro PRD + RFC + SQL + JSON (Esquema 2 y 3)',
                            itemsExtra: _tablasDetectadas,
                            onFeedback: (widget as Ms14StudioPrdRfcPdf).onFeedback,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _botonSubTab(int idx, String label) {
    final bool act = _subTab == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _subTab = idx);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: act ? const Color(0xFFFBB400) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: act ? const Color(0xFF071326) : Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _cajaTextoStudio(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFA9C7FF), fontSize: 10.5, fontWeight: FontWeight.bold)),
          const SizedBox(height: 3),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF030E21),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }
}