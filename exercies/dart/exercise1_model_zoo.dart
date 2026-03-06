// Exercise 1: Model a Zoo

abstract class Animal {
  Animal(this.name, this.legs);

  final String name;
  final int legs;

  String makeSound();
}

class Dog extends Animal {
  Dog(String name) : super(name, 4);

  @override
  String makeSound() => 'Woof!';
}

class Cat extends Animal {
  Cat(String name) : super(name, 4);

  @override
  String makeSound() => 'Meow!';
}

void runExercise1() {
  final animals = <Animal>[
    Dog('Buddy'),
    Cat('Whiskers'),
    Dog('Rex'),
    Cat('Luna'),
  ];

  for (final animal in animals) {
    print('${animal.name} (${animal.legs} legs) says ${animal.makeSound()}');
  }
}

void main() => runExercise1();
