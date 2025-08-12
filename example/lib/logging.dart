import 'package:flutter/material.dart';
import 'package:ft_mobile_agent_flutter/ft_mobile_agent_flutter.dart';

class Logging extends StatefulWidget {

  @override
  _LoggingState createState() => _LoggingState();
}

class _LoggingState extends State<Logging> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Log Output"),
      ),
      body: Column(
        children: <Widget>[
          ListTile(
            title: Text("Log Status: info"),
            onTap: (){
              FTLogger().logging("info log content", FTLogStatus.info,property: {"logger_property": "ft_value"});
            },
          ),
          ListTile(
            title: Text("Log Status: warning"),
            onTap: (){
              FTLogger().logging("warning log content", FTLogStatus.warning);
            },
          ),
          ListTile(
            title: Text("Log Status: error"),
            onTap: (){
              FTLogger().logging("error log content", FTLogStatus.error);
            },
          ),
          ListTile(
            title: Text("Log Status: critical"),
            onTap: (){
              FTLogger().logging("critical log content", FTLogStatus.critical);
            },
          ),
          ListTile(
            title: Text("Log Status: ok"),
            onTap: (){
              FTLogger().logging("ok log content", FTLogStatus.ok);
            },
          )
        ],
      ),
    );
  }
}
