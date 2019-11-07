import 'dart:async';
import 'dart:io';
import "dart:convert";
import "request.dart";

const checkDelay = Duration(seconds: 6);
final connections = Set<WebSocket>();
int treeCount = -1;

void sendLatest(final WebSocket socket) {
  final now = DateTime.now().toIso8601String();
  final payload = {"date": now, "trees": treeCount};
  socket.add(json.encode(payload));
}

final broadcast = () => connections.forEach(sendLatest);

Future updateTrees() async {
  print("Updating tree count");
  final newTrees = await treeCountAsync();
  if (newTrees == treeCount) {
    return;
  }
  treeCount = newTrees;
  print("new tree count $treeCount");
  broadcast();
}

void handleConnection(final WebSocket socket) {
  connections.add(socket);
  if (treeCount != -1) {
    sendLatest(socket);
  }
  socket.handleError(() {
    connections.remove(socket);
  });
}

const port = 8080;

void main(final List<String> args) async {
  await runZoned(() async {
    final server = await HttpServer.bind('127.0.0.1', port);
    server.defaultResponseHeaders.add("Access-Control-Allow-Origin", "*");
    print("Listening to connections at $port");
    Timer.periodic(checkDelay, (Timer timer) {
      updateTrees();
    });
    await for (final req in server) {
      print("Received a new connection");
      if (req.uri.path == '/ws') {
        print(
            "Received a new websocket connection.\nConnected clients: ${connections.length}");
        // Upgrade a HttpRequest to a WebSocket connection.
        final socket = await WebSocketTransformer.upgrade(req);
        handleConnection(socket);
      }
    }
  }, onError: (e) => print("An error occurred.\n$e"));
}
