import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_singmulwon_app/Community/screens/community_home_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import '../provider/Users.dart';

class CommunityWriteForm extends StatefulWidget {
  @override
  State<CommunityWriteForm> createState() => _CommunityWriteFormState();
}

class _CommunityWriteFormState extends State<CommunityWriteForm> {
  var _cData;
  var _userid;
  List _cImageData= [];
  bool isPicked=false;

  String baseUrl = dotenv.env['BASE_URL'];


  @override
  void initState(){
    super.initState();
    Future.delayed(Duration.zero, () {
      final arguments = (ModalRoute.of(context).settings.arguments ?? <String, dynamic>{}) as Map;
      _cData = arguments['data'];

      if (_cData!=null){
        print(_cData);
        _titleController.text = _cData.title;
        _contentController.text = _cData.content;
        _selectedCategoryIndex = _cData.categoryId;
        _selectedValue = _categoryValueList[_cData.categoryId];
        _cImageData = arguments['image'];
      }
    });
  }

  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  final List<String> _categoryValueList = ['꿀팁', '질문', '나눔'];
  String _selectedValue = '꿀팁';
  int _selectedCategoryIndex =0;

  final picker = ImagePicker();
  File _image;
  List<XFile> _selectedFiles=[];

  Future sendImages(String communityId)async{
    var uri = baseUrl+"/community/flutter_upload_image/create.php";
    var request = http.MultipartRequest('POST', Uri.parse(uri));

    try{
      if (_selectedFiles.isNotEmpty){
        for (int i = 0; i < _selectedFiles.length; i++) {
          var pic = await http.MultipartFile.fromPath(
              "image[]", _selectedFiles[i].path);
          print("pick${i}: ${_selectedFiles[i].path}");
          request.files.add(pic);
          request.fields["communityId"] = communityId;
        }

        await request.send().then((result) {
          http.Response.fromStream(result).then((response) {

            if(response.body.isNotEmpty) {
              var message = json.decode(response.body);

            }
          });

        }).catchError((e) {
          print(e);
        });
      }else{
        print("image is not selected!");
      }

    }catch(e){
      print(e);
    }
    print("image list length:${_selectedFiles.length.toString()}");

  }
  Future pickImages() async {
    final List<XFile> selectedImages = await picker.pickMultiImage();

    if(_cImageData.isNotEmpty){
      setState(() {
        _cImageData.clear();
      });
    }
    if (_selectedFiles.isNotEmpty) {
      setState(() {
        _selectedFiles.clear();
      });
    }
    if (selectedImages.isNotEmpty) {
      setState(() {
        _selectedFiles.addAll(selectedImages);
      });
    }
  }

  Future _create() async {
    print("_create start");
    var url = baseUrl + "/community/c_create.php";

    var response = await http.post(Uri.parse(url), body: {
      "categoryId": _selectedCategoryIndex.toString(),
      "userId": _userid,
      "title": _titleController.text,
      "content": _contentController.text
    });

    print(_selectedCategoryIndex.toString());
    print(_titleController.text);
    print(_contentController.text);
    if (response.body.isNotEmpty) {
      // var message = json.decode(response.body);
      var message = await json.decode(response.body);
      print(message);

      if (response.body.isNotEmpty) {
        var message = json.decode(response.body);

        String id = message["communityId"].toString();
        print("!!!!${id}");
        sendImages(id);
      }

      Navigator.pop(context);
    }
  }
  Future _update() async{
    var url = baseUrl+"/community/c_update.php";

    var response = await http.post(Uri.parse(url), body: {
      "communityId": _cData.communityId.toString(),
      "categoryId": _selectedCategoryIndex.toString(),
      "userId": _userid,
      "title": _titleController.text,
      "content": _contentController.text,
    });
    sendImages(_cData.communityId.toString());
    Navigator.pop(context);

  }
  Widget showImages() {
    return Row(
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.width * 0.9,
          child: InkWell(
            onTap: () {
              pickImages();
            },
            child: GridView.builder(
              itemCount: _selectedFiles.isEmpty ? 1 : _selectedFiles.length + 1,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                childAspectRatio: 1 / 1, //item 의 가로 1, 세로 2 의 비율
                mainAxisSpacing: 10, //수평 Padding
                crossAxisSpacing: 10, //수직 Padding
              ),
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                ),
                child: _selectedFiles.isEmpty || index == _selectedFiles.length
                    ? Icon(
                        CupertinoIcons.camera,
                      )
                    : Image.file(File(_selectedFiles[index].path)),
              ),
            ),
          ),
        ),
      ],
    );
  }
  Widget showImagesByNetwork(){
    return Row(
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          height: MediaQuery.of(context).size.width * 0.9,
          child: InkWell(
            onTap: () {
              pickImages();
            },
            child: GridView.builder(
              itemCount: _cImageData.isEmpty ? 1 : _cImageData.length+1,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, //1 개의 행에 보여줄 item 개수
                childAspectRatio: 1 / 1, //item 의 가로 1, 세로 2 의 비율
                mainAxisSpacing: 10, //수평 Padding
                crossAxisSpacing: 10, //수직 Padding
              ),
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.withOpacity(0.5)),
                ),
                child: _cImageData.isEmpty || index == _cImageData.length
                    ? Icon(
                  CupertinoIcons.camera,
                  color: Colors.grey.withOpacity(0.5),
                )
                    : Image.network(baseUrl+'/community/flutter_upload_image/images/'+_cImageData[index]['url']),),
              ),
            ),
          ),
      ],
    );

  }

  @override
  Widget build(BuildContext context) {
    _userid = context.watch<Users>().userId.toString();

    return Column(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height*0.11,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height*0.9,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40.0),
                  topRight: Radius.circular(40.0))),
          child: Padding(
            padding: const EdgeInsets.only(
              right: 30,
              left: 30,
            ),
            child: SingleChildScrollView(

              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  DropdownButtonFormField(
                    value: _selectedValue,
                    items: _categoryValueList.map((value) {
                      return DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        var index = _categoryValueList.indexOf(value as String);
                        _selectedValue = value;
                        _selectedCategoryIndex = index;
                      });
                    },
                    icon: const Icon(Icons.arrow_drop_down_circle,),
                    decoration: InputDecoration(
                      labelText: "Category",
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  TextField(
                    controller: _titleController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Enter title",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  TextField(
                    controller: _contentController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      labelText: "Enter content",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.content_paste),
                    ),
                  ),

                  Container(
                    height:MediaQuery.of(context).size.height*0.38,
                    width: MediaQuery.of(context).size.width*1,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _cImageData.isEmpty? showImages():showImagesByNetwork(),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if(_cData != null){
                        _update();
                      }else{
                        _create();
                      }

                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '작성',
                          ),
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ),

      ],
    );
  }
}
