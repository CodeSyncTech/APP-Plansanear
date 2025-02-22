// pdf_generator.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';

/// Função para mascarar o telefone, mostrando apenas os 4 últimos dígitos.
/// Exemplos:
///   "11987654321" -> "(XX) X XXXX-4321"
///   "21999999999" -> "(XX) X XXXX-9999"
String maskPhoneNumberBrazil(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 11) {
    final last4 = digits.substring(7); // últimos 4 dígitos
    return "(XX) X XXXX-$last4";
  } else if (digits.length == 10) {
    final last4 = digits.substring(6);
    return "(XX) XXXX-$last4";
  } else {
    if (digits.length <= 4) return digits;
    final last4 = digits.substring(digits.length - 4);
    return "(XX) XXXX-$last4";
  }
}

/// Gera o PDF com a formatação da lista de presença, usando Times New Roman (size 13),
/// imagem no cabeçalho, título, município, data e uma tabela com as respostas.
/// Agora também recebe o formId para exibir o UUID ou o link.
Future<Uint8List> generatePdfWithRespostas(
  String formId,
  String cidade,
  String dataCriacao,
  List<Map<String, dynamic>> respostas,
) async {
  // Carrega a fonte Times New Roman do assets (ajuste o caminho conforme seu projeto).
  final fontData = await rootBundle.load('assets/fonts/Times_New_Roman.ttf');
  final timesFont = pw.Font.ttf(fontData);

  // Carrega a imagem do assets.
  final logoBytes = await rootBundle.load('assets/barradelogo.png');
  final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

  final pdf = pw.Document();

  // Separa "cidade" para extrair município e estado (ex: "São Paulo - SP")
  final parts = cidade.split(" - ");
  final municipio = parts.isNotEmpty ? parts[0] : "";
  final estado = parts.length > 1 ? parts[1] : "";

  pdf.addPage(
    pw.MultiPage(
      theme: pw.ThemeData.withFont(
        base: timesFont,
        bold: timesFont,
      ),
      build: (pw.Context context) {
        // Monta as linhas da tabela
        final tableRows = <pw.TableRow>[];

        // Cabeçalho da tabela
        tableRows.add(
          pw.TableRow(
            decoration: const pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              _buildCellHeader('Nome Completo'),
              _buildCellHeader('Telefone'),
              _buildCellHeader('Vínculo (Órgão/Instituição/Setor/Secretaria)'),
            ],
          ),
        );

        // Linhas com os dados das respostas
        for (final resp in respostas) {
          final nome = resp['nomeCompleto'] ?? 'Anônimo';
          final telefoneOriginal = resp['telefone'] ?? 'Não informado';
          final telefoneMascarado = telefoneOriginal == 'Não informado'
              ? telefoneOriginal
              : maskPhoneNumberBrazil(telefoneOriginal);
          final vinculo = resp['vinculo'] ?? 'Não informado';

          tableRows.add(
            pw.TableRow(
              children: [
                _buildCell(nome),
                _buildCell(telefoneMascarado),
                _buildCell(vinculo),
              ],
            ),
          );
        }

        return [
          // Imagem no cabeçalho
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Image(logoImage, width: 500),
            ],
          ),
          pw.SizedBox(height: 16),

          // Título centralizado
          pw.Center(
            child: pw.Text(
              'LISTA DE PRESENÇA – 1ª REUNIÃO TÉCNICA',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(height: 16),

          // Linha com Município e Data
          pw.Row(
            children: [
              pw.Text('MUNICÍPIO: $cidade', style: pw.TextStyle(fontSize: 12)),
              pw.Spacer(),
              pw.Text('DATA: $dataCriacao', style: pw.TextStyle(fontSize: 12)),
            ],
          ),
          pw.SizedBox(height: 18),

          // Linha com o ID do formulário (ou link)

          // Tabela com bordas
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.black,
              width: 0.5,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.4),
              2: const pw.FlexColumnWidth(2.2),
            },
            children: tableRows,
          ),
          pw.SizedBox(height: 16),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 16),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                pw.Spacer(),
                pw.Text(
                    'Verifique a integridade dessa lista de presença: \n https://plansanear.com.br/redeplansanea/v10/#/validacao/formulario_presenca/$formId',
                    style: pw.TextStyle(
                      fontSize: 8,
                    ),
                    textAlign: pw.TextAlign.center),
                pw.Spacer(),
              ],
            ),
          ),
          pw.SizedBox(height: 16),
        ];
      },
    ),
  );

  return pdf.save();
}

/// Auxiliar para criar a célula do cabeçalho (fonte negrito, tamanho 12).
pw.Widget _buildCellHeader(String text) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(4),
    alignment: pw.Alignment.center,
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      textAlign: pw.TextAlign.center,
    ),
  );
}

/// Auxiliar para criar a célula dos dados (fonte tamanho 12).
pw.Widget _buildCell(String text) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(4),
    alignment: pw.Alignment.center,
    child: pw.Text(text, style: const pw.TextStyle(fontSize: 12)),
  );
}

/// Gera e compartilha o PDF com todas as respostas do formulário.
/// O nome do arquivo será: lista_presenca_<municipioSemEspacos>_<estadoSemEspacos>.pdf
Future<void> handleGeneratePdfWithRespostas(
  BuildContext context,
  String formId,
  String cidade,
  String dataCriacao,
) async {
  final respostaSnapshot = await FirebaseFirestore.instance
      .collection('respostas')
      .where('idFormulario', isEqualTo: formId)
      .get();

  final respostas = respostaSnapshot.docs
      .map((doc) => doc.data() as Map<String, dynamic>)
      .toList();

  // Gera o PDF passando também o formId para ser exibido
  final pdfBytes =
      await generatePdfWithRespostas(formId, cidade, dataCriacao, respostas);

  // Monta o nome do arquivo
  final parts = cidade.split(" - ");
  final municipio = parts.isNotEmpty ? parts[0].replaceAll(" ", "") : "";
  final estado = parts.length > 1 ? parts[1].replaceAll(" ", "") : "";
  final fileName = "lista_presenca_${municipio}_$estado.pdf";

  if (kIsWeb) {
    await Printing.sharePdf(bytes: pdfBytes, filename: fileName);
  } else {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/$fileName';
    final file = File(filePath);

    await file.writeAsBytes(pdfBytes);
    await Printing.sharePdf(bytes: pdfBytes, filename: fileName);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF gerado e salvo em: $filePath')),
    );
  }
}
