import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:flutter_easyrefresh/material_header.dart';
import 'package:flutterapp2/pages/stock.dart';
import 'package:flutterapp2/utils/JumpAnimation.dart';
import 'package:flutterapp2/utils/request.dart';



class ChildItemView extends StatefulWidget {
  @override
  _ChildItemView createState() => _ChildItemView();
}

class _ChildItemView extends State<ChildItemView> with AutomaticKeepAliveClientMixin{
  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
  List<Container> table_list = [];
  List dapan_data;
  List<String> containers = ["沪深", "自选"];
  int page = 0;
  int page_ = 1;
  List rank_list = [] ; //龙虎榜
  double screenwidth;
  List<TextStyle> ts = [TextStyle()];
  Future _future;
  @override
  void initState() {
    super.initState();



    _future = getRankList();

  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    screenwidth = MediaQuery.of(context).size.width*0.6;
    return Container(
      child: FutureBuilder(
          future: _future,
          builder: (context, snapshot){
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Center(
                    child: Text('网络请求出错'),
                  );
                }
                return Center(
                  child: EasyRefresh(
                    refreshHeader: MaterialHeader(
                      key: null,
                    ),
                    refreshFooter: MaterialFooter(key: null),
                    child: ListView(
                      children: <Widget>[

                        Container(
                          padding: EdgeInsets.only(left: 15,right: 15),
                          child: Wrap(
                            runSpacing: 10,
                            children: getTableRowList(),
                          ),
                        )
                      ],
                    ),
                    onRefresh: () async {
                      await new Future.delayed(const Duration(seconds: 1), () {
                        setState(() {
                          getRankList();

                        });
                      });
                    },
                    loadMore: null,
                  ),
                );
            }
            return null;
          }
      ),
    );





  }


  List<Container> getTableRowList(){
    int i = 0;
    rank_list.forEach((element) {
      Color cur_color ;
      String diff_rate;
      if(element["diff_rate"]>0.00){
        cur_color = Colors.red;
        diff_rate = "+"+element["diff_rate"].toString();
      }else{
        cur_color = Color(0xff09B971);
        diff_rate = element["diff_rate"].toString();
      }

      if(i>5){
        table_list.add(Container(

          child: Material(
            color: Colors.white,
            child: Ink(
              child: InkWell(
                splashColor: Colors.black26,
                onTap:() {

                  JumpAnimation().jump(stock(element["code"].toString()), context);
                },
                child: Row(

                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: screenwidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.start,
                            direction: Axis.vertical,
                            children: <Widget>[
                              Text(
                                element["name"].toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Row(
                                children: <Widget>[
                                  Text(element["code"].toString(),style: TextStyle(fontSize: 12),),
                                ],
                              )
                            ],
                          ),
                          Container(

                            child: Text(element["nowPrice"].toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                          ),
                        ],
                      ),
                    ),


                    Container(

                      child: Text(diff_rate.toString()+"%",
                          style: TextStyle(
                              color: cur_color,
                              fontWeight: FontWeight.bold,
                              fontSize: 13)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
      }
      i++;
    });
    return table_list;
  }
  Future getRankList() async {
    try{
      String result;
      result = await  request().send_get("/stock/getRankList/"+page_.toString());
      Map parseJson = json.decode(result);
      Map dat1 = json.decode(parseJson["data"]["data"]);
      List list = dat1["showapi_res_body"]["data"]["list"];
      setState(() {
        if(page_ == 1){
          rank_list = list;
          table_list.add(Container(
            child: Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: screenwidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text("名称代码"),
                      Text("最新价格"),
                    ],
                  ),
                ),



                Container(

                  child: Text("涨跌幅"),
                ),
              ],
            ),
          ));
        }else{
          rank_list.addAll(list);
        }

      });
    }catch(e){
      print(e);
    }
  }


  static SlideTransition createTransition(
      Animation<double> animation, Widget child) {
    return new SlideTransition(
      position: new Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: const Offset(0.0, 0.0),
      ).animate(animation),
      child: child, // child is the value returned by pageBuilder
    );
  }

}
