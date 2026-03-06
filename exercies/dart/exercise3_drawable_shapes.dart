// Exercise 3: Drawable Shapes with Interfaces

abstract interface class Drawable {
  void draw();
}

class Circle implements Drawable {
  Circle({required this.radius});

  final int radius;

  @override
  void draw() {
    print('Circle(radius: $radius)');
  }
}

void main() {
  print('Exercise 3 interface setup complete.');
}
