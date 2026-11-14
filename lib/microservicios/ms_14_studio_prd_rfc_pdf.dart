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
  int _subTab = 0; // 0=PRD/RFC+Imagen, 1=Nubes #1..#45, 2=Tiquear PRD/RFC, 3=Mapa Mental
  int _idxPantallaPrd = 0;
  String _filtroPantallaNube = 'P1_MURO';
  int _idxMapaMental = 0;

  final Set _rolesTiqueados = {'🏅 Socio Vitalicio / Registrado con PIN (#1942)'};
  String _nubeSeleccionada = '☁️ #20 | btn-blindar (Botón Dorado Blindar Bóveda Ahora)';
  String _pantallaDestinoNube = 'RAIZ';
  final Set _condicionesTiqueadas = {'🔐 Que el usuario haya ingresado un PIN válido de 4 dígitos'};
  final Set _accionesTiqueadas = {'📝 Registrar / Actualizar en usuarios_estado (Apodo, PIN y Puntos)'};
  final Set _respuestasTiqueadas = {'🔔 Mostrar Toast Dorado inferior con check de confirmación'};
  final TextEditingController _ctrlTextoLibreExtra = TextEditingController(
    text: 'Al confirmar el PIN, migrar automáticamente los +40 pts del dispositivo temporal #89F2A.',
  );

  static const List _pantallasPrdRfc = [
    {
      'id': 'PROY_01_MURO_SANTO_DADO',
      'pantalla_num': 'PANTALLA 1 (DISEÑO 1)',
      'titulo': '1. Muro Santo 9:16 + El Mirón (#89F2A) + Dado Santo',
      'rpc_microservicio': 'esquema3.esq3_ms_pantalla_1_muro(p_payload)',
      'trigger_activo': 'trg_notificar_cambio_diseno_a_esq2 + trg_candado_pantallas_esq3',
      'imagen_diseno': 'https://lh3.googleusercontent.com/aida-public/AB6AXuAzkbVETd8U6n0rkXQSMlREA8aZEjR18epUA2BD_YO7PAL4VW15ANS8bUKder-D7btF1xcS_yZTr4LyqSgc-LouZ2HOgc9za70VxcrVygqOZTmF-XfzJUF5GUkNafJhnSC0WG9slLpBR1OW7CphxQfZespFPWuHCse5i1eIcWIrPGZuHO0YJzE6jAhOU1biLZdyvjcnbD8qCEqcLKKw7Wa9o0WWVfqKERfhl3RcM8k',
      'nubes_incluidas': '☁️ Nube #1 a ☁️ Nube #9 (Header 1942, 350 pts, HUD #89F2A, El Mirón, Video 9:16, Seguir +, Like 14.2k, Lanzar Dado 1-6, Modal +120 pts)',
      'que_registra_bd': '• Registra sesión anónima temporal (#89F2A) con +40 pts en esquema3.usuarios_estado.\n• Registra cada tiro del Dado Santo (1 al 6) y el contador de Likes (14.2k a 14.3k) en esquema3.api_comunicacion.',
      'que_controla_if': '• Controla que el usuario entre directo sin bloqueo de login (Modo Invitado).\n• Valida el progreso de 4/6 tiros (66%) hacia la Camiseta Oficial 2025.',
      'mermaid': 'graph TD;\n  N1[☁️ #1 Abrir Muro Santo] --> N3[☁️ #3 Sesión Temporal #89F2A];\n  N3 --> N8[☁️ #8 Toca Botón Lanzar Dado];\n  N8 --> RPC1[⚡ RPC: esq3_ms_pantalla_1_muro];\n  RPC1 --> N9[☁️ #9 Abre Modal +120 Pts y Cupón 20%];',
    },
    {
      'id': 'PROY_02_GANADORES_TOMBOLA_06AM',
      'pantalla_num': 'PANTALLA 2 (DISEÑO 5)',
      'titulo': '2. Ganadores + Reloj 06:00 AM + Esfera Cuántica + Top 10',
      'rpc_microservicio': 'esquema3.esq3_ms_pantalla_2_ganadores(p_payload)',
      'trigger_activo': 'trg_notificar_cambio_diseno_a_esq2 (Sincronización automática a Esquema 2)',
      'imagen_diseno': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCJ-oE4cIBMfeuqLBNAuYoVl-21SUEgErUtcmNZbWV9O4OaM6uBtxsd7BMBEnRZBfudHeZ5X9HUID6_bBdnLgGuFzG3NFmzmVt3zSQpBd_qDEaeMZwS9B_DX-QAmGKRB7la3unxl0rx7GyyTva0tjMudhs-tedsWx4kteJliL2bPNAx3IgB8K1AlJug-yDe8Wzt0L7BGYQfLoVTRUK1e_wLqIA0j7I0AElQz8U_ZgU',
      'nubes_incluidas': '☁️ Nube #10 a ☁️ Nube #18 (Reloj 05:42:18, Premio Estrella Camiseta, Esfera Cuántica 8-3-9-5, Botón Subir Comprobante, FlashList Top 10 Ganadores, 3 Franquicias)',
      'que_registra_bd': '• Registra comprobantes de aporte (cada 10 Bs = +1 boleto cuántico) en esquema3.api_comunicacion.\n• Registra la lista oficial auditada de los 10 ganadores diarios a las 06:00 AM en juegos_kahoot_lumosity.',
      'que_controla_if': '• Controla el temporizador hacia las 06:00 AM.\n• Valida que cada boleto tenga hash criptográfico único (#4819-A, #0192-K, #7731-X).',
      'mermaid': 'graph LR;\n  N13[☁️ #13 Subir Comprobante] --> RPC2[⚡ RPC: esq3_ms_pantalla_2_ganadores];\n  RPC2 --> N12[☁️ #12 Mezclar 4,120 Boletos en Esfera];\n  N12 --> N14[☁️ #14-#16 Publicar FlashList Top 10];',
    },
    {
      'id': 'PROY_03_BOVEDA_PIN_Y_QR',
      'pantalla_num': 'PANTALLA 3 (DISEÑO 2)',
      'titulo': '3. Bóveda QR + Blindaje PIN 4 Dígitos + 3 Cupones Diarios',
      'rpc_microservicio': 'esquema3.esq3_ms_pantalla_3_boveda(p_payload)',
      'trigger_activo': 'trg_notificar_cambio_diseno_a_esq2 + Regenerador Token QR 45s',
      'imagen_diseno': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCJ-oE4cIBMfeuqLBNAuYoVl-21SUEgErUtcmNZbWV9O4OaM6uBtxsd7BMBEnRZBfudHeZ5X9HUID6_bBdnLgGuFzG3NFmzmVt3zSQpBd_qDEaeMZwS9B_DX-QAmGKRB7la3unxl0rx7GyyTva0tjMudhs-tedsWx4kteJliL2bPNAx3IgB8K1AlJug-yDe8Wzt0L7BGYQfLoVTRUK1e_wLqIA0j7I0AElQz8U_ZgU',
      'nubes_incluidas': '☁️ Nube #19 a ☁️ Nube #27 (Alerta Resguardo, Botón Blindar Bóveda, Billetera 480 pts, Selector PIN 1h/6h/24h/Siempre, QR Polera SJ-8821-QR, Mostrar en Tienda, Transferir, FlashList 3 Cupones)',
      'que_registra_bd': '• Registra el Apodo de Hincha y el PIN Secreto de 4 dígitos en esquema3.usuarios_estado.\n• Registra la transferencia de propiedad de un premio QR hacia otro hincha en esquema3.inventario_premios.',
      'que_controla_if': '• Controla que el PIN tenga exactamente 4 dígitos numéricos antes de encriptar.\n• Regenera dinámicamente el código QR (SJ-8821-QR) cada 45 segundos para evitar capturas falsas.',
      'mermaid': 'graph TD;\n  N20[☁️ #20 Toca Blindar Bóveda] --> N27[☁️ #27 Modal Apodo + PIN 4 Dígitos];\n  N27 --> RPC3[⚡ RPC: esq3_ms_pantalla_3_boveda];\n  RPC3 --> N23[☁️ #23 Activa QR Polera + FlashList #26];',
    },
    {
      'id': 'PROY_04_AUDITORIA_Y_TIENDA_QR',
      'pantalla_num': 'PANTALLA 4 (DISEÑO 4)',
      'titulo': '4. Auditoría de Pagos + Escáner Tienda (-1 Stock) + Tribunal',
      'rpc_microservicio': 'esquema3.esq3_ms_pantalla_4_auditoria(p_payload)',
      'trigger_activo': 'trg_notificar_cambio_diseno_a_esq2 + Regla Dual Automática',
      'imagen_diseno': 'https://lh3.googleusercontent.com/aida-public/AB6AXuDKqD9D6jn6MviQ8Pf11VIhyzQCyd4b2ouxe0LcsZFccPvicG1oeid4qnfRSWkVCDGn84VnuhcumhqtrD__EnM89ZxlnPNl5ZFl1bALBeP7kdhNXypla5usVVczZZufuons6BhqXvNY-AKanrrXQUn2mlw6ff36VbTFzqjOWyXUS2jYQ6i6t34oklBQ3y-Ie-7OSZSwErHdMZmEyY-TFwV6jgP2I5oibhpVL0kNKsg',
      'nubes_incluidas': '☁️ Nube #28 a ☁️ Nube #36 (Switch Admin/Tienda, Stock 14/50 Poleras, Cámara QR #SJ-9942, Botón Quemar de la Bóveda, Tribunal 2 Col Recibo #BNB-88319, Rechazar/Aprobar, Inputs 270/70 BS, Slider Dado)',
      'que_registra_bd': '• Registra el canje y quemado presencial del premio QR descontando -1 del stock (de 14/50 a 13/50) en inventario_premios.\n• Registra la aprobación o rechazo de los recibos bancarios de 70 BS del Lote de 12 pendientes.',
      'que_controla_if': '• Controla el rol activo en la Nube #28: si es Tienda Aliada, oculta automáticamente el Tribunal (#32-#33) y el Gestor (#34-#36).\n• Verifica Match 100% entre el recibo #BNB-88319 y el Socio #1842.',
      'mermaid': 'graph LR;\n  N28[☁️ #28 Conmutador Rol] --> B{¿Admin o Tienda?};\n  B -- Tienda --> N31[☁️ #31 Quemar QR y Restar -1 Stock];\n  B -- Admin --> N33[☁️ #33 Aprobar 70 BS + Ajustar #34-#36];',
    },
    {
      'id': 'PROY_05_ZONA_SOCIO_PARLAMENTO_51',
      'pantalla_num': 'PANTALLA 5 (DISEÑO 3)',
      'titulo': '5. Zona Socio #1942 + Parlamento Santo (+51%) + Credencial',
      'rpc_microservicio': 'esquema3.esq3_ms_pantalla_5_socio(p_payload)',
      'trigger_activo': 'trg_notificar_cambio_diseno_a_esq2 + Validador Quórum 51%',
      'imagen_diseno': 'https://lh3.googleusercontent.com/aida-public/AB6AXuCb5NY4n_ugH-ni34NAfQyVGYpraf_nTo7UO280JrhbSAkRR21bUKAIFFGNWpYsZMaN7B3Uw-VvTp2EoxGz_I4y_0rSOTp_2U_W0XGv7mQBM3K3ykJ_LOvZEdTRDCze_Vl9vfG0GB_WgQB57laQaWxloca3-f33GK3NYH4DONfr89_8wflkqm-FN2rZd2Bn9AT-vJ_2fXeAPa7CDk0b3206dDMHsjn2uEwFvj_tAK8',
      'nubes_incluidas': '☁️ Nube #37 a ☁️ Nube #45 (Hero Socio Vitalicio #1942, 3 Pestañas Socio, Moción 08-2025, Barra Quórum 51%, Botón Emitir Voto Certificado, Credencial Digital, Estado de Cuenta 270/70 BS, Ticket Extra VIP, 3 Cupones Auto)',
      'que_registra_bd': '• Registra el voto firmado digitalmente (A Favor o En Contra) con Hash 0x9b42...1942SJ en esquema3.api_comunicacion.\n• Asigna gratuitamente el ticket extra #SJ-1942-C para el sorteo de la Camiseta Firmada.',
      'que_controla_if': '• Controla que el quórum se calcule sobre el 100% de los 3,420 socios habilitados (exige >= 51% para aprobar moción).\n• Verifica que la mensualidad de 70 BS esté Al Día para habilitar voto y sorteos VIP.',
      'mermaid': 'graph TD;\n  N37[☁️ #37 Socio #1942 SJ-42901-LP] --> N41[☁️ #41 Emitir Voto Certificado];\n  N41 --> RPC5[⚡ RPC: esq3_ms_pantalla_5_socio];\n  RPC5 --> N40[☁️ #40 Quórum 62.4% >= 51%: Moción Aprobada];',
    },
  ];

  static const List _nubes45Catalogo = [
    {'num': 1, 'pant': 'P1_MURO', 'id': 'header_san_jose_1942', 'tipo': 'HEADER_FIJO', 'nom': 'Cabecera SAN JOSÉ 1942 + SOCIO VIP', 'donde': 'Arriba fijo con blur', 'muestra': 'Avatar + SAN JOSÉ 1942 + SOCIO VIP', 'rpc': 'Muestra sesión activa'},
    {'num': 2, 'pant': 'P1_MURO', 'id': 'header_pill_350_pts', 'tipo': 'BADGE_PUNTOS', 'nom': 'Píldora ⭐ 350 pts + Escudo Edit Pro', 'donde': 'Esquina superior derecha', 'muestra': '350 pts + Icono verified_user', 'rpc': 'Al tocar abre Stitch Studio Edit Pro'},
    {'num': 3, 'pant': 'P1_MURO', 'id': 'muro_hud_lanzamiento', 'tipo': 'BANNER_HUD', 'nom': 'Banner Lanzamiento Activo (+40 pts • #89F2A)', 'donde': 'Debajo del Header', 'muestra': '+40 pts acumulados • #89F2A', 'rpc': 'Reserva puntos en dispositivo #89F2A'},
    {'num': 4, 'pant': 'P1_MURO', 'id': 'btn-anon-mode', 'tipo': 'BOTON', 'nom': 'Botón 👁️ El Mirón (Modo Anónimo)', 'donde': 'Derecha del HUD', 'muestra': 'El Mirón', 'rpc': 'Abre Tooltip Modal #89F2A'},
    {'num': 5, 'pant': 'P1_MURO', 'id': 'muro_video_9_16', 'tipo': 'VIDEO_9_16', 'nom': 'Viewport Video 9:16 En Vivo Bermúdez', 'donde': 'Centro de Pantalla 1', 'muestra': 'EN VIVO BERMÚDEZ + AUDIO HISTÓRICO + @clubsanjose_oficial', 'rpc': 'Reproduce jugada en vivo'},
    {'num': 6, 'pant': 'P1_MURO', 'id': 'btn-follow-club', 'tipo': 'BOTON_ICONO', 'nom': 'Escudo Redondo San José + Botón (+)', 'donde': 'Riel derecho arriba', 'muestra': 'Escudo + Botón dorado (+)', 'rpc': 'Cambia a (✓) y sigue al club'},
    {'num': 7, 'pant': 'P1_MURO', 'id': 'btn-like-heart', 'tipo': 'BOTON_LIKE', 'nom': 'Botón Corazón Me Gusta (14.2k) + 842 + 3.1k', 'donde': 'Riel derecho centro', 'muestra': '❤️ 14.2k | 💬 842 | 🔗 3.1k | 💿 Vinilo', 'rpc': 'Sube a 14.3k en coral (esq3_ms_pantalla_1_muro)'},
    {'num': 8, 'pant': 'P1_MURO', 'id': 'btn-roll-dice', 'tipo': 'BOTON_DADO', 'nom': 'Centro Tirar Dado Santo (1 al 6) + Botón Lanzar', 'donde': 'Abajo del video', 'muestra': 'Tirar Dado Santo + Barra 4/6 Tiros (66%)', 'rpc': 'Gira dado 360°, llama a esq3_ms_pantalla_1_muro y abre Modal #9'},
    {'num': 9, 'pant': 'P1_MURO', 'id': 'dice-modal-claim', 'tipo': 'MODAL_POPUP', 'nom': 'Modal ¡TIRO PERFECTO! (+120 Pts) + Botón Guardar', 'donde': 'Popup central', 'muestra': 'Dado #6 + +120 Pts + Cupón 20% OFF', 'rpc': 'Guarda en Bóveda y salta a Pantalla 3'},
    {'num': 10, 'pant': 'P2_GANADORES', 'id': 'gan_reloj_06am', 'tipo': 'RELOJ_DIGITAL', 'nom': 'Hero Sorteo 06:00 AM + Reloj [05:42:18]', 'donde': 'Arriba de Pantalla 2', 'muestra': '05 HRS : 42 MIN : 18 SEG', 'rpc': 'Cuenta regresiva hacia las 06:00 AM'},
    {'num': 11, 'pant': 'P2_GANADORES', 'id': 'gan_premio_estrella', 'tipo': 'TARJETA_PREMIO', 'nom': 'Tarjeta Premio Estrella: Camiseta Autografiada', 'donde': 'Debajo del reloj', 'muestra': 'Camiseta Oficial + 2 Cupones Santo Express', 'rpc': 'Lee premio mayor de inventario_premios'},
    {'num': 12, 'pant': 'P2_GANADORES', 'id': 'gan_esfera_cuantica', 'tipo': 'ESFERA_TUMBLER', 'nom': 'Esfera Cuántica en Vivo (Boloña #748-SJ)', 'donde': 'Centro de Pantalla 2', 'muestra': 'Rodillos [8][3][9][5] • 4,120 números', 'rpc': 'Mezcla boletos activos cada 220ms'},
    {'num': 13, 'pant': 'P2_GANADORES', 'id': 'btn-upload-voucher', 'tipo': 'BOTON_PRIMARIO', 'nom': 'Botón Dorado 📤 Subir Comprobante (10 Bs = 1 Tiro)', 'donde': 'Tarjeta azul ¿Cómo entrar?', 'muestra': 'Subir Comprobante', 'rpc': 'Ejecuta esq3_ms_pantalla_2_ganadores'},
    {'num': 14, 'pant': 'P2_GANADORES', 'id': 'gan_top10_podium_1', 'tipo': 'PODIO_1', 'nom': 'Podio 1º Lugar: Hincha_Orureño_77 (#4819-A)', 'donde': 'Inicio FlashList Top 10', 'muestra': '1º Polera Conmemorativa 1942 • 06:01 AM', 'rpc': 'Muestra ganador #1 auditado'},
    {'num': 15, 'pant': 'P2_GANADORES', 'id': 'gan_top10_podium_2_3', 'tipo': 'FLASHLIST_2_3', 'nom': 'Podio 2º Carlos M. (#0192-K) y 3º Device_98B2', 'donde': 'Filas 2 y 3 del Top 10', 'muestra': 'Combo Pollos Aliados y Entrada vs Blooming', 'rpc': 'Muestra ganadores #2 y #3'},
    {'num': 16, 'pant': 'P2_GANADORES', 'id': 'gan_top10_4_al_10', 'tipo': 'FLASHLIST_4_10', 'nom': 'FlashList Ganadores 4º Raúl Q. al 10º Device_00CC', 'donde': 'Filas 4 a 10 del Top 10', 'muestra': 'Gorra, Vale 50 Bs, Bebidas, Bufanda, Pase, Bono 100 pts', 'rpc': 'Lista completa auditada 06:05 AM'},
    {'num': 17, 'pant': 'P2_GANADORES', 'id': 'gan_sponsors_grid3', 'tipo': 'GRID_3_COL', 'nom': 'Mosaico 3 Franquicias Aliadas (Pollos, Café, Estación)', 'donde': 'Pie de Pantalla 2', 'muestra': '2x1 Combos | Pase VIP | Puntos x2', 'rpc': 'Red oficial de canje QR'},
    {'num': 18, 'pant': 'P2_GANADORES', 'id': 'rules-btn-tombola', 'tipo': 'BOTON', 'nom': 'Botón Bases del Sorteo 06:00 AM', 'donde': 'Derecha de Subir Comprobante', 'muestra': 'Bases', 'rpc': 'Abre reglamento del sorteo'},
    {'num': 19, 'pant': 'P3_BOVEDA', 'id': 'bov_alerta_resguardo', 'tipo': 'TARJETA_ALERTA', 'nom': 'Alerta Protocolo de Resguardo (Protege tus Recompensas)', 'donde': 'Arriba de Pantalla 3', 'muestra': '1 Premio Activo y 3 Cupones', 'rpc': 'Verifica si usuario tiene PIN'},
    {'num': 20, 'pant': 'P3_BOVEDA', 'id': 'btn-blindar', 'tipo': 'BOTON_PRIMARIO', 'nom': 'Botón Dorado 🔒 Blindar Bóveda Ahora', 'donde': 'Pie de Alerta Resguardo', 'muestra': 'Blindar Bóveda Ahora', 'rpc': 'Abre Modal #27 y ejecuta esq3_ms_pantalla_3_boveda'},
    {'num': 21, 'pant': 'P3_BOVEDA', 'id': 'bov_saldos_2_col', 'tipo': 'GRID_2_COL', 'nom': 'Tarjetas Billetera Santa (480 pts) y Caducidad PIN (6h)', 'donde': 'Debajo de Alerta', 'muestra': '480 pts | 6 Horas', 'rpc': 'Lee saldo de usuarios_estado'},
    {'num': 22, 'pant': 'P3_BOVEDA', 'id': 'pin-timer-btns', 'tipo': 'SELECTOR_4_CHIPS', 'nom': 'Selector Frecuencia Bloqueo PIN (1h, 6h, 24h, Siempre)', 'donde': 'Centro superior Bóveda', 'muestra': '1 Hora | 6 Horas | 24 Horas | Siempre', 'rpc': 'Cambia frecuencia de bloqueo PIN'},
    {'num': 23, 'pant': 'P3_BOVEDA', 'id': 'bov_qr_holografico', 'tipo': 'TARJETA_QR_VIP', 'nom': 'Tarjeta VIP Holográfica: 1x Polera 2025 (SJ-8821-QR)', 'donde': 'Centro de Pantalla 3', 'muestra': 'QR + SJ-8821-QR + Regenera en 45s', 'rpc': 'Regenera token dinámico cada 45s'},
    {'num': 24, 'pant': 'P3_BOVEDA', 'id': 'btn-show-store', 'tipo': 'BOTON_ACCION', 'nom': 'Botón Azul 🏪 Mostrar en Tienda', 'donde': 'Izquierda bajo QR VIP', 'muestra': 'Mostrar en Tienda', 'rpc': 'Prepara QR para validación óptica'},
    {'num': 25, 'pant': 'P3_BOVEDA', 'id': 'btn-transfer', 'tipo': 'BOTON_ACCION', 'nom': 'Botón 📲 Transferir a Hincha', 'donde': 'Derecha bajo QR VIP', 'muestra': 'Transferir a Hincha', 'rpc': 'Transfiere premio QR a otro carnet'},
    {'num': 26, 'pant': 'P3_BOVEDA', 'id': 'bov_flashlist_3_cupones', 'tipo': 'FLASHLIST_CUPONES', 'nom': 'FlashList Mis Cupones Diarios (3 Activos)', 'donde': 'Abajo en Pantalla 3', 'muestra': 'Pollos SN-772910, Tienda SN-903124, Chopp SN-441029', 'rpc': 'Lista cupones seriados con QR'},
    {'num': 27, 'pant': 'P3_BOVEDA', 'id': 'blindar-modal-form', 'tipo': 'MODAL_FORM', 'nom': 'Modal Blindaje de Bóveda (Input Apodo + PIN 4 Dígitos)', 'donde': 'Popup al tocar Blindar', 'muestra': 'MineroSanto_77 + PIN •••• + Confirmar', 'rpc': 'Encripta billetera en usuarios_estado'},
    {'num': 28, 'pant': 'P4_AUDITORIA', 'id': 'aud_switch_role', 'tipo': 'SELECTOR_MODO', 'nom': 'Switch 🛡️ Admin Central vs 🏪 Tienda Aliada', 'donde': 'Arriba de Pantalla 4', 'muestra': 'Admin Central | Tienda Aliada', 'rpc': 'En modo Tienda oculta Nubes #32 a #36'},
    {'num': 29, 'pant': 'P4_AUDITORIA', 'id': 'aud_inventario_pill', 'tipo': 'CONTADOR_STOCK', 'nom': 'Píldora Inventario Sucursal: Poleras 2024 (14/50)', 'donde': 'Módulo 1 Escáner', 'muestra': '14 / 50 disp.', 'rpc': 'Muestra stock disponible en tienda'},
    {'num': 30, 'pant': 'P4_AUDITORIA', 'id': 'aud_camara_visor_qr', 'tipo': 'CAMARA_QR', 'nom': 'Visor Cámara 4:3 Esquinas Doradas + Token #SJ-9942', 'donde': 'Centro Módulo 1', 'muestra': 'Token #SJ-9942 - Socio Pleno • LISTO', 'rpc': 'Lee QR del socio en sucursal'},
    {'num': 31, 'pant': 'P4_AUDITORIA', 'id': 'burn-btn', 'tipo': 'BOTON_QUEMAR', 'nom': 'Botón Dorado 🔥 Validar y Quemar de la Bóveda (-1 Stock)', 'donde': 'Pie de Módulo 1', 'muestra': 'Validar y Quemar de la Bóveda', 'rpc': 'Ejecuta esq3_ms_pantalla_4_auditoria y resta -1 stock'},
    {'num': 32, 'pant': 'P4_AUDITORIA', 'id': 'aud_tribunal_2_col', 'tipo': 'TRIBUNAL_2_COL', 'nom': 'Tribunal de Comprobantes (Recibo #BNB-88319 vs Socio #1842)', 'donde': 'Módulo 2 Centro', 'muestra': 'Foto Recibo 70 BS con Zoom | Zenón Choque Match 100%', 'rpc': 'Comparador forense de 2 columnas'},
    {'num': 33, 'pant': 'P4_AUDITORIA', 'id': 'btn-reject-approve', 'tipo': 'BOTONES_AUDITORIA', 'nom': 'Botones ❌ Rechazar | ✅ Aprobar (70 BS) + Siguiente Lote', 'donde': 'Pie de Módulo 2', 'muestra': 'Rechazar | Aprobar | Siguiente lote (11 rest.)', 'rpc': 'Aprueba o rechaza comprobante bancario'},
    {'num': 34, 'pant': 'P4_AUDITORIA', 'id': 'aud_inputs_270_70', 'tipo': 'INPUTS_PRECIOS', 'nom': 'Inputs Cuota Inscripción (270 BS) y Mensualidad (70 BS)', 'donde': 'Módulo 3 Gestor', 'muestra': '270 BS | 70 BS', 'rpc': 'Actualiza tarifas oficiales del club'},
    {'num': 35, 'pant': 'P4_AUDITORIA', 'id': 'dice-range-slider', 'tipo': 'SLIDER_DADO', 'nom': 'Slider Probabilidad Dado Minero (1 en 6 = 16.6%)', 'donde': 'Módulo 3 Centro', 'muestra': '1 en 6 (16.6%)', 'rpc': 'Ajusta algoritmo de acierto del dado'},
    {'num': 36, 'pant': 'P4_AUDITORIA', 'id': 'toggle-dual-rule', 'tipo': 'SWITCH_REGLA', 'nom': 'Switch Regla Dual Automática + Botón Actualizar Parámetros', 'donde': 'Pie de Pantalla 4', 'muestra': 'Regla Dual Activa + Guardar', 'rpc': 'Guarda reglas y replica en Parlamento'},
    {'num': 37, 'pant': 'P5_SOCIO', 'id': 'soc_hero_vitalicio', 'tipo': 'TARJETA_HEROE', 'nom': 'Hero Socio Vitalicio #1942 (Quirquincho ID SJ-42901-LP)', 'donde': 'Arriba de Pantalla 5', 'muestra': 'Acreditado Activo • #1942 • SJ-42901-LP', 'rpc': 'Verifica membresía vitalicia'},
    {'num': 38, 'pant': 'P5_SOCIO', 'id': 'soc_tabs_3_modos', 'tipo': 'TABS_SOCIO', 'nom': 'Pestañas: Parlamento (+51%) | Credencial | Sorteos VIP', 'donde': 'Debajo del Hero', 'muestra': '3 Pestañas de Zona Socio', 'rpc': 'Alterna vista interna de socio'},
    {'num': 39, 'pant': 'P5_SOCIO', 'id': 'soc_mocion_08_2025', 'tipo': 'TARJETA_MOCION', 'nom': 'Parlamento Santo: Moción N° 08-2025 (3,420 Socios)', 'donde': 'Sección 1 Parlamento', 'muestra': 'Pregunta Copa 2025 + 3,420 socios habilitados', 'rpc': 'Lee moción activa en asamblea'},
    {'num': 40, 'pant': 'P5_SOCIO', 'id': 'soc_barra_quorum_51', 'tipo': 'GRAFICO_51', 'nom': 'Barra Progreso 51% Quórum (62.4% A Favor = 2,134 votos)', 'donde': 'Centro Parlamento', 'muestra': '62.4% Favor | 18.1% Contra | ¡Moción Aprobada!', 'rpc': 'Exige >= 51% sobre 3,420 socios'},
    {'num': 41, 'pant': 'P5_SOCIO', 'id': 'emit-vote-btn', 'tipo': 'BOTON_VOTO', 'nom': 'Radios A Favor/Contra + Botón 👆 Emitir Voto Certificado', 'donde': 'Pie de Parlamento', 'muestra': 'Emitir Voto Certificado -> Hash 0x9b42...1942SJ', 'rpc': 'Ejecuta esq3_ms_pantalla_5_socio'},
    {'num': 42, 'pant': 'P5_SOCIO', 'id': 'soc_credencial_card', 'tipo': 'CREDENCIAL_VIP', 'nom': 'Credencial Holográfica Alejandro Choque M. + Pase Estadio QR', 'donde': 'Sección 2 Credencial', 'muestra': 'Socio VIP #1942 + Torniquete Puertas 3 y 4', 'rpc': 'Refresca QR de estadio cada 24s'},
    {'num': 43, 'pant': 'P5_SOCIO', 'id': 'soc_estado_cuenta', 'tipo': 'FLASHLIST_PAGOS', 'nom': 'Estado de Cuenta (Inscripción 270 BS + Mensualidad 70 BS)', 'donde': 'Debajo de Credencial', 'muestra': '270 BS Pagado | 70 BS Al Día | Adelantar 70 BS', 'rpc': 'Genera orden de adelanto de cuota'},
    {'num': 44, 'pant': 'P5_SOCIO', 'id': 'btn-ticket-claim', 'tipo': 'BOTON_SORTEO_VIP', 'nom': 'Sorteo Camiseta Firmada + Botón Reclamar Ticket Extra VIP', 'donde': 'Sección 3 Sorteos VIP', 'muestra': 'Tickets #SJ-1942-A/B -> Asigna #SJ-1942-C gratis', 'rpc': 'Inscribe ticket extra gratuito'},
    {'num': 45, 'pant': 'P5_SOCIO', 'id': 'soc_3_cupones_auto', 'tipo': 'FLASHLIST_CUPONES', 'nom': 'FlashList 3 Cupones Diarios Automáticos (Tienda, Café, Gym)', 'donde': 'Pie de Pantalla 5', 'muestra': 'SJ-V25-9941, SJ-PAGADOR-882, SJ-GYM-3011 + Copiar', 'rpc': 'Copia serie de cupón al portapapeles'},
  ];

  static const List _mapasMentalesRoles = [
    {
      'rol': '👤 HINCHA INVITADO\n(El Mirón #89F2A)',
      'color': 0xFFA7C8FF,
      'nubes': [
        '☁️ 1. EXPLORA:\nVe Muro Santo 9:16 y Top 10 sin login (Nubes #1-#5)',
        '☁️ 2. ACUMULA:\nSuma +40 pts temporales en dispositivo #89F2A (Nube #3)',
        '☁️ 3. REACCIONA:\nDa Me Gusta 14.2k -> 14.3k y sigue al Club (Nubes #6-#7)',
        '☁️ 4. LANZA DADO:\nTira el Dado 1-6 y gana +120 pts y cupón (Nubes #8-#9)',
        '☁️ 5. CONSULTA:\nAbre Tooltip anti-rastreo El Mirón (Nube #4)',
        '☁️ 6. SE REGISTRA:\nEn Nube #20 crea Apodo + PIN 4 dígitos y blinda Bóveda',
      ],
    },
    {
      'rol': '🏅 SOCIO VITALICIO #1942\n(Alejandro Choque M.)',
      'color': 0xFFFBB400,
      'nubes': [
        '☁️ 1. CREDENCIAL QR:\nIngresa por Puertas 3 y 4 del Bermúdez (Nube #42)',
        '☁️ 2. VOTA +51%:\nEmite voto digital con Hash 0x9b42 (Nubes #39-#41)',
        '☁️ 3. TRANSFIERE QR:\nEnvía Polera o Cupón a otro hincha (Nubes #23-#25)',
        '☁️ 4. CONFIGURA PIN:\nElige bloqueo cada 1h, 6h, 24h o Siempre (Nube #22)',
        '☁️ 5. PAGA APORTES:\nMantiene al día sus 270 BS y 70 BS/mes (Nube #43)',
        '☁️ 6. RECLAMA VIP:\nObtiene gratis Ticket #SJ-1942-C y 3 cupones (Nubes #44-#45)',
      ],
    },
    {
      'rol': '🏪 TIENDA ALIADA\n(Calle Bolívar / Pollos)',
      'color': 0xFF00C853,
      'nubes': [
        '☁️ 1. MODO TIENDA:\nActiva vista limpia sin datos financieros (Nube #28)',
        '☁️ 2. ESCANEA QR:\nApunta cámara 4:3 al Token #SJ-9942 (Nube #30)',
        '☁️ 3. QUEMA PREMIO:\nValida y quema el QR de la Bóveda (Nube #31)',
        '☁️ 4. DESCUENTA STOCK:\nBaja inventario de 14/50 a 13/50 poleras (Nube #29)',
        '☁️ 5. CANJEA CUPÓN:\nValida series SN-772910 y SN-903124 (Nube #26)',
        '☁️ 6. SINCRONIZA:\nReporta entrega en línea al Nodo Oruro (Nube #28)',
      ],
    },
    {
      'rol': '👑 ADMIN CENTRAL\n(Tribunal y Gestor)',
      'color': 0xFF00509D,
      'nubes': [
        '☁️ 1. REVISA LOTE:\nInspecciona con Zoom los 12 recibos QR (Nube #32)',
        '☁️ 2. APRUEBA 70 BS:\nAcredita mensualidad al Socio #1842 (Nube #33)',
        '☁️ 3. RECHAZA:\nObserva comprobante dudoso y pide reingreso (Nube #33)',
        '☁️ 4. FIJA TARIFAS:\nModifica Inscripción (270 BS) y Cuota (70 BS) (Nube #34)',
        '☁️ 5. CALIBRA DADO:\nAjusta probabilidad del Dado Minero 1-6 (Nube #35)',
        '☁️ 6. REGLA DUAL:\nActiva aprobación inmediata con auditoría (Nube #36)',
      ],
    },
  ];

  String _construirSqlDesdeTiqueo() {
    final String rolesTxt = _rolesTiqueados.join(', ');
    final String condTxt = _condicionesTiqueadas.join(' AND ');
    final String accTxt = _accionesTiqueadas.join(' + ');
    final String respTxt = _respuestasTiqueadas.join(' + ');
    return '''DO \$BODY\$
DECLARE
    v_p JSONB := current_setting('sdui.payload', true)::jsonb;
BEGIN
    -- 1. ROLES HABILITADOS: $rolesTxt
    -- 2. COMPONENTE NUBE DISPARADOR: $_nubeSeleccionada
    -- 3. CONDICIONES VALIDADAS (IF): $condTxt
    -- 4. ACCIÓN EN TABLAS SUPABASE: $accTxt
    INSERT INTO esquema3.api_comunicacion (origen_admin, destino_admin, payload_datos, estado)
    VALUES ('ESQUEMA2_TIQUEO', '$_nubeSeleccionada', v_p, 'EJECUTADO_OK');

    -- 5. RESPUESTA VISUAL EN STITCH: $respTxt
    PERFORM set_config('sdui.resultado_json', jsonb_build_object(
        'exito', true,
        'nube', '$_nubeSeleccionada',
        'mensaje', '✅ Lógica ejecutada en $_nubeSeleccionada: ${_ctrlTextoLibreExtra.text}'
    )::text, true);
END;
\$BODY\$;''';
  }

  Future _guardarTiqueoEnEsquema2() async {
    HapticFeedback.mediumImpact();
    (widget as Ms14StudioPrdRfcPdf).onFeedback('⏳ Guardando PRD y RFC tiqueado en Esquema 2...');
    final res = await PuenteSupabaseSdui.ejecutarRpcUniversal(
      'esq2_rpc_generar_prd_rfc_desde_tiqueo',
      {
        'p_rol': _rolesTiqueados.join(', '),
        'p_nube': _nubeSeleccionada,
        'p_condicion': _condicionesTiqueadas.join(' + '),
        'p_accion': _accionesTiqueadas.join(' + '),
        'p_texto_extra': _ctrlTextoLibreExtra.text.trim(),
      },
      esquemaOverride: 'esquema2',
    );
    (widget as Ms14StudioPrdRfcPdf).onFeedback(res['mensaje']?.toString() ?? '✅ Guardado en Esquema 2.');
  }

  Future _publicarTiqueoHaciaEsquema3() async {
    HapticFeedback.heavyImpact();
    final String sqlGen = _construirSqlDesdeTiqueo();
    final String idAcc = 'ACCION_${_nubeSeleccionada.split('|').first.replaceAll(RegExp(r'[^0-9A-Za-z]'), '')}';
    (widget as Ms14StudioPrdRfcPdf).onFeedback('🚀 Publicando lógica de $_nubeSeleccionada hacia Esquema 3...');
    final res = await PuenteSupabaseSdui.ejecutarRpcUniversal(
      'esq2_rpc_publicar_logica_en_esq3',
      {
        'p_id_accion': idAcc,
        'p_pantalla_origen': _pantallaDestinoNube,
        'p_boton_disparador': _nubeSeleccionada,
        'p_explicacion': 'Creado por Tiqueo: ${_accionesTiqueadas.join(", ")}',
        'p_tablas': 'esquema3.usuarios_estado, esquema3.inventario_premios, esquema3.api_comunicacion',
        'p_sql_dinamico': sqlGen,
      },
      esquemaOverride: 'esquema2',
    );
    (widget as Ms14StudioPrdRfcPdf).onFeedback(res['mensaje']?.toString() ?? '🚀 Publicado en Esquema 3.');
    await (widget as Ms14StudioPrdRfcPdf).onSincronizar();
  }

  @override
  Widget build(BuildContext context) {
    final Map proy = Map.from(_pantallasPrdRfc[_idxPantallaPrd] as Map);
    final List nubesFiltradas = _nubes45Catalogo
        .where((n) => (n as Map)['pant'] == _filtroPantallaNube)
        .toList();
    final Map mapaRol = Map.from(_mapasMentalesRoles[_idxMapaMental] as Map);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
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
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.cloud_done, color: Color(0xFFFBB400), size: 26),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STUDIO SDUI · 24 TABLAS + 45 NUBES',
                            style: TextStyle(color: Color(0xFFFBB400), fontSize: 13, fontWeight: FontWeight.w900),
                          ),
                          Text(
                            'Desliza 👉 para volver a Stitch 1:1 a pantalla completa',
                            style: TextStyle(color: Color(0xFFA9C7FF), fontSize: 10, fontWeight: FontWeight.bold),
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
                    ),
                    icon: const Icon(Icons.picture_as_pdf, size: 15),
                    label: const Text('LIBRO PDF', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900)),
                    onPressed: () {
                      DespachadorAccionesSdui.generarYMostrarLibroPdfMaestro(
                        context: context,
                        tituloPdf: 'Libro Maestro PRD + RFC + 45 Nubes + 24 Tablas (Esquema 2 y 3)',
                        itemsExtra: _nubes45Catalogo.map((n) => '☁️ #${(n as Map)['num']} [${n['pant']}] ${n['nom']} -> ${n['rpc']}').toList(),
                        onFeedback: (widget as Ms14StudioPrdRfcPdf).onFeedback,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: const Color(0xFF030E21), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    _botonSubTab(0, '📘 1. PRD+FOTO'),
                    _botonSubTab(1, '☁️ 2. NUBES #1-45'),
                    _botonSubTab(2, '☑️ 3. TIQUEAR'),
                    _botonSubTab(3, '🧠 4. MAPA MENTAL'),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (_subTab == 0) ...[
          const Text(
            '📱 TOCA UNA DE LAS 5 PANTALLAS DE STITCH PARA VER SU IMAGEN, SU PRD/RFC, SU TRIGGER Y SU MICROSERVICIO RPC:',
            style: TextStyle(color: Color(0xFFA9C7FF), fontSize: 10.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_pantallasPrdRfc.length, (i) {
                final Map it = Map.from(_pantallasPrdRfc[i] as Map);
                final bool sel = _idxPantallaPrd == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      it['pantalla_num'].toString(),
                      style: TextStyle(color: sel ? const Color(0xFF071326) : Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900),
                    ),
                    selected: sel,
                    selectedColor: const Color(0xFFFBB400),
                    backgroundColor: const Color(0xFF142033),
                    onSelected: (_) => setState(() => _idxPantallaPrd = i),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF142033),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFBB400), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proy['titulo'].toString(),
                  style: const TextStyle(color: Color(0xFFFBB400), fontSize: 14, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 175,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        InteractiveViewer(
                          child: Image.network(
                            proy['imagen_diseno'].toString(),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFF030E21),
                              child: const Center(child: Icon(Icons.phone_android, color: Color(0xFFFBB400), size: 48)),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 6,
                          left: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: Colors.black.withAlpha(190), borderRadius: BorderRadius.circular(8)),
                            child: Text(
                              '⚡ Microservicio dedicado: ${proy['rpc_microservicio']}',
                              style: const TextStyle(color: Color(0xFF00FF66), fontSize: 10.5, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _bloqueDetallePrd('☁️ Componentes Numerados en esta Pantalla:', proy['nubes_incluidas'].toString(), const Color(0xFFA9C7FF)),
                _bloqueDetallePrd('📝 ¿Qué Registra en las Tablas de Supabase?:', proy['que_registra_bd'].toString(), const Color(0xFFFFD795)),
                _bloqueDetallePrd('🛡️ ¿Qué Controla / Valida (Condiciones IF)?:', proy['que_controla_if'].toString(), const Color(0xFF00FF66)),
                _bloqueDetallePrd('🔔 Trigger Automático Activo (Esquema 3 -> Esquema 2):', proy['trigger_activo'].toString(), const Color(0xFFFFB4AB)),
                const SizedBox(height: 4),
                const Text('🗺️ Diagrama de Flujo de esta Pantalla (Mermaid):', style: TextStyle(color: Color(0xFFA9C7FF), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF030E21), borderRadius: BorderRadius.circular(8)),
                  child: SelectableText(
                    proy['mermaid'].toString(),
                    style: const TextStyle(color: Color(0xFF00F3FF), fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ],

        if (_subTab == 1) ...[
          const Text(
            '☁️ FILTRA POR PANTALLA Y TOCA CUALQUIER NUBE (#1 AL #45) PARA PROGRAMAR SU LÓGICA POR SU NÚMERO:',
            style: TextStyle(color: Color(0xFFA9C7FF), fontSize: 10.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                {'k': 'P1_MURO', 'lbl': '📺 P1 Muro (#1-#9)'},
                {'k': 'P2_GANADORES', 'lbl': '🎰 P2 Ganadores (#10-#18)'},
                {'k': 'P3_BOVEDA', 'lbl': '🔐 P3 Bóveda (#19-#27)'},
                {'k': 'P4_AUDITORIA', 'lbl': '⚖️ P4 Auditoría (#28-#36)'},
                {'k': 'P5_SOCIO', 'lbl': '🛡️ P5 Socio (#37-#45)'},
              ].map((f) {
                final bool sel = _filtroPantallaNube == f['k'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      f['lbl']!,
                      style: TextStyle(color: sel ? const Color(0xFF071326) : Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900),
                    ),
                    selected: sel,
                    selectedColor: const Color(0xFFFBB400),
                    backgroundColor: const Color(0xFF142033),
                    onSelected: (_) => setState(() => _filtroPantallaNube = f['k']!),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          ...nubesFiltradas.map((item) {
            final Map n = Map.from(item as Map);
            final int numNube = (n['num'] as num).toInt();
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF142033),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFF00F3FF), width: 1.5),
                boxShadow: [BoxShadow(color: const Color(0xFF00F3FF).withAlpha(35), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFBB400),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '☁️ NUBE #$numNube · ${n['tipo']}',
                          style: const TextStyle(color: Color(0xFF071326), fontSize: 10.5, fontWeight: FontWeight.w900),
                        ),
                      ),
                      SelectableText(
                        'ID: ${n['id']}',
                        style: const TextStyle(color: Color(0xFFA9C7FF), fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    n['nom'].toString(),
                    style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text('📍 Dónde está: ${n['donde']}  |  👁️ Qué muestra: ${n['muestra']}', style: const TextStyle(color: Color(0xFFC2C6D3), fontSize: 11)),
                  const SizedBox(height: 3),
                  Text('⚡ Lógica actual: ${n['rpc']}', style: const TextStyle(color: Color(0xFF00FF66), fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFBB400)),
                        backgroundColor: const Color(0xFF030E21),
                      ),
                      icon: const Icon(Icons.check_box_outlined, color: Color(0xFFFBB400), size: 16),
                      label: Text(
                        '🎯 ELEGIR NUBE #$numNube EN EL GENERADOR TIQUEABLE',
                        style: const TextStyle(color: Color(0xFFFBB400), fontSize: 10.5, fontWeight: FontWeight.w900),
                      ),
                      onPressed: () {
                        HapticFeedback.mediumImpact();
                        setState(() {
                          _nubeSeleccionada = '☁️ #$numNube | ${n['id']} (${n['nom']})';
                          _subTab = 2;
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],

        if (_subTab == 2) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF142033),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00C853), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '☑️ GENERADOR DE PRD, RFC Y LÓGICA POR TIQUEO (SIN ADIVINAR CÓDIGO)',
                  style: TextStyle(color: Color(0xFF00C853), fontSize: 12.5, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF030E21),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFFBB400)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('2️⃣ COMPONENTE EN NUBE SELECCIONADO:', style: TextStyle(color: Color(0xFFA9C7FF), fontSize: 10, fontWeight: FontWeight.bold)),
                            Text(_nubeSeleccionada, style: const TextStyle(color: Color(0xFFFBB400), fontSize: 12, fontWeight: FontWeight.w900)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => setState(() => _subTab = 1),
                        child: const Text('CAMBIAR #NUBE', style: TextStyle(color: Color(0xFF00F3FF), fontSize: 10.5, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                _grupoCheckboxes(
                  titulo: '1️⃣ ¿Quién usa este botón o pantalla? (Tiquea):',
                  opciones: const [
                    '👤 Hincha Invitado sin Login (El Mirón #89F2A)',
                    '🏅 Socio Vitalicio / Registrado con PIN (#1942)',
                    '🏪 Cajero de Tienda Aliada (Escáner QR)',
                    '👑 Administrador Central / Tribunal',
                  ],
                  conjuntoActivo: _rolesTiqueados,
                ),
                _grupoCheckboxes(
                  titulo: '3️⃣ ¿Qué condición (IF) debe comprobar antes?:',
                  opciones: const [
                    '🔐 Que el usuario haya ingresado un PIN válido de 4 dígitos',
                    '💰 Que tenga saldo suficiente de puntos (>= 100 pts)',
                    '📦 Que exista stock disponible en la sucursal (> 0 poleras)',
                    '🗳️ Que el Quórum supere el 51% de los 3,420 socios',
                    '🧾 Que el monto del recibo coincida al 100% (70.00 BS)',
                    '✅ Acceso directo sin restricción (Modo Invitado Libre)',
                  ],
                  conjuntoActivo: _condicionesTiqueadas,
                ),
                _grupoCheckboxes(
                  titulo: '4️⃣ ¿Qué acción hace en las tablas de Supabase?:',
                  opciones: const [
                    '📝 Registrar / Actualizar en usuarios_estado (Apodo, PIN y Puntos)',
                    '🎟️ Crear o Transferir premio QR en inventario_premios',
                    '🔥 Quemar QR y descontar -1 del stock en sucursal',
                    '🗳️ Registrar voto certificado con Hash en api_comunicacion',
                    '🎰 Generar boletos cuánticos para el sorteo de las 06:00 AM',
                  ],
                  conjuntoActivo: _accionesTiqueadas,
                ),
                _grupoCheckboxes(
                  titulo: '5️⃣ ¿Qué muestra la pantalla de Stitch al terminar?:',
                  opciones: const [
                    '🎉 Abrir Modal de Celebración (Ej: ¡Ganaste +120 Puntos!)',
                    '🔔 Mostrar Toast Dorado inferior con check de confirmación',
                    '🟢 Cambiar estado del botón a Protegido / Auditado',
                    '📊 Actualizar barra de progreso o contador en tiempo real',
                  ],
                  conjuntoActivo: _respuestasTiqueadas,
                ),
                const Text('✏️ Detalle adicional en tus propias palabras (Opcional):', style: TextStyle(color: Color(0xFFA9C7FF), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                TextField(
                  controller: _ctrlTextoLibreExtra,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF030E21),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 10),
                const Text('💻 CÓDIGO SQL Y CONTRATO GENERADO POR TUS TIQUEOS:', style: TextStyle(color: Color(0xFFFBB400), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF030E21), borderRadius: BorderRadius.circular(8)),
                  child: SelectableText(
                    _construirSqlDesdeTiqueo(),
                    style: const TextStyle(color: Color(0xFF00FF66), fontFamily: 'monospace', fontSize: 10.5),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00509D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.save_alt, size: 16),
                        label: const Text('✨ GUARDAR EN ESQ2', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)),
                        onPressed: _guardarTiqueoEnEsquema2,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFBB400),
                          foregroundColor: const Color(0xFF071326),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.rocket_launch, size: 16),
                        label: const Text('🚀 INYECTAR A ESQ3', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900)),
                        onPressed: _publicarTiqueoHaciaEsquema3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],

        if (_subTab == 3) ...[
          const Text(
            '🧠 SELECCIONA EL USUARIO CENTRAL PARA VER SU MAPA MENTAL DE NUBES (QUÉ REGISTRA, QUÉ QUEMA, QUÉ TRANSFIERE):',
            style: TextStyle(color: Color(0xFFA9C7FF), fontSize: 10.5, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_mapasMentalesRoles.length, (i) {
                final Map m = Map.from(_mapasMentalesRoles[i] as Map);
                final bool sel = _idxMapaMental == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(
                      m['rol'].toString().split('\n').first,
                      style: TextStyle(color: sel ? const Color(0xFF071326) : Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900),
                    ),
                    selected: sel,
                    selectedColor: const Color(0xFFFBB400),
                    backgroundColor: const Color(0xFF142033),
                    onSelected: (_) => setState(() => _idxMapaMental = i),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF030E21),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Color((mapaRol['color'] as num).toInt()), width: 2),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _burbujaNubeMapa((mapaRol['nubes'] as List)[0].toString(), const Color(0xFF00F3FF))),
                    const SizedBox(width: 8),
                    Expanded(child: _burbujaNubeMapa((mapaRol['nubes'] as List)[1].toString(), const Color(0xFF00FF66))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _burbujaNubeMapa((mapaRol['nubes'] as List)[2].toString(), const Color(0xFFFFD795))),
                    Container(
                      width: 125,
                      height: 125,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Color((mapaRol['color'] as num).toInt()),
                            const Color(0xFF142033),
                          ],
                        ),
                        border: Border.all(color: Colors.white, width: 2.5),
                        boxShadow: [
                          BoxShadow(color: Color((mapaRol['color'] as num).toInt()).withAlpha(110), blurRadius: 18),
                        ],
                      ),
                      child: Text(
                        mapaRol['rol'].toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w900),
                      ),
                    ),
                    Expanded(child: _burbujaNubeMapa((mapaRol['nubes'] as List)[3].toString(), const Color(0xFFA9C7FF))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _burbujaNubeMapa((mapaRol['nubes'] as List)[4].toString(), const Color(0xFFFBB400))),
                    const SizedBox(width: 8),
                    Expanded(child: _burbujaNubeMapa((mapaRol['nubes'] as List)[5].toString(), const Color(0xFFFFB4AB))),
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
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }

  Widget _bloqueDetallePrd(String titulo, String contenido, Color col) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF030E21),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: col.withAlpha(90)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: TextStyle(color: col, fontSize: 10.5, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(contenido, style: const TextStyle(color: Color(0xFFD7E3FD), fontSize: 11.5, height: 1.35)),
          ],
        ),
      ),
    );
  }

  Widget _grupoCheckboxes({
    required String titulo,
    required List opciones,
    required Set conjuntoActivo,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(color: Color(0xFFA9C7FF), fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          ...opciones.map((op) {
            final String txt = op.toString();
            final bool marcado = conjuntoActivo.contains(txt);
            return InkWell(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  if (marcado && conjuntoActivo.length > 1) {
                    conjuntoActivo.remove(txt);
                  } else {
                    conjuntoActivo.add(txt);
                  }
                });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  color: marcado ? const Color(0xFF00509D).withAlpha(120) : const Color(0xFF030E21),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: marcado ? const Color(0xFFFBB400) : const Color(0xFF2A3549)),
                ),
                child: Row(
                  children: [
                    Icon(
                      marcado ? Icons.check_box : Icons.check_box_outline_blank,
                      color: marcado ? const Color(0xFFFBB400) : Colors.white54,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        txt,
                        style: TextStyle(
                          color: marcado ? Colors.white : Colors.white70,
                          fontSize: 11,
                          fontWeight: marcado ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _burbujaNubeMapa(String texto, Color colorBorde) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF142033),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorBorde, width: 1.5),
        boxShadow: [BoxShadow(color: colorBorde.withAlpha(40), blurRadius: 8)],
      ),
      child: Text(
        texto,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Color(0xFFD7E3FD), fontSize: 10, fontWeight: FontWeight.w700, height: 1.3),
      ),
    );
  }
}