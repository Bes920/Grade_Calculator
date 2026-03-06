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

void handleState(NetworkState state) {
  switch (state) {
    case Loading():
      print('Loading...');
    case Success(data: final data):
      print('Success: $data');
    case Error(message: final message):
      print('Error: $message');
  }
}

void main() {
  final states = <NetworkState>[
    const Loading(),
    const Success('User data loaded'),
    const Error('Server timeout'),
  ];

  for (final state in states) {
    handleState(state);
  }
}
