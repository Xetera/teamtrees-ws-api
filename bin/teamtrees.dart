import "package:html/dom.dart";
import "package:html/parser.dart";
import "package:http/http.dart" as http;

const url = "https://teamtrees.org";

class Donation {
  String name;
  int trees;
  String date;
  String badge;
  String? comment;

  Donation(this.name, this.trees, this.badge, this.date, [this.comment]);

  @override
  bool operator ==(other) {
    return this.name == other.name &&
        this.trees == other.trees &&
        this.date == other.date &&
        this.badge == other.badge;
  }
  Map<String, dynamic> toJson() => {
    "name": name,
    "trees": trees,
    "date": date,
    "badge": badge,
    "comment": comment ?? ""
  };
}

class TeamTrees {
  List<Donation> donations;
  int treeCount;

  TeamTrees(this.treeCount, this.donations);
}

// Removing "trees" and "," from the text
int parseTreeCount(String str) =>
    int.parse(str.replaceAll(RegExp("[^0-9]"), ""));

Donation getDonation(Element node) {
  final $ = node.querySelector;
  final comment = $(".d-block.medium.mb-0").text;
  final badge = "$url/${$(".icon.donor").attributes["src"]}";
  return Donation(
    $(".media-body strong").text,
    parseTreeCount($(".feed-tree-count").text),
    badge,
    $(".feed-datetime").text,
    comment,
  );
}

List<Donation> getDonations(final Document document) => document
    .querySelector("#recent-donations")
    .children
    .map(getDonation)
    .toList();

int getTreeCount(final Document document) {
  final treeDiv = document.querySelector("#totalTrees");
  final treeValue = treeDiv.attributes["data-count"];
  return int.parse(treeValue);
}

Future<TeamTrees> crawl() async {
  final html = await http.get(url);
  final document = parse(html.body);
  final treeCount = getTreeCount(document);
  final donations = getDonations(document);
  return TeamTrees(treeCount, donations);
}
