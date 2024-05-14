import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/lists.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Lists> lists = [];
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    refresh();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de Mercado"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showFormModal();
        },
        child: const Icon(Icons.add),
      ),
      body: (lists.isEmpty)
          ? const Center(
              child: Text(
                "Nenhuma lista ainda.\nVamos criar a primeira?",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            )
          : RefreshIndicator(
              onRefresh: () {
                return refresh();
              },
              child: ListView(
                children: List.generate(
                  lists.length,
                  (index) {
                    Lists model = lists[index];
                    return Dismissible(
                      key: ValueKey<Lists>(model),
                      direction: DismissDirection.endToStart,
                      background: Container(
                          color: Colors.red,
                          padding: const EdgeInsets.only(right: 8),
                          alignment: Alignment.centerRight,
                          child: const Icon(Icons.delete, color: Colors.white)),
                      onDismissed: (direction) {
                        remove(model);
                      },
                      child: ListTile(
                        onTap: () {},
                        onLongPress: () {
                          showFormModal(model: model);
                        },
                        leading: const Icon(Icons.list_alt_rounded),
                        title: Text(model.name),
                        subtitle: Text(model.id),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }

  showFormModal({
    Lists? model,
  }) {
    String title = "Adicionar Lista";
    String confirmationButton = "Salvar";
    String skipButton = "Cancelar";

    TextEditingController nameController = TextEditingController();

    if (model != null) {
      title = "Editando ${model.name}";
      nameController.text = model.name;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.all(32.0),
          child: ListView(
            children: [
              Text(title, style: Theme.of(context).textTheme.headline5),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(label: Text("Nome da Lista")),
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(skipButton),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        Lists list = Lists(
                            id: const Uuid().v1(), name: nameController.text);

                        if (model != null) {
                          list.id = model.id;
                        }

                        firestore
                            .collection("lists")
                            .doc(list.id)
                            .set(list.toMap());

                        refresh();

                        Navigator.pop(context);
                      },
                      child: Text(confirmationButton)),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  refresh() async {
    List<Lists> temp = [];
    QuerySnapshot<Map<String, dynamic>> snapshot =
        await firestore.collection("lists").get();

    for (var doc in snapshot.docs) {
      temp.add(Lists.fromMap(doc.data()));
    }

    setState(() {
      lists = temp;
    });
  }

  void remove(Lists model) {
    firestore.collection("lists").doc(model.id).delete();
    refresh();
  }
}
