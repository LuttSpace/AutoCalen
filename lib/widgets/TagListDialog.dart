
import 'package:autocalen/models/Tag.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class TagSelectMenu extends StatefulWidget {
  final BorderRadius borderRadius;
  final Color backgroundColor;
  final Color iconColor;
  final ValueChanged<int> onChange;
  final ValueChanged<Tag> addETC;
  final List<Tag> tagList;
  final Tag currentTag;

  const TagSelectMenu({
    Key key,
    this.borderRadius,
    this.backgroundColor = const Color(0xFFF67C0B9),
    this.iconColor = Colors.black,
    this.onChange,
    this.addETC,
    this.tagList,
    this.currentTag,
  })  : assert(tagList != null),
        super(key: key);
  @override
  _TagSelectMenuState createState() => _TagSelectMenuState();
}

class _TagSelectMenuState extends State<TagSelectMenu>
    with SingleTickerProviderStateMixin {
  GlobalKey _key;
  bool isMenuOpen = false;
  Offset buttonPosition;
  Size buttonSize;
  OverlayEntry _overlayEntry;
  BorderRadius _borderRadius;
  Color currentColor;
  List<Tag> tagList;
  Tag currentTag;

  @override
  void initState() {
    _key = LabeledGlobalKey("button_icon");
    _borderRadius = widget.borderRadius ?? BorderRadius.circular(4);
    tagList = widget.tagList;
    currentTag=widget.currentTag;
    currentColor = currentTag.getTagColor();
    super.initState();
  }

  findButton() {
    RenderBox renderBox = _key.currentContext.findRenderObject();
    buttonSize = renderBox.size;
    buttonPosition = renderBox.localToGlobal(Offset.zero);
  }

  void closeMenu() {
    _overlayEntry.remove();
    isMenuOpen = !isMenuOpen;
  }

  void openMenu() {
    findButton();
    _overlayEntry = _overlayEntryBuilder();
    Overlay.of(context).insert(_overlayEntry);
    isMenuOpen = !isMenuOpen;
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      key: _key,
      decoration: BoxDecoration(
        borderRadius: _borderRadius,
      ),
      child: RaisedButton(
        color: currentColor,
        onPressed: () {
          if (isMenuOpen) {
            closeMenu();
          } else {
            openMenu();
          }
        },
      ),
    );
  }
  OverlayEntry _overlayEntryBuilder() {
    Color _backgroundColor = Color(0xffefefef);

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          top: buttonPosition.dy + buttonSize.height,
          left: buttonPosition.dx,
          width: buttonSize.width*5,
          height: buttonSize.width*4.5,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topLeft,
                  child: ClipPath(
                    clipper: ArrowClipper(),
                    child: Container(
                      width: 17,
                      height: 17,
                      color: _backgroundColor,
                    ),
                  ),
                ),
                Positioned(
                    top: 15.0,
                    child: Container(
                      width: buttonSize.width*5,
                      height: buttonSize.width*4.5,
                      decoration: BoxDecoration(
                        borderRadius: _borderRadius,
                        color: _backgroundColor,
                      ),
                      child: GridView.count(
                          crossAxisCount: 4,
                          padding: EdgeInsets.all(20.0),
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          children: List<Widget>.generate(
                              tagList.length+1,
                              (int index){
                                  if(index == tagList.length){
                                    Color _pickedColor;
                                    return Container(
                                      child: Column(
                                        children: [
                                          Container(
                                            height:30,
                                            margin: EdgeInsets.only(bottom: 5),
                                            child: FlatButton(
                                              child: Icon(Icons.add_circle),
                                              onPressed: (){
                                                closeMenu();
                                                showDialog(
                                                  context: context,
                                                  builder: (context){
                                                    return AlertDialog(
                                                      content: Container(
                                                        width: 320,height: 500,
                                                        child: ColorPicker(
                                                          color: Colors.green,
                                                          onColorChanged: (color){
                                                            setState(() {
                                                              _pickedColor=color;
                                                            });
                                                          },
                                                          width: 40,
                                                          height: 40,
                                                          borderRadius: 4,
                                                          spacing: 5,
                                                          runSpacing: 5,
                                                          wheelDiameter: 155,
                                                          heading: Text(
                                                            'Select color',
                                                            style: Theme.of(context).textTheme.subtitle1,
                                                          ),
                                                          subheading: Text(
                                                            'Select color shade',
                                                            style: Theme.of(context).textTheme.subtitle1,
                                                          ),
                                                          wheelSubheading: Text(
                                                            'Selected color and its shades',
                                                            style: Theme.of(context).textTheme.subtitle1,
                                                          ),
                                                          showMaterialName: true,
                                                          showColorName: true,
                                                          showColorCode: true,
                                                          materialNameTextStyle: Theme.of(context).textTheme.caption,
                                                          colorNameTextStyle: Theme.of(context).textTheme.caption,
                                                          colorCodeTextStyle: Theme.of(context).textTheme.caption,
                                                          pickersEnabled: const <ColorPickerType, bool>{
                                                            ColorPickerType.both: false,
                                                            ColorPickerType.primary: true,
                                                            ColorPickerType.accent: true,
                                                            ColorPickerType.bw: false,
                                                            ColorPickerType.custom: true,
                                                            ColorPickerType.wheel: true,
                                                          },
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: (){
                                                              print(_pickedColor.toString());
                                                              setState(() {
                                                                currentColor=_pickedColor;
                                                                currentTag= new Tag('기타',_pickedColor);
                                                                widget.addETC(currentTag);
                                                              });
                                                              Navigator.pop(context);
                                                            },
                                                            child: Text('확인')
                                                        )
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                  else{
                                    return Container(
                                      child: Column(
                                        children: [
                                          Container(
                                            height:30,
                                            margin: EdgeInsets.only(bottom: 5),
                                            child: FlatButton(
                                              color: tagList[index].getTagColor(),
                                              onPressed: () {
                                                setState(() {
                                                  currentColor = tagList[index].getTagColor();
                                                  currentTag = tagList[index];
                                                  widget.onChange(index);
                                                  closeMenu();
                                                });
                                              }
                                            ),
                                          ),
                                          Center(child: Text(tagList[index].getTagName(),overflow: TextOverflow.ellipsis,),),
                                        ],
                                      ),
                                    );
                                  }
                              }
                          )
                      ),
                    )
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
class ArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width / 2, size.height / 2);
    path.lineTo(size.width, size.height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}