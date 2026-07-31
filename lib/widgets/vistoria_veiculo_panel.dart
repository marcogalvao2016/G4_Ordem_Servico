import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/utils/uppercase_text_formatter.dart';
import '../models/item_atendimento.dart';
import '../models/vistoria_veiculo.dart';

class VistoriaVeiculoPanel extends StatefulWidget {
  const VistoriaVeiculoPanel({super.key,required this.initial,required this.item,required this.onChanged});
  final VistoriaVeiculo initial;
  final ItemAtendimento? item;
  final ValueChanged<VistoriaVeiculo> onChanged;
  @override State<VistoriaVeiculoPanel> createState()=>_VistoriaVeiculoPanelState();
}

class _VistoriaVeiculoPanelState extends State<VistoriaVeiculoPanel>{
  late VistoriaVeiculo v;
  late final TextEditingController motorista,local,destino,km,outro,obs;
  static const tipos=['Plataforma hidráulica','Táxi','Guincho leve','Guincho pesado','Munck','Plataforma/caminhão'];
  static const motivos=['Acidente','Pane','Alternador','Injeção eletrônica','Correia dentada','Arrefecimento','Coleta','Roubo','Bateria','Combustível','Pneu','Motor/suspensão'];
  static const acessorios=['Bagageiro','Retrovisor','Farol lateral','Brake light','Faróis auxiliares','Calotas','Rodas de aço','Rodas de liga leve','Chaves de ignição','Documentos','Antena','Rádio / MP3','Bancos','Alto-falantes','Amplificador','Console interno','Tapetes','Tampão traseiro','Airbag','Extintor','Estepe','Macaco','Triângulo','Chave de roda','Alarme','Câmera / protetor'];
  static const areas=['Frente','Traseira','Lateral esquerda','Lateral direita','Capô','Teto','Porta-malas','Para-choque dianteiro','Para-choque traseiro'];
  static const tiposDano=['Arranhado','Amassado','Quebrado','Trincado','Pintura danificada','Outro'];

  @override void initState(){super.initState();v=widget.initial;motorista=TextEditingController(text:v.nomeMotorista);local=TextEditingController(text:v.local);destino=TextEditingController(text:v.destino);km=TextEditingController(text:v.km);outro=TextEditingController(text:v.outroMotivo);obs=TextEditingController(text:v.observacoes);}
  @override void dispose(){for(final c in [motorista,local,destino,km,outro,obs]){c.dispose();}super.dispose();}
  void emit(VistoriaVeiculo n){v=n.copyWith(atualizadoEm:DateTime.now(),sincronizado:false);widget.onChanged(v);}
  InputDecoration dec(String label)=>InputDecoration(labelText:label,border:const OutlineInputBorder());

