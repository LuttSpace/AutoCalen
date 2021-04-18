import 'dart:ui';

class Tag{
  String tid;
  String _tagName;
  Color _tagColor;

  Tag(this.tid,this._tagName,this._tagColor);

  Color getTagColor() {return _tagColor; }
  String getTagName() {return _tagName; }

  void setTagColor(Color color){
    _tagColor=color;
  }
  void setTagName(String name){
    _tagName = name;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    return { //tid
      'name': _tagName,
      'color': _tagColor.toString(),
    };
  }
}