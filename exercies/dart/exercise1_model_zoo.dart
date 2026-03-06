// Exercise 1: Model a Zoo

abstract class Animal {
  Animal(this.name);

  final String name;
  String makeSound();
}

class Dog extends Animal {
  Dog(String name) : super(name);

  @override
  String makeSound() => 'Woof!';
}

class Cat extends Animal {
  Cat(String name) : super(name);

  @override
  String makeSound() => 'Meow!';
}

void main() {
  // Will be expanded in next commit.
  print('Exercise 1 setup complete.');
}
