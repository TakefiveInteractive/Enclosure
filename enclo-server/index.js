'use strict'

var app = require('express')()
var http = require('http').Server(app)
var io = require('socket.io')(http)
const uuid = require('node-uuid')
const log = () => {
  console.log('Conns : ' + JSON.stringify(conns))
  console.log('Rooms : ' + JSON.stringify(rooms))
}

let conns = {

} // map of user to socket
let rooms = {

} // room name to [] of names

io.on('connection', function(socket){
  let selfname
  console.log('a user connected')
  socket.on('disconnect', function(){
    console.log('user disconnected')
  })
  socket.on('ready', function (username){
    selfname = username
    conns [username] = socket
    log()
  })
  socket.on('invite', function (toUsername){
    roomname = null
    Object.keys(rooms).forEach((name) => {
      if (rooms[name].indexOf(toUsername) >-1) {
        rooms[name].push(selfname)
        roomname = name
        startgame(name)
      }
    })
    log()
    if (roomname)
      return

    roomname = uuid.v4()
    rooms[roomname] = [selfname]
    log()
  })
})

let startgame = (roomName) => {
  let room = rooms[roomName]
  let conn = [
    conns[rooms[roomName][0]],
    conns[rooms[roomName][1]]]
  log()
  conn[0].join(roomName)
  conn[1].join(roomName)
  conn[0].on('move', (data) => {
    io.to(roomName).emit('move', data)
  })
  conn[1].on('move', (data) => {
    io.to(roomName).emit('move', data)
  })
  conn[0].on('reset', (data) => {
    reset(roomName)
  })
  conn[1].on('reset', (data) => {
    reset(roomName)
  })
}

let reset = (roomName) => {
  io.to(roomName).emit('reset')
  delete rooms[roomName]
}

http.listen(3000, function(){
  console.log('listening on *:3000')
})