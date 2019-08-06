import 'dart:async';

import 'package:flutter/material.dart';

typedef Future<bool> OnLoadMoreCallback();

enum LoadMoreStatus { idle, loading, fail, noMoreData }

class BuildNotification extends Notification {}
class RetryNotification extends Notification {}

class LoadMore extends StatefulWidget {

  final ListView child;

  final OnLoadMoreCallback onLoadMore;

  final bool isNoMoreData;

  const LoadMore({
    Key key,
    @required this.child,
    @required this.onLoadMore,
    this.isNoMoreData = false,
  }) : assert (child != null), super(key: key);

  @override
  _LoadMoreState createState() => _LoadMoreState();
}

class _LoadMoreState extends State<LoadMore> {

  LoadMoreStatus status = LoadMoreStatus.idle;

  Widget get child => widget.child;

  @override
  Widget build(BuildContext context) {
    if (widget.onLoadMore == null) {
      return child;
    }
    return _buildListView(child);
  }

  Widget _buildListView(ListView listView) {
    var delegate = listView.childrenDelegate;
    outer:
    if (delegate is SliverChildBuilderDelegate) {
      SliverChildBuilderDelegate delegate = listView.childrenDelegate;
      if (delegate.estimatedChildCount == 0) {
        break outer;
      }
      var viewCount = delegate.estimatedChildCount + 1;
      IndexedWidgetBuilder builder = (context, index) {
        if (index == viewCount - 1) {
          return _buildLoadMoreView();
        }
        return delegate.builder(context, index);
      };

      return ListView.builder(
        itemBuilder: builder,
        addAutomaticKeepAlives: delegate.addAutomaticKeepAlives,
        addRepaintBoundaries: delegate.addRepaintBoundaries,
        addSemanticIndexes: delegate.addSemanticIndexes,
        dragStartBehavior: listView.dragStartBehavior,
        semanticChildCount: listView.semanticChildCount,
        itemCount: viewCount,
        cacheExtent: listView.cacheExtent,
        controller: listView.controller,
        itemExtent: listView.itemExtent,
        key: listView.key,
        padding: listView.padding,
        physics: listView.physics,
        primary: listView.primary,
        reverse: listView.reverse,
        scrollDirection: listView.scrollDirection,
        shrinkWrap: listView.shrinkWrap,
      );
    } else if (delegate is SliverChildListDelegate) {
      SliverChildListDelegate delegate = listView.childrenDelegate;

      if (delegate.estimatedChildCount == 0) {
        break outer;
      }

      delegate.children.add(_buildLoadMoreView());
      return ListView(
        children: delegate.children,
        addAutomaticKeepAlives: delegate.addAutomaticKeepAlives,
        addRepaintBoundaries: delegate.addRepaintBoundaries,
        cacheExtent: listView.cacheExtent,
        controller: listView.controller,
        itemExtent: listView.itemExtent,
        key: listView.key,
        padding: listView.padding,
        physics: listView.physics,
        primary: listView.primary,
        reverse: listView.reverse,
        scrollDirection: listView.scrollDirection,
        shrinkWrap: listView.shrinkWrap,
        addSemanticIndexes: delegate.addSemanticIndexes,
        dragStartBehavior: listView.dragStartBehavior,
        semanticChildCount: listView.semanticChildCount,
      );
    }
    return listView;
  }

  Widget _buildLoadMoreView() {
    if (widget.isNoMoreData == true) {
      this.status = LoadMoreStatus.noMoreData;
    } else {
      if (this.status == LoadMoreStatus.noMoreData) {
        this.status = LoadMoreStatus.idle;
      }
    }
    return NotificationListener<RetryNotification>(
      child: NotificationListener<BuildNotification>(
        child: LoadMoreView(status: status),
        onNotification: (_buildNotification) {
          if (status == LoadMoreStatus.idle) {
            loadMore();
          }
          return false;
        },
      ),
      onNotification: (_retryNotification) {
        loadMore();
        return false;
      },
    );
  }

  void _updateStatus(LoadMoreStatus status) {
    setState(() {
      this.status = status;
    });
  }

  void loadMore() {
    _updateStatus(LoadMoreStatus.loading);
    widget.onLoadMore().then((v) {
      if (v == true) {
        _updateStatus(LoadMoreStatus.idle);
      } else {
        _updateStatus(LoadMoreStatus.fail);
      }
    });
  }
}

class LoadMoreView extends StatefulWidget {
  final LoadMoreStatus status;
  const LoadMoreView({
    Key key,
    this.status = LoadMoreStatus.idle
  }) : super(key: key);

  @override
  _LoadMoreViewState createState() => _LoadMoreViewState();
}

class _LoadMoreViewState extends State<LoadMoreView> {

  @override
  Widget build(BuildContext context) {
    notify();
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        if (widget.status == LoadMoreStatus.fail ||
            widget.status == LoadMoreStatus.idle) {
          RetryNotification().dispatch(context);
        }
      },
      child: Container(
        height: 80.0,
        alignment: Alignment.center,
        child: Center(child: Text(_buildText(widget.status))),
      ),
    );
  }

  void notify() async {
    await Future.delayed(Duration(milliseconds: 16));
    if (widget.status == LoadMoreStatus.idle) {
      BuildNotification().dispatch(context);
    }
  }

  String _buildText(LoadMoreStatus status) {
    String text;
    switch (status) {
      case LoadMoreStatus.fail:
        text = "加载失败，请点击重试";
        break;
      case LoadMoreStatus.idle:
        text = "等待加载";
        break;
      case LoadMoreStatus.loading:
        text = "正在加载...";
        break;
      case LoadMoreStatus.noMoreData:
        text = "没有更多数据加载了";
        break;
      default:
        text = "";
    }
    return text;
  }
}


