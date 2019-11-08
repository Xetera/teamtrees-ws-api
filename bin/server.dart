import 'dart:async';
import 'dart:collection';
import 'dart:io';
import "dart:convert";
import "teamtrees.dart";

const checkDelay = Duration(seconds: 6);
final connections = Set<WebSocket>();
final latestDonations = Queue<Donation>();
const MAX_DONATIONS = 50;
int treeCount = -1;

void sendTrees(final WebSocket socket) {
  final payload = {
    "event": "tree_count",
    "data": treeCount,
  };
  socket.add(json.encode(payload));
}

void sendDonations(final WebSocket socket, List<Donation> donations) {
  final payload = {
    "event": "donations",
    "data": donations.toList(),
  };
  socket.add(json.encode(payload));
}

void broadcastTrees() => connections.forEach(sendTrees);

void broadcastDonations(List<Donation> donations) =>
    connections.forEach((conn) {
      sendDonations(conn, donations);
    });

Future updateTrees() async {
  print("Updating tree count");
  final res = await crawl();
  final newDonations = updateQueue(res.donations);
  if (res.treeCount == treeCount) {
    return;
  }
  treeCount = res.treeCount;
  print("new tree count $treeCount");
  await broadcastTrees();
  await broadcastDonations(newDonations);
}

List<Donation> updateQueue(final List<Donation> donations) {
  final toCheck = latestDonations.toSet();
  final newDonations = donations.takeWhile((donation) {
    return !toCheck.any((existingDonation) {
      return existingDonation == donation;
    });
  });
  latestDonations.addAll(newDonations);
  final until = latestDonations.length > MAX_DONATIONS
      ? MAX_DONATIONS - latestDonations.length
      : 0;
  for (int i = 0; i < until; ++i) {
    latestDonations.removeFirst();
  }
  return newDonations.toList();
}

void handleDisconnect(final WebSocket socket) {
  connections.remove(socket);
}

const port = 8080;

void handleConnection(final WebSocket socket) async {
  connections.add(socket);
  if (treeCount != -1) {
    await sendTrees(socket);
  }
  if (latestDonations.isNotEmpty) {
    await sendDonations(socket, latestDonations.toList());
  }
}

void main(final List<String> args) async {
  await runZoned(() async {
    final server = await HttpServer.bind('0.0.0.0', port);
    server.defaultResponseHeaders.add("Access-Control-Allow-Origin", "*");
    print("Listening to connections at $port");
    Timer.periodic(checkDelay, (Timer timer) {
      updateTrees();
    });
    await for (final req in server) {
      print("Received a new connection");
      if (req.uri.path != '/ws') {
        continue;
      }
      // Upgrade a HttpRequest to a WebSocket connection.
      final socket = await WebSocketTransformer.upgrade(req);
      socket.listen((_) {}, onDone: () {
        handleDisconnect(socket);
      });
      handleConnection(socket);
      print(
          "Received a new websocket connection.\nConnected clients: ${connections.length}");
    }
  }, onError: (e) => print("An error occurred.\n$e"));
}
