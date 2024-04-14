import 'package:flutter/material.dart';
import 'package:sqflite_flutter/helper.dart';
import 'home.dart';

abstract class Controller extends State<Home> {
    List<Map<String, dynamic>> journals = [];
    bool isLoading = true;
    
void refreshjournals() async {
    final data = await SQLHelper.getItems();
    setState(() {
      journals = data;
      isLoading = false;
    });
  }
    @override
  void initState() {
    super.initState();
    refreshjournals();
    debugPrint("... number of items ${journals.length}");
  }
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _addItem() async {
   await SQLHelper.createItem(_titleController.text,_descriptionController.text);
   refreshjournals();
   debugPrint('... number of items ${journals.length}');
  }

  // Update an existing journal
  Future<void> updateItem(int id) async {
    await SQLHelper.updateItem(
        id, _titleController.text, _descriptionController.text);
    refreshjournals();
  }

  // Delete an item
  void deleteItem(int id) async {
    await SQLHelper.delete(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully deleted a journal!'),
    ));
    refreshjournals();
  }

  void showForm (int? id) async {
    if(id != null){
      final existingjournal = journals.firstWhere((element) => element["id"] == id);
      _titleController.text = existingjournal['title'];
      _descriptionController.text = existingjournal['title'];
    }
    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
          padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right: 15,
            // this will prevent the soft keyboard from covering the text fields
            bottom: MediaQuery.of(context).viewInsets.bottom + 120,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: 'Title'),
              ),
              box,
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(hintText: 'Description'),
              ),
              box,
              ElevatedButton(
                onPressed: () async {
                  // Save new journal
                  if (id == null) {
                    await _addItem();
                  }
                  if (id != null) {
                    await updateItem(id);
                  }
                  // Clear the text fields
                  _titleController.text = '';
                  _descriptionController.text = '';

                  // Close the bottom sheet
                  Navigator.of(context).pop();
                },
                child: Text(id == null ? 'Create New' : 'Update'),
              )
            ],
          ),
        ));
  }

}

SizedBox box = const SizedBox(height: 20,);