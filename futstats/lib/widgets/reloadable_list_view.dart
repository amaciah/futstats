import 'package:flutter/material.dart';
import 'package:futstats/widgets/empty_reload_message.dart';
import 'package:futstats/widgets/waiting_indicator.dart';

class ReloadableListController<T> {
  late VoidCallback _reloadCallback;

  // Método público para recargar la lista
  void reload() {
    _reloadCallback();
  }

  // Método interno para enlazar la función de recarga con el widget
  void _attach(VoidCallback reloadCallback) {
    _reloadCallback = reloadCallback;
  }
}

class ReloadableListView<T> extends StatefulWidget {
  const ReloadableListView({
    super.key,
    required this.future,
    required this.itemBuilder,
    this.controller,
    this.loadingErrorMessage = 'Se produjo un error al cargar los datos',
    this.emptyListMessage = 'No hay elementos disponibles',
  });

  final Future<List<T>> Function() future;
  final Widget Function(BuildContext context, T) itemBuilder;
  final ReloadableListController<T>? controller;
  final String loadingErrorMessage;
  final String emptyListMessage;

  @override
  State<ReloadableListView<T>> createState() => _ReloadableListViewState<T>();
}

class _ReloadableListViewState<T> extends State<ReloadableListView<T>> {
  late Future<List<T>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _loadItems();

    // Configurar el controlador
    if (widget.controller != null) {
      widget.controller!._attach(_loadItems);
    }
  }

  void _loadItems() {
    setState(() {
      _itemsFuture = widget.future();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: _itemsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const WaitingIndicator();
        }
        if (snapshot.hasError) {
          return EmptyReloadMessage(
            message: widget.loadingErrorMessage,
            reloadAction: _loadItems,
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return EmptyReloadMessage(
            message: widget.emptyListMessage,
            reloadAction: _loadItems,
          );
        }

        final items = snapshot.data!;
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return widget.itemBuilder(context, items[index]);
          },
        );
      },
    );
  }
}
