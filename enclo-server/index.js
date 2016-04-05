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
  socket.on('joinRank', handlers.onJoinRankingGame(socket))
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
  .then((dbResult) => res.json(dbResult))
})
app.post('/report', (req, res) => {
  let body = req.body
  if (body.isOffline) {
    let gameDoc = new models.Game(body)
    return gameDoc.save().then(() => {
      return res.json({})
    })
  }
  let winId = body.winId
  let selfId = body.selfId
  let gameId = body.gameId
  let anotherId = body.playerIds[1 - body.playerIds.indexOf(winId)]
  Promise.all(body.playerIds.map((id) => {
    return models.Player.findOne({deviceId : id})
  }))
  .then((users) => {
    return models.Game.findOne({
      gameId : gameId
    }).then((result) => {
      if (result) {
        l('another guy')
        let ans = {}
        ans.old = result._doc.rankChange[selfId][0]
        ans.new = result._doc.rankChange[selfId][1]
        if (ans.old != -1) ans.old ++
        if (ans.new != -1) ans.new ++
        l(ans)
        return res.json(ans)
      }
      //if (result? && !body.isRanking)
      let oldElo = users.map((u) => u.elo)
      let eloChange = ranker({
        ranks : users.map((u) => u.elo),
        scores : users.map((u) => {
          return (u.deviceId == winId) ? 1 : 0
        }),
      })
      //!!todo
      return Promise.all(eloChange.map((rank, index) => {
        let user = users[index]
        let requestOldRanking = redisClient.zrevrankAsync('playerRank', user._id.toString())
        if (user.elo == -1) {
          user.elo = 1000
          requestOldRanking = Promise.resolve(-1)
        }
        user.elo = user.elo + rank
        return requestOldRanking.then((oldRanking) => {
          return Promise.all([
            user.save(),
            redisClient.zaddAsync('playerRank', user.elo, user._id.toString()),
          ]).then(() => 
              redisClient.zrevrankAsync('playerRank', user._id.toString()))
          .then((newRanking) => {
            if (body.playerIds[index] == selfId) {
              let ans = {}
              ans.old = oldRanking
              ans.new = newRanking
              if (ans.old != -1) ans.old ++
              if (ans.new != -1) ans.new ++
              l(ans)
              res.json(ans)
            }
            return [oldRanking, newRanking]
          })
        })
      })).then((twoRankings) => {
        body.rankChange = {}
        body.playerIds.forEach((playerId, index) => {
          body.rankChange[playerId] = twoRankings[index]
        })
        let gameDoc = new models.Game(body)
        return gameDoc.save()
      })
    })
  }).catch(errorHandler)
})
app.get('/top100', (req, res) => {
  models.Player.find({
    elo : {
      $ne : -1
    }
  }).sort({
    elo : -1,
    _id : -1
  }).limit(100)
  .then((users) => {
    res.json(users.map((u) => u.name))
  })
})
app.post('/register', (req, res) => {
  l('resgister')
  let user = {
    deviceId : req.body.userId
  }
  l('register start ' + req.body.userId)
  let userDoc = new models.Player(user)
  models.Player.findOne(user).then((u) => {
    if (u)
      return u
    else
      return userDoc.save()
  }).then((u) => {
    return res.json({
      name : u.name,
      rank : -1
    })
  })
})
app.get('/info', (req, res) => {
  let user = {
    deviceId : req.query.userId
  }
  models.Player.findOne(user)
  .then((user) => {
    if (user == null)
      return null
    return Promise.all([
      redisClient.zrevrankAsync('playerRank', user._id.toString()),
      Promise.resolve(user)
    ])
  })
  .then((results) => {
    if (results == null)
      return res.json({})
    let rank = results[0]
    let user = results[1]
    return res.json({
      name : user.name,
      rank : rank === null ? -1 : rank + 1,
    })
  })
  .catch(errorHandler)
})

const run = () => {
  http.listen(8888, () => {
    console.log('listening')
  })
}

Promise.all([
    redisClient.zcountAsync('playerRank', '-inf', '+inf'),
    models.Player.count({})
]).then((countResult) => {
  if (countResult[1] > countResult[0]) {
    return models.Player.find({elo : {$ne : -1}}).sort({_id : -1})
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



