'use strict'

let app = require('express')()
let http = require('http').Server(app)
let io = require('socket.io')(http)
const uuid = require('node-uuid')

const roomSocket = (roomNumber) => io.to(roomNumber)

let conns = {

} // map of user to socket
let rooms = {

} // room name to [] of names

let handlers = require('./socket-handlers')(conns, rooms, io)
let models = require('./db')

io.on('connection', function(socket){
  let selfname
  console.log(socket.id + ' connected')
  //socket.on('disconnect', function(){
  //  console.log(socket.id + ' disconnected')
  //})

  socket.on('error', function (err) {
    console.log(err)
  })

  socket.on('createRoom', handlers.onCreateRoom(socket))
  socket.on('joinRoom', handlers.onJoinRoom(socket))

  socket.on('setName', function (username){
    selfname = username
    conns [username] = socket
    log()
  })
})

http.listen(3000, function(){
  console.log('listening on *:3000')
})


