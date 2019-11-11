# TeamTrees Websocket API

Simple websocket server to publish new updates from https://teamtrees.org

## Usage
```js
const ws = new WebSocket("wss://trees.xetera.dev")
ws.onmessage = (event) => {
  const message = JSON.parse(event.data)
  console.log(message)
  // { "event": "tree_count", "data": 14431524 }
}
```
### Event types

2 kinds of events are currently supported. Both events are emitted together upon first connection.

#### Tree Count

Emitted when the tree count is updated.

```json
{
  "event": "tree_count",
  "data": 14431524
}
```

#### Donations

All known donations are emitted upon first connection. When new donations are found, only the updated ones are emitted.
Max 50 latest donations are stored at a time.

```json
{
  "event": "donations",
  "data": [{
    "name": "Jon da man",
    "trees": 5,
    "date": "2019-11-08T21:41:49.1170000Z",
    "badge": "https://teamtrees.org/images/icon-badge-acorn-2.svg",
    "comment": "This ones for the giving tree"
  }, {
    "name": "Montana9914",
    "trees": 5,
    "date": "2019-11-08T21:41:25.1230000Z",
    "badge": "https://teamtrees.org/images/icon-badge-acorn-2.svg",
    "comment": ""
  }]
}
```
`comment` might be empty but never null or missing.

### Currently supports
- [x] Updates to tree count
- [x] New recent donations
