import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatefulWidget {
  DeviceScreen({Key key, @required this.device, @required this.snaps})
      : super(key: key);
  // 장치 정보 전달 받기
  final BluetoothDevice device;
  final snaps;

  @override
  DeviceScreenState createState() => DeviceScreenState();
}

class DeviceScreenState extends State<DeviceScreen> {
  // flutterBlue
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;

  final _wifiSsidController = TextEditingController();
  final _wifiPwController = TextEditingController();

  // 연결 상태 표시 문자열
  String stateText = 'Connecting';

  // 연결 버튼 문자열
  String connectButtonText = 'Disconnect';

  // 현재 연결 상태 저장용
  BluetoothDeviceState deviceState = BluetoothDeviceState.disconnected;

  // 연결 상태 리스너 핸들 화면 종료시 리스너 해제를 위함
  StreamSubscription<BluetoothDeviceState> _stateListener;

  // 연결된 장치의 서비스 정보를 저장하기 위한 변수
  List<BluetoothService> bluetoothService = [];
  //

  Map<String, List<int>> notifyDatas = {};

  @override
  initState() {
    super.initState();
    print(widget.snaps);
    // 상태 연결 리스너 등록
    _stateListener = widget.device.state.listen((event) {
      debugPrint('event :  $event');
      if (deviceState == event) {
        // 상태가 동일하다면 무시
        return;
      }
      // 연결 상태 정보 변경
      setBleConnectionState(event);
    });
    // 연결 시작
    connect();
  }