  Future<void> addDano() async {
    String area = areas.first;
    String tipo = tiposDano.first;
    final detalhe = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Registrar dano ou avaria'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: area,
                  items: areas
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (x) {
                    if (x != null) {
                      setD(() => area = x);
                    }
                  },
                  decoration: dec('Área do veículo'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: tipo,
                  items: tiposDano
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(e),
                        ),
                      )
                      .toList(),
                  onChanged: (x) {
                    if (x != null) {
                      setD(() => tipo = x);
                    }
                  },
                  decoration: dec('Tipo de dano'),
                ),
                const SizedBox(height: 12),
                TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], 
                  controller: detalhe,
                  decoration: dec('Detalhes'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.pop(ctx, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                Navigator.pop(ctx, true);
              },
              child: const Text('Adicionar'),
            ),
          ],
        ),
      ),
    );

    final detalheInformado = detalhe.text.trim();

    // Aguarda o fechamento completo do diálogo e a liberação do foco
    // antes de destruir o controller.
    await WidgetsBinding.instance.endOfFrame;
    detalhe.dispose();

    if (!mounted) return;

    if (ok == true) {
      setState(() {
        emit(
          v.copyWith(
            danos: [
              ...v.danos,
              {
                'area': area,
                'tipo': tipo,
                'detalhe': detalheInformado,
              },
            ],
          ),
        );
      });
    }
  }

  Widget sec(String title,List<Widget> children)=>Card(margin:const EdgeInsets.only(bottom:12),child:ExpansionTile(initiallyExpanded:title=='Identificação do veículo',title:Text(title,style:const TextStyle(fontWeight:FontWeight.bold)),children:[Padding(padding:const EdgeInsets.fromLTRB(16,0,16,16),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:children))]));
  @override Widget build(BuildContext context){final item=widget.item;return Column(children:[
    sec('Identificação do veículo',[Text('Veículo: ${item?.descricao ?? '-'}'),const SizedBox(height:6),Text('Marca: ${item?.marca ?? '-'}  •  Modelo: ${item?.modelo ?? '-'}'),const SizedBox(height:6),Text('Ano: ${item?.ano ?? '-'}  •  Cor: ${item?.cor ?? '-'}  •  Placa: ${item?.placa ?? '-'}'),const SizedBox(height:12),TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], controller:motorista,onChanged:(x)=>emit(v.copyWith(nomeMotorista:x)),decoration:dec('Nome do motorista')),const SizedBox(height:12),Row(children:[Expanded(child:TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], controller:local,onChanged:(x)=>emit(v.copyWith(local:x)),decoration:dec('Local'))),const SizedBox(width:8),Expanded(child:TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], controller:destino,onChanged:(x)=>emit(v.copyWith(destino:x)),decoration:dec('Destino')))]),const SizedBox(height:12),TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], controller:km,keyboardType:TextInputType.number,onChanged:(x)=>emit(v.copyWith(km:x)),decoration:dec('Quilometragem'))]),
    sec('Tipo de atendimento',[Wrap(spacing:8,runSpacing:4,children:tipos.map((e)=>FilterChip(label:Text(e),selected:v.tiposAtendimento.contains(e),onSelected:(s){final n=[...v.tiposAtendimento];s?n.add(e):n.remove(e);setState(()=>emit(v.copyWith(tiposAtendimento:n)));})).toList())]),
    sec('Motivo da chamada',[Wrap(spacing:8,runSpacing:4,children:motivos.map((e)=>FilterChip(label:Text(e),selected:v.motivos.contains(e),onSelected:(s){final n=[...v.motivos];s?n.add(e):n.remove(e);setState(()=>emit(v.copyWith(motivos:n)));})).toList()),const SizedBox(height:12),TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], controller:outro,onChanged:(x)=>emit(v.copyWith(outroMotivo:x)),decoration:dec('Outros'))]),
    sec('Danos ou avarias na retirada',[Container(height:130,decoration:BoxDecoration(border:Border.all(color:Theme.of(context).colorScheme.outlineVariant),borderRadius:BorderRadius.circular(12)),child:const Center(child:Column(mainAxisSize:MainAxisSize.min,children:[Icon(Icons.directions_car_filled_outlined,size:72),Text('Selecione a região e registre a avaria')]))),const SizedBox(height:8),FilledButton.icon(onPressed:addDano,icon:const Icon(Icons.add_location_alt_outlined),label:const Text('Adicionar dano')),for(int i=0;i<v.danos.length;i++) ListTile(contentPadding:EdgeInsets.zero,leading:const Icon(Icons.warning_amber_rounded),title:Text('${v.danos[i]['area']} — ${v.danos[i]['tipo']}'),subtitle:(v.danos[i]['detalhe']??'').isEmpty?null:Text(v.danos[i]['detalhe']!),trailing:IconButton(onPressed:(){final n=[...v.danos]..removeAt(i);setState(()=>emit(v.copyWith(danos:n)));},icon:const Icon(Icons.delete_outline)))]),
    sec('Estado dos pneus',[for(final p in {'dianteiro_esquerdo':'Dianteiro esquerdo','dianteiro_direito':'Dianteiro direito','traseiro_esquerdo':'Traseiro esquerdo','traseiro_direito':'Traseiro direito','estepe':'Estepe'}.entries) Padding(padding:const EdgeInsets.only(bottom:8),child:DropdownButtonFormField<String>(value:v.pneus[p.key],decoration:dec(p.value),items:['Bom','Médio','Ruim'].map((e)=>DropdownMenuItem(value:e,child:Text(e))).toList(),onChanged:(x){final n={...v.pneus};if(x!=null)n[p.key]=x;setState(()=>emit(v.copyWith(pneus:n)));}))]),
    sec('Combustível',[Text('${v.combustivel}% do tanque',textAlign:TextAlign.center),Slider(value:v.combustivel.toDouble(),min:0,max:100,divisions:4,label:'${v.combustivel}%',onChanged:(x)=>setState(()=>emit(v.copyWith(combustivel:x.round())))),const Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('Reserva'),Text('1/4'),Text('1/2'),Text('3/4'),Text('Cheio')])]),
    sec('Acessórios e equipamentos',[const Text('S = existente, N = não existente, I = incompleto ou avariado'),const SizedBox(height:8),for(final a in acessorios) Padding(padding:const EdgeInsets.only(bottom:8),child:Row(children:[Expanded(child:Text(a)),SegmentedButton<String>(segments:const [ButtonSegment(value:'S',label:Text('S')),ButtonSegment(value:'N',label:Text('N')),ButtonSegment(value:'I',label:Text('I'))],selected:{v.acessorios[a]??'N'},onSelectionChanged:(x){final n={...v.acessorios,a:x.first};setState(()=>emit(v.copyWith(acessorios:n)));})]))]),
    sec('Declarações e observações',[CheckboxListTile(contentPadding:EdgeInsets.zero,value:v.proprietarioOrientado,title:const Text('O proprietário foi orientado a retirar os pertences do veículo.'),onChanged:(x)=>setState(()=>emit(v.copyWith(proprietarioOrientado:x??false)))),CheckboxListTile(contentPadding:EdgeInsets.zero,value:v.patioCiente,title:const Text('Ciente de que o veículo removido para o pátio poderá gerar cobrança de diárias.'),onChanged:(x)=>setState(()=>emit(v.copyWith(patioCiente:x??false)))),TextField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], controller:obs,minLines:3,maxLines:6,onChanged:(x)=>emit(v.copyWith(observacoes:x)),decoration:dec('Observações'))]),
    sec('Segurado ou beneficiário',[TextFormField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], initialValue:v.seguradoNome,onChanged:(x)=>emit(v.copyWith(seguradoNome:x)),decoration:dec('Nome')),const SizedBox(height:8),TextFormField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], initialValue:v.seguradoRg,onChanged:(x)=>emit(v.copyWith(seguradoRg:x)),decoration:dec('RG')),const SizedBox(height:8),TextFormField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], initialValue:v.seguradoAssinatura,onChanged:(x)=>emit(v.copyWith(seguradoAssinatura:x)),decoration:dec('Assinatura / confirmação'))]),
    sec('Destinatário',[TextFormField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], initialValue:v.destinatarioNome,onChanged:(x)=>emit(v.copyWith(destinatarioNome:x)),decoration:dec('Nome')),const SizedBox(height:8),TextFormField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], initialValue:v.destinatarioRg,onChanged:(x)=>emit(v.copyWith(destinatarioRg:x)),decoration:dec('RG')),const SizedBox(height:8),TextFormField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], initialValue:v.destinatarioAssinatura,onChanged:(x)=>emit(v.copyWith(destinatarioAssinatura:x)),decoration:dec('Assinatura / confirmação'))]),
    sec('Prestador',[TextFormField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], initialValue:v.prestadorNome,onChanged:(x)=>emit(v.copyWith(prestadorNome:x)),decoration:dec('Nome')),const SizedBox(height:8),TextFormField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], initialValue:v.prestadorRg,onChanged:(x)=>emit(v.copyWith(prestadorRg:x)),decoration:dec('RG')),const SizedBox(height:8),TextFormField(inputFormatters: const <TextInputFormatter>[upperCaseTextFormatter], initialValue:v.prestadorAssinatura,onChanged:(x)=>emit(v.copyWith(prestadorAssinatura:x)),decoration:dec('Assinatura / confirmação'))]),
  ]);}
}
