import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:my_list2/layout.dart';
import 'package:my_list2/application.dart';
import 'package:my_list2/pages/item-edit.dart';
import 'package:my_list2/pages/items.dart';
import 'package:my_list2/models/Item.dart';

class ItemsList extends StatefulWidget {

  final List<Map> items;
  final String filter;
  final ItemsListBloc itemsListBloc;

  const ItemsList({Key key, this.items, this.filter, this.itemsListBloc}) : super(key: key);

  @override
  _ItemsListState createState() => _ItemsListState();
}

class _ItemsListState extends State<ItemsList> {

  @override
  Widget build(BuildContext context) {

    // Item default
    if (widget.items.isEmpty) {
      return ListView(children: <Widget>[
        ListTile(title: Text('Nenhum item para exibir ainda'))
      ]);
    }

    // The list after filter apply
    List<Map> filteredList = List<Map>();

    // There is some filter?
    if (widget.filter.isNotEmpty) {
      for (dynamic item in widget.items) {

        // Check if theres this filter in the current item
        String name = item['name'].toString().toLowerCase();
        if (name.contains(widget.filter.toLowerCase())) {
          filteredList.add(item);
        }
      }
    } else {
      filteredList.addAll(widget.items);
    }
  
    // Empty after filters
    if (filteredList.isEmpty) {
      return ListView(children: <Widget>[
        ListTile(title: Text('Nenhum item encontrado...'))
      ]);
    }

    // Instancia model
    ModelItem itemBo = ModelItem();

    return ListView.builder(
      itemCount: filteredList.length,
      itemBuilder: (BuildContext context, int i) {

        Map item = filteredList[i];

        double realVal =currencyToDouble(item['valor']);
        String valTotal = doubleToCurrency(realVal * item['quantidade']);

        return Slidable(
          delegate: SlidableDrawerDelegate(),
          actionExtentRatio: 0.2,
          closeOnScroll: true,
          child: ListTile(
            leading: GestureDetector(
              child: Icon(
                ((item['checked'] == 1) ? Icons.check_box : Icons.check_box_outline_blank),
                color: ((item['checked'] == 0) ? Layout.info() : Layout.success()),
                size: 42
              ),
              onTap: () {
                itemBo.update({ 'checked': !(item['checked'] == 1) }, item['pk_item']).then((bool updated) {
                  if (updated) {
                    widget.itemsListBloc.getList();
                  }
                });
                print('Marcar como adquirido');
              },
            ),
            title: Text(item['name']),
            subtitle: Text('${item['quantidade']} X ${item['valor']} = $valTotal'),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: 'Editar',
              icon: Icons.edit,
              color: Colors.black45,
              onTap: () {
                
                itemBo.getItem(item['pk_item']).then((Map i) {

                  // Adiciona dados do item a pagina
                  ItemEditPage.item = i;

                  // Abre a pagina
                  Navigator.of(context).pushNamed(ItemEditPage.tag);
                });
              },
            ),
            IconSlideAction(
              caption: 'Deletar',
              icon: Icons.delete,
              color: Colors.red,
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: Text('Tem certeza?'),
                      content: Text('Esta ação irá remover o item selecionado e não poderá ser desfeita'),
                      actions: <Widget>[
                        RaisedButton(
                          color: Layout.secondary(),
                          child: Text('Cancelar', style: TextStyle(color: Layout.light())),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                        ),
                        RaisedButton(
                          color: Layout.danger(),
                          child: Text('Remover', style: TextStyle(color: Layout.light())),
                          onPressed: () {
                            itemBo.delete(item['pk_item']);

                            Navigator.of(ctx).pop();
                            widget.itemsListBloc.getList();
                          }
                        )
                      ],
                    );
                  }
                );
              },
            )
          ],
        );
      }
    );
  }
}