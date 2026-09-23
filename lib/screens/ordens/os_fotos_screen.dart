import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/session/session_manager.dart';
import '../../models/ordem_servico_foto.dart';

class OsFotosScreen extends StatefulWidget {
  const OsFotosScreen({super.key, required this.ordemUuid, required this.fotos});
  final String ordemUuid;
  final List<OrdemServicoFoto> fotos;
  @override State<OsFotosScreen> createState() => _OsFotosScreenState();
}

class _OsFotosScreenState extends State<OsFotosScreen> {
  static const int limite = 6;
  final _picker = ImagePicker();
  late List<OrdemServicoFoto> _fotos;
  @override void initState() { super.initState(); _fotos = List.of(widget.fotos); }

  Future<void> _adicionar() async {
    if (_fotos.length >= limite) return;
    final origem = await showModalBottomSheet<ImageSource>(context: context, builder: (context) => SafeArea(
      child: Wrap(children: [
        ListTile(leading: const Icon(Icons.photo_camera_outlined), title: const Text('Tirar foto'), onTap: () => Navigator.pop(context, ImageSource.camera)),
        ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Escolher da galeria'), onTap: () => Navigator.pop(context, ImageSource.gallery)),
      ])));
    if (origem == null) return;
    final xfile = await _picker.pickImage(source: origem, imageQuality: 78, maxWidth: 1920, maxHeight: 1920);
    if (xfile == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final pasta = Directory(p.join(dir.path, 'os_fotos', widget.ordemUuid));
    await pasta.create(recursive: true);
    final uuid = const Uuid().v4();
    final ext = p.extension(xfile.path).isEmpty ? '.jpg' : p.extension(xfile.path);
    final destino = p.join(pasta.path, '$uuid$ext');
    await File(xfile.path).copy(destino);
    final agora = DateTime.now();
    if (!mounted) return;
    setState(() => _fotos.add(OrdemServicoFoto(uuid: uuid, empresaUuid: SessionManager.instance.requireEmpresaUuid(), ordemUuid: widget.ordemUuid, caminhoArquivo: destino, ordem: _fotos.length, criadoEm: agora, atualizadoEm: agora)));
  }

  Future<void> _substituir(int index) async {
    final origem = await showModalBottomSheet<ImageSource>(context: context, builder: (context) => SafeArea(
      child: Wrap(children: [
        ListTile(leading: const Icon(Icons.photo_camera_outlined), title: const Text('Tirar nova foto'), onTap: () => Navigator.pop(context, ImageSource.camera)),
        ListTile(leading: const Icon(Icons.photo_library_outlined), title: const Text('Escolher outra da galeria'), onTap: () => Navigator.pop(context, ImageSource.gallery)),
      ])));
    if (origem == null) return;
    final xfile = await _picker.pickImage(source: origem, imageQuality: 78, maxWidth: 1920, maxHeight: 1920);
    if (xfile == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final pasta = Directory(p.join(dir.path, 'os_fotos', widget.ordemUuid));
    await pasta.create(recursive: true);
    final ext = p.extension(xfile.path).isEmpty ? '.jpg' : p.extension(xfile.path);
    final destino = p.join(pasta.path, '${const Uuid().v4()}$ext');
    await File(xfile.path).copy(destino);
    if (!mounted) return;
    setState(() => _fotos[index] = _fotos[index].copyWith(caminhoArquivo: destino, atualizadoEm: DateTime.now(), sincronizado: false));
  }

  Future<void> _abrir(int index) async {
    final foto = _fotos[index];
    final ctrl = TextEditingController(text: foto.descricao ?? '');
    final acao = await showDialog<String>(context: context, builder: (context) => Dialog(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560), child: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [
        AspectRatio(aspectRatio: 4/3, child: InteractiveViewer(child: Image.file(File(foto.caminhoArquivo), fit: BoxFit.contain, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image_outlined, size: 64))))),
        const SizedBox(height: 12),
        TextField(controller: ctrl, maxLength: 100, decoration: const InputDecoration(labelText: 'Descrição da foto (opcional)', hintText: 'Ex.: Vazamento identificado')),
        Wrap(spacing: 8, children: [
          TextButton.icon(onPressed: () => Navigator.pop(context, 'excluir'), icon: const Icon(Icons.delete_outline), label: const Text('Excluir')),
          TextButton.icon(onPressed: () => Navigator.pop(context, 'substituir'), icon: const Icon(Icons.cameraswitch_outlined), label: const Text('Substituir')),
          FilledButton.icon(onPressed: () => Navigator.pop(context, 'salvar'), icon: const Icon(Icons.save_outlined), label: const Text('Salvar descrição')),
        ])
      ])))));
    final descricao = ctrl.text.trim(); ctrl.dispose();
    if (!mounted) return;
    if (acao == 'substituir') {
      await _substituir(index);
    } else if (acao == 'excluir') {
      setState(() { _fotos.removeAt(index); for (var i=0;i<_fotos.length;i++) { _fotos[i] = _fotos[i].copyWith(ordem:i); } });
    } else if (acao == 'salvar') {
      setState(() => _fotos[index] = foto.copyWith(descricao: descricao.isEmpty ? null : descricao, limparDescricao: descricao.isEmpty, atualizadoEm: DateTime.now(), sincronizado: false));
    }
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
    onWillPop: () async {
      Navigator.pop(context, List<OrdemServicoFoto>.of(_fotos));
      return false;
    },
    child: Scaffold(
    appBar: AppBar(title: const Text('Fotos da Ordem de Serviço'), actions: [TextButton(onPressed: () => Navigator.pop(context, List<OrdemServicoFoto>.of(_fotos)), child: const Text('Concluir'))]),
    floatingActionButton: _fotos.length >= limite ? null : FloatingActionButton.extended(onPressed: _adicionar, icon: const Icon(Icons.add_a_photo_outlined), label: const Text('Adicionar foto')),
    body: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Expanded(child: Text('Galeria da OS', style: Theme.of(context).textTheme.titleLarge)), Text('${_fotos.length}/$limite', style: Theme.of(context).textTheme.titleMedium)]),
      const SizedBox(height: 4),
      Text(_fotos.length >= limite ? 'Limite de 6 fotos atingido.' : 'Toque em uma foto para ampliar, descrever ou excluir.'),
      const SizedBox(height: 16),
      Expanded(child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12), itemCount: _fotos.length + (_fotos.length < limite ? 1 : 0), itemBuilder: (context,index) {
        if (index == _fotos.length) return InkWell(onTap: _adicionar, borderRadius: BorderRadius.circular(12), child: Card(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [Icon(Icons.add_a_photo_outlined, size: 42), SizedBox(height: 8), Text('Adicionar foto')]))));
        final foto = _fotos[index];
        return InkWell(onTap: () => _abrir(index), borderRadius: BorderRadius.circular(12), child: Card(clipBehavior: Clip.antiAlias, child: Stack(fit: StackFit.expand, children: [Image.file(File(foto.caminhoArquivo), fit: BoxFit.cover, errorBuilder: (_,__,___)=>const Center(child: Icon(Icons.broken_image_outlined))), Positioned(left:0,right:0,bottom:0,child: Container(padding: const EdgeInsets.all(7), color: Colors.black54, child: Text((foto.descricao ?? '').isEmpty ? 'Foto ${index+1}' : foto.descricao!, maxLines:1, overflow:TextOverflow.ellipsis, style: const TextStyle(color:Colors.white))))])));
      }))
    ]))),
  );
}
