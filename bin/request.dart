import "package:html/parser.dart";
import "package:http/http.dart" as http;

const url = "https://teamtrees.org";

Future<int> treeCountAsync() async {
  final html = await http.get(url);
  final document = parse(html.body);
  final treeDiv = document.querySelector("#totalTrees");
  final treeValue = treeDiv.attributes["data-count"];
  return int.parse(treeValue);
}