  @override
  void dispose() {
    // 상태 리스터 해제
    _stateListener?.cancel();
    // 연결 해제
    disconnect();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      // 화면이 mounted 되었을때만 업데이트 되게 함
      super.setState(fn);
    }
  }

  /* 연결 상태 갱신 */
  setBleConnectionState(BluetoothDeviceState event) {
    switch (event) {
      case BluetoothDeviceState.disconnected:
        stateText = 'Disconnected';
        // 버튼 상태 변경
        connectButtonText = 'Connect';
        break;
      case BluetoothDeviceState.disconnecting:
        stateText = 'Disconnecting';
        break;
      case BluetoothDeviceState.connected:
        stateText = 'Connected';
        // 버튼 상태 변경
        connectButtonText = 'Disconnect';
        break;
      case BluetoothDeviceState.connecting:
        stateText = 'Connecting';
        break;
    }
    //이전 상태 이벤트 저장
    deviceState = event;
    setState(() {});
  }

  /* 연결 시작 */
  Future<bool> connect() async {
    Future<bool> returnValue;
    setState(() {
      /* 상태 표시를 Connecting으로 변경 */
      stateText = 'Connecting';
    });

    /* 
      타임아웃을 10초(10000ms)로 설정 및 autoconnect 해제
      참고로 autoconnect가 true되어있으면 연결이 지연되는 경우가 있음.
     */
    await widget.device
        .connect(autoConnect: false)
        .timeout(Duration(milliseconds: 15000), onTimeout: () {
      //타임아웃 발생
      //returnValue를 false로 설정
      returnValue = Future.value(false);
      debugPrint('timeout failed');

      //연결 상태 disconnected로 변경
      setBleConnectionState(BluetoothDeviceState.disconnected);
    }).then((data) async {
      bluetoothService.clear();
      if (returnValue == null) {
        //returnValue가 null이면 timeout이 발생한 것이 아니므로 연결 성공
        debugPrint('connection successful');
        List<BluetoothService> bleServices =
            await widget.device.discoverServices();
        setState(() {
          bluetoothService = bleServices;
        });
        // 각 속성을 디버그에 출력
        for (BluetoothService service in bleServices) {
          for (BluetoothCharacteristic c in service.characteristics) {
            if (c.properties.notify && c.descriptors.isNotEmpty) {
              // 진짜 0x2902 가 있는지 단순 체크용!
              for (BluetoothDescriptor d in c.descriptors) {
                print('BluetoothDescriptor uuid ${d.uuid}');
                if (d.uuid == BluetoothDescriptor.cccd) {
                  print('d.lastValue: ${d.lastValue}');
                }
              }

              // notify가 설정 안되었다면...
              if (!c.isNotifying) {
                try {
                  await c.setNotifyValue(true);
                  // 받을 데이터 변수 Map 형식으로 키 생성
                  notifyDatas[c.uuid.toString()] = List.empty();
                  c.value.listen((value) {
                    // 데이터 읽기 처리!
                    print('${c.uuid}: $value');
                    setState(() {
                      // 받은 데이터 저장 화면 표시용
                      notifyDatas[c.uuid.toString()] = value;
                    });
                  });

                  // 설정 후 일정시간 지연
                  await Future.delayed(const Duration(milliseconds: 500));
                } catch (e) {
                  print('error ${c.uuid} $e');
                }
              }
            }
          }
        }
        returnValue = Future.value(true);
      }
    });

    return returnValue ?? Future.value(false);
  }

  /* 연결 해제 */
  void disconnect() {
    try {
      setState(() {
        stateText = 'Disconnecting';
      });
      widget.device.disconnect();
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        /* 장치명 */
        title: Text(widget.device.name),
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              /* 연결 상태 */
              Text('$stateText'),
              /* 연결 및 해제 버튼 */
              OutlinedButton(
                  onPressed: () {
                    if (deviceState == BluetoothDeviceState.connected) {
                      /* 연결된 상태라면 연결 해제 */
                      disconnect();
                    } else if (deviceState ==
                        BluetoothDeviceState.disconnected) {
                      /* 연결 해재된 상태라면 연결 */
                      connect();
                    } else {}
                  },
                  child: Text(connectButtonText)),
            ],
          ),
          /* 연결된 BLE의 서비스 정보 출력 */
          Expanded(
            child:
                // listItem(bluetoothService[3])
                ListView.separated(
              itemCount: bluetoothService.length,
              itemBuilder: (context, index) {
                return listItem(bluetoothService[index]);
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
            ),
          ),
        ],
      )),
    );
  }

  ButtonTheme _buildReadWriteNotifyButton(
      BluetoothCharacteristic characteristic) {
    // BluetoothDescriptor descriptors){
    return ButtonTheme(
      minWidth: 10,
      height: 20,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: RaisedButton(
          child: Text('WRITE', style: TextStyle(color: Colors.white)),
          onPressed: () async {
            await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Write"),
                    content: Column(
                      children: <Widget>[
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Wifi Id',
                          ),
                          controller: _wifiSsidController,
                        ),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Wifi Pw',
                          ),
                          controller: _wifiPwController,
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Send"),
                        onPressed: () async {
                          log(widget.snaps);
                          log(_wifiSsidController.value.text);
                          log(_wifiPwController.value.text);
                          // ignore: prefer_interpolation_to_compose_strings
                          // await descriptors.write(utf8.encode('{"w_id":"' +
                          await characteristic.write(utf8.encode('{"w_id":"' +
                              _wifiSsidController.value.text +
                              '","w_pw":"' +
                              _wifiPwController.value.text +
                              '","p_id":"' +
                              widget.snaps));
                          Future.delayed(Duration(milliseconds: 500));
                          // characteristic.write(utf8.encode('`"p_iid":"' +
                          //     widget.snaps +
                          //     '","p_id":"' +
                          //     widget.userid));
                          Navigator.pop(context);
                        },
                      ),
                      FlatButton(
                        child: Text("Cancel"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                });
          },
        ),
      ),
    );
  }

  /* 각 캐릭터리스틱 정보 표시 위젯 */
  Widget characteristicInfo(BluetoothService r) {
    String name = '';
    String properties = '';
    ButtonTheme btn;
    // 캐릭터리스틱을 한개씩 꺼내서 표시
    for (BluetoothCharacteristic c in r.characteristics) {
      properties = '';

      name += '\t\t${c.uuid}\n';
      if (c.properties.write) {
        properties += 'Write ';
        name += '\t\t\tProperties: $properties\n';
        btn = _buildReadWriteNotifyButton(c);
        // c.write(utf8.encode(_writeController.value.text));
      }
      // if (c.properties.read) {
      //   properties += 'Read ';
      // }
      // if (c.properties.notify) {
      //   properties += 'Notify ';
      //   if (notifyDatas.containsKey(c.uuid.toString())) {
      //     // notify 데이터가 존재한다면
      //   }
      // }
      // if (c.properties.writeWithoutResponse) {
      //   properties += 'WriteWR ';
      // }
      // if (c.properties.indicate) {
      //   properties += 'Indicate ';
      // }
    }
    return btn;
  }

  /* Service UUID 위젯  */
  Widget serviceUUID(BluetoothService r) {
    String name = '';
    name = r.uuid.toString();
    return Text(name);
  }

  /* Service 정보 아이템 위젯 */
  Widget listItem(BluetoothService r) {
    return ListTile(
      onTap: null,
      title: serviceUUID(r),
      subtitle: characteristicInfo(r),
    );
  }
}
