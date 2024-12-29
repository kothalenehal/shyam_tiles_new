class CatalogModel {
  static final List<Item> items = [
    Item(
      id: 1,
      name: "1004 DK*",
      desc: "16X16 Inch",
      color: "#33505a",
      image: 'images/Image 22.png',
    ),
    Item(
        id: 2,
        name: "1004 DK*",
        desc: "16X12 Inch",
        color: "#33505a",
        image: 'images/Image 24.png'),
    Item(
        id: 3,
        name: "1004 DK*",
        desc: "16X18 Inch",
        color: "#33505a",
        image: 'images/Image 23.png'),
    Item(
        id: 4,
        name: "1004 DK*",
        desc: "18X18 Inch",
        color: "#33505a",
        image: "images/Image 25.png"),
    Item(
        id: 5,
        name: "1004 DK*",
        desc: "16X12 Inch",
        color: "#33505a",
        image: "images/tiles.jpg"),
  ];
}

class Item {
  final int id;
  final String name;
  final String desc;
  //final num price;
  final String color;
  final String image;

  Item(
      {required this.id,
      required this.name,
      required this.desc,
      //required this.price,
      required this.color,
      required this.image});
}
