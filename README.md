# TeamTrees Websocket API

Simple websocket server to publish new updates from https://teamtrees.org

## Usage
```js
const ws = new Websocket("wss://trees.xetera.dev")
ws.onmessage = (str) => {
  const { trees, date } = JSON.parse(str)
  console.log(trees) // 14301975
}
```

## Currently supports
- [x] Updates to tree count
- [ ] New recent donations
- [ ] Changes to most trees
