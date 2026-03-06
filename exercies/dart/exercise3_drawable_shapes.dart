// Exercise 3: Drawable Shapes with Interfaces

abstract interface class Drawable {
  void draw();
}

class Circle implements Drawable {
  Circle({required this.radius});

  final int radius;

  @override
  void draw() {
    print('Circle (radius: $radius)');
    print('   ***   ');
    print(' *     * ');
    print('*       *');
    print(' *     * ');
    print('   ***   ');
  }
}

class Square implements Drawable {
  Square({required this.side});

  final int side;

  @override
  void draw() {
    print('Square (side: $side)');
    print('+-------+');
    print('|       |');
    print('|       |');
    print('|       |');
    print('+-------+');
  }
}

void main() {
  final shapes = <Drawable>[
    Circle(radius: 4),
    Square(side: 7),
  ];

  for (final shape in shapes) {
    shape.draw();
    print('');
  }
}
