import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutterfirebase/main.dart';

class FlutterArray extends StatefulWidget {
  const FlutterArray({Key? key}) : super(key: key);

  @override
  State<FlutterArray> createState() => _FlutterArrayState();
}

class _FlutterArrayState extends State<FlutterArray> {
  List<entry> mList = [];
  List<entry> mListData = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New App'),
        actions: [
          IconButton(
              onPressed: () {
                print(mListData.length.toString() + ' mlistdata length');
                showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Container(
                        child: ListView.builder(
                            itemCount: mListData.length,
                            itemBuilder: (context, index) {
                              return Card(
                                child: Text(mListData[index].name ?? ''),
                              );
                            }),
                      );
                    });
              },
              icon: Icon(Icons.list))
        ],
      ),
      body: ListView.builder(
          itemCount: mList.length,
          itemBuilder: (context, index) {
            return Card(
              child: ListTile(
                title: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(mList[index].name ?? ''),
                ),
                trailing:
                    mList[index].status == '1' ? Text('selected') : Text(''),
                onTap: () {
                  print(mList[index].status.toString() + ' status');
                  if (mList[index].status == '0') {
                    setState(() {
                      mList[index].status = '1';
                      mListData.add(entry(mList[index].id, mList[index].name,
                          mList[index].qty, mList[index].rate));
                    });
                  } else {
                    setState(() {
                      mList[index].status = '0';
                      mListData.removeWhere(
                          (element) => element.name == mList[index].name);
                    });
                  }
                },
              ),
            );
          }),
      floatingActionButton: FloatingActionButton(onPressed: () {
        TextEditingController name = TextEditingController();
        TextEditingController qty = TextEditingController();
        TextEditingController rate = TextEditingController();
        var formkey = GlobalKey<FormState>();
        showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                height: 500,
                child: Form(
                    key: formkey,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Enter Name of item'),
                              controller: name,
                            ),
                            TextFormField(
                              decoration:
                                  InputDecoration(hintText: 'Enter Qty'),
                              controller: qty,
                            ),
                            TextFormField(
                              decoration: InputDecoration(
                                  hintText: 'Enter Name of item'),
                              controller: rate,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            InkWell(
                              onTap: () {
                                if (formkey.currentState!.validate()) {
                                  if (name.text.isNotEmpty &&
                                      qty.text.isNotEmpty &&
                                      rate.text.isNotEmpty) {
                                    int i = 0;
                                    setState(() {
                                      mList.add(entry((i++).toString(),
                                          name.text, qty.text, rate.text,
                                          status: '0'));
                                    });
                                    Navigator.pop(context);
                                  } else {
                                    var showsnackbar =
                                        SnackBar(content: Text('Check Above'));
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(showsnackbar);
                                  }
                                }
                              },
                              child: Container(
                                height: 50,
                                width: 100,
                                color: Colors.red,
                                child: Center(child: Text('Submit')),
                              ),
                            )
                          ],
                        ),
                      ),
                    )),
              );
            });
      }),
    );
  }
}
