class Cuisine {
  String id;
  String name;

  Cuisine({this.id, this.name});

  bool operator ==(o) => o is Cuisine && o.name == name;
  int get hashCode => name.hashCode;
}

class DishCategory {
  String id;
  String name;

  DishCategory({this.id, this.name});

  bool operator ==(o) => o is DishCategory && o.name == name;
  int get hashCode => name.hashCode;
}