const express = require('express')
const app = express()
const port = 12701

app.all('/*', function (req, res) {
    console.log(`Buyer #??? receiving from server: ${JSON.stringify(req.params[0])}`)
    res.sendStatus(200)
  })

app.listen(port, () => console.log("Buyer online"))