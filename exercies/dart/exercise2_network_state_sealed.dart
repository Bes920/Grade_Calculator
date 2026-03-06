// Exercise 2: Model Network Request State with Sealed Class

sealed class NetworkState {
  const NetworkState();
}

final class Loading extends NetworkState {
  const Loading();
}

final class Success extends NetworkState {
  const Success(this.data);

  final String data;
}

final class Error extends NetworkState {
  const Error(this.message);

  final String message;
}

void main() {
  print('Exercise 2 state model ready.');
}
