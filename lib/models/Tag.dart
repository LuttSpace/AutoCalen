import 'dart:ui';

class Tag{
  String _tagName;
  Color _tagColor;

  Tag(this._tagName,this._tagColor);

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
    return {
      'name': _tagName,
      'color': _tagColor.toString(),
    };
  }
}