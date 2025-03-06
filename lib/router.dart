import 'package:Redeplansanea/formularios/mapeamentoatores/lista_presenca_mapeamento.dart';
import 'package:Redeplansanea/formularios/presenca/lista_presenca.dart';
import 'package:Redeplansanea/formularios/presenca/todas_respostas.dart';
import 'package:Redeplansanea/formularios/presencacomite/lista_presenca_comite.dart';
import 'package:Redeplansanea/formularios/satisfacao/lista_presenca_satisfacao.dart';
import 'package:Redeplansanea/formularios/votacao/lista_votacao.dart';
import 'package:Redeplansanea/formularios/votacao/respondido_tela_votacao.dart';
import 'package:Redeplansanea/formularios/votacao/todas_votacoes.dart';
import 'package:Redeplansanea/main.dart';

import 'package:Redeplansanea/produtos/produto_a/produto_a.dart';
import 'package:Redeplansanea/respondido_tela.dart';
import 'package:Redeplansanea/view/auth_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        return MaterialPage(
          key: state.pageKey,
          child: user != null ? BottomNavBar() : AuthScreen(),
        );
      },
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        return MaterialPage(
          key: state.pageKey,
          child: user != null ? BottomNavBar() : AuthScreen(),
        );
      },
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) {
        final user = FirebaseAuth.instance.currentUser;
        return MaterialPage(
          key: state.pageKey,
          child: user != null ? BottomNavBar() : AuthScreen(),
        );
      },
    ),
    GoRoute(
      path: '/formularios',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: AdminScreen(),
      ),
    ),
    GoRoute(
      path: '/produtoa',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: ProdutoA_menu(),
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
    GoRoute(
      path: '/pesquisasatisfacao/:idFormulario',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: ResponderFormularioScreenSatisfacao(
          idFormulario: state.pathParameters['idFormulario']!,
        ),
      ),
    ),
    GoRoute(
      path: '/forms/respondido',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: RespondidoScreen(),
      ),
    ),
    GoRoute(
      path: '/forms/respondidoVotacao/:idFormulario',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: RespondidoScreenVotacao(
          idFormulario: state.pathParameters['idFormulario']!,
        ),
      ),
    ),
    GoRoute(
      path: '/votacao/:idFormulario',
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: ResponderFormularioScreenVotacao(
          idFormulario: state.pathParameters['idFormulario']!,
        ),
      ),
    ),
    GoRoute(
      path: '/validacao/formulario_presenca/:uuid',
      builder: (context, state) {
        final uuid = state.pathParameters['uuid']!;
        return VisualizacaoRespostaPage(uuid: uuid);
      },
    ),
    GoRoute(
      path: '/validacao/votacao/:uid',
      builder: (context, state) {
        final uid = state.pathParameters['uid']!;
        return VisualizacaoVotacaoScreen(idFormulario: uid);
      },
    ),
  ],
);
