import 'package:flutter/material.dart';
import 'package:load_more_demo/LoadMore.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo LoadMore'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState2 createState() => _MyHomePageState2();
}

class _MyHomePageState extends State<MyHomePage> {

  var count = 10;

  void loadMore() {
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        count += 10;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: ListView.builder(
          itemCount: count + 1,
          itemBuilder: _buildItem,
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    if (index == count) {
      loadMore();
      return Container(
        width: MediaQuery.of(context).size.width,
        height: 80,
        child: Center(child: Text('正在加载...'),),
      );
    }
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 80,
      child: Center(child: Text(index.toString())),
      decoration: BoxDecoration(
          border: Border(bottom: BorderSide(width: 1, color: Colors.white))
      ),
    );
  }

}

class _MyHomePageState2 extends State<MyHomePage> {

  var count = 10;

  Future<bool> loadMore() async {
    await Future.delayed(Duration(seconds: 2), () {
      setState(() {
        count += 10;
      });
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: LoadMore(
          child: ListView.builder(
            itemCount: count,
            itemBuilder: _buildItem,
          ),
          onLoadMore: loadMore,
          isNoMoreData: false,
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 80,
      child: Center(child: Text(index.toString())),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(width: 1, color: Colors.white))
      ),
    );
  }

}
