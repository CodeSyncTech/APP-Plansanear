import 'package:Redeplansanea/formularios/mapeamentoatores/lista_presenca_mapeamento.dart';
import 'package:Redeplansanea/formularios/presenca/lista_presenca.dart';
import 'package:Redeplansanea/formularios/presenca/todas_respostas.dart';
import 'package:Redeplansanea/formularios/presencacomite/lista_presenca_comite.dart';
import 'package:Redeplansanea/main.dart';
import 'package:Redeplansanea/view/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: AuthScreen(),
      ),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: BottomNavBar(),
      ),
    ),
    GoRoute(
      path: '/formularios',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: AdminScreen(),
      ),
    ),
    GoRoute(
      path: '/:idFormulario',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: ResponderFormularioScreen(
          idFormulario: state.pathParameters['idFormulario']!,
        ),
      ),
    ),
    GoRoute(
      path: '/comite/:idFormulario',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: ResponderFormularioScreenComite(
          idFormulario: state.pathParameters['idFormulario']!,
        ),
      ),
    ),
    GoRoute(
      path: '/mapeamento/:idFormulario',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: ResponderFormularioScreenMapeamento(
          idFormulario: state.pathParameters['idFormulario']!,
        ),
      ),
    ),
  ],
);
