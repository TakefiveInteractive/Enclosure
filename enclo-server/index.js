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
const handlers = require('./socket-handlers')(conns, rooms, io)

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
    username : req.body.name
  })
  .then((dbResult) => res.end(dbResult))
})
app.post('/getInfo', (req, res) => {
  let user = {
    deviceId : req.body.userId
  }
  models.Player.findOne(user).then((doc) => {
    if (doc != null) {
      return doc
    } else {
      let userDoc = new models.Player(user)
      return userDoc.save()
    }
  })
  .then((user) => {
    return Promise.all([
      user,
      redisClient.zaddAsync('playerRank', user.elo, user._id.toString())
    ])
  })
  .then((results) => {
    let user = results[0]
    return Promise.all([
      Promise.resolve(user),
      redisClient.zrankAsync('playerRank', user._id.toString()),
    ])
  })
  .then((results) => {
    l(results)
    let rank = results[1]
    let user = results[0]
    res.json({
      name : user.name,
      rank : rank,
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



