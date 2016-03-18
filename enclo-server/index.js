'use strict'
const l = (obj) => console.log('log : ' + JSON.stringify(obj))
const errorHandler = (err) => console.log('error : ' + JSON.stringify(err))

const app = require('express')()
const bodyParser = require('body-parser')
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

const http = require('http').Server(app)
const io = require('socket.io')(http)

const models = require('./db')

const uuid = require('node-uuid')

let redis = require("redis")
let bluebird = require("bluebird")
bluebird.promisifyAll(redis.RedisClient.prototype)
bluebird.promisifyAll(redis.Multi.prototype)
let redisClient = redis.createClient()

const roomSocket = (roomNumber) => io.to(roomNumber)

let conns = {

} // map of user to socket
let rooms = {

} // room name to [] of sockets
let processingId = []

const handlers = require('./socket-handlers')(conns, rooms, io)
const ranker = require('./ranking.js')

io.on('connection', function(socket){
  let selfname
  console.log(socket.id + ' connected')
  //socket.on('disconnect', function(){
  //  console.log(socket.id + ' disconnected')
  //})

  socket.on('error', function (err) {
    console.log(err)
  })

  socket.on('register', function (username) {
    let newPlayer = new models.Player({
      name : username
    })
    newPlayer.save().then((doc) => {
      socket.emit('registerComplete', doc._id)
    })
  })

  socket.on('createRoom', handlers.onCreateRoom(socket))
  socket.on('joinRoom', handlers.onJoinRoom(socket))

  socket.on('setName', function (username){
    selfname = username
    conns [username] = socket
    log()
  })
})
app.post('/setName', (req, res) => {
  let user = {
    deviceId : req.body.userId
  }
  models.Player.update(user, {
    name : req.body.name
  })
  .then((dbResult) => res.end(dbResult))
})
app.post('/report', (req, res) => {
  let body = req.body
  l(body)
  if (body.playerIds && body.playerIds.length == 2) {
    let winId = body.winId
    let anotherId = body.playerIds[1 - body.playerIds.indexOf(winId)]
    Promise.all(body.playerIds.map((id) => {
      return models.Player.findOne({deviceId : id})
    }))
    .then((userInfoArray) => {
      l(userInfoArray)
      l('fuck')
      body.ranks = ranker({
        ranks : userInfoArray.map((u) => u.elo),
        scores : userInfoArray.map((u) => {
          return (u.deviceId == winId) ? 1 : 0
        }),
      })
      l(body.ranks)
      let gameDoc = new models.Game(body)
      gameDoc.save().then((result) => {
        res.json(result)
        return Promise.all(body.ranks.map((rank, index) => {
        if (userInfoArray[index].elo == -1)
          userInfoArray[index].elo = 1000
          userInfoArray[index].elo = userInfoArray[index].elo + rank
          return Promise.all([
            userInfoArray[index].save(),
            redisClient.zaddAsync('playerRank', userInfoArray[index].elo, userInfoArray[index]._id.toString()),
          ])
        }))
      })
    }).catch(errorHandler) 
  } else {
    let gameDoc = new models.Game(body)
    gameDoc.save().then((result) => {
      res.json(result)
    })
  }
  
})
app.get('/top100', (req, res) => {
  models.Player.find({
    elo : {
      $gt : -1
    }
  }).sort({
    elo: -1
  }).limit(100)
  .then((users) => {
    res.json(users.map((u) => u.name))
  })
})
app.post('/register', (req, res) => {
  let user = {
    deviceId : req.body.userId
  }
  let userDoc = new models.Player(user)
  userDoc.save()
  .then((u) => {
    return Promise.all([
      redisClient.zaddAsync('playerRank', u.elo, u._id.toString()),
      Promise.resolve(u)
    ])
  })
  .then((results) => {
    return Promise.all([
      redisClient.zrevrankAsync(user._id.toString()),
      Promise.resolve(results[1].name),
    ])
  })
  .then((results) => {
    return res.json({
      name : results[1],
      rank : -1
    })
  })
})
app.get('/info', (req, res) => {
  let user = {
    deviceId : req.query.userId
  }
  models.Player.findOne(user).then((doc) => {
    if (doc != null) {
      return doc
    } else {
      res.json({})
    }
  })
  .then((user) => {
    return Promise.all([
      Promise.resolve(user),
      redisClient.zrevrankAsync('playerRank', user._id.toString())
    ])
  })
  .then((results) => {
    let rank = results[1]
    let user = results[0]
    res.json({
      name : user.name,
      rank : rank + 1,
    })
  })
  .catch(errorHandler)
})

const run = () => {
  http.listen(3000, () => {
    console.log('listening')
  })
}

Promise.all([
    redisClient.zcountAsync('playerRank', '-inf', '+inf'),
    models.Player.count({})
]).then((countResult) => {
  if (countResult[1] > countResult[0]) {
    return models.Player.find({})
  } else {
    return null
  }
}).then((userList) => {
  if (userList == null)
    return true
  return Promise.all(userList.map((u) => {
    return redisClient.zaddAsync('playerRank', u.elo, u._id.toString())
  }))
}).then((info) => {
  l(info)
  run()
}).catch(errorHandler)



