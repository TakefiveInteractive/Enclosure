'use strict'
let models = require('./db')
let Move = models.Move

let randName = () => Math.floor(Math.random() * 100000).toString()

let handlers = (conns, rooms, io) => {
  const log = () => {
    //console.log('Conns : ' + JSON.stringify(conns.map((c) => c.id)))
    console.log('rooms : ' + JSON.stringify(Object.keys(rooms)))
  }
  let methods = {
  onJoinRoom: (socket) => function (roomNumber) {
    console.log('join ' + roomNumber)
    log()

    if (rooms[roomNumber] && rooms[roomNumber].length == 1) {
      let theRoom = rooms[roomNumber]
      theRoom.push(socket)
      socket.join(roomNumber)
      //io.to(roomNumber).emit('gameCanStart', '')
      theRoom.sort(() => {
        Math.random() > 0.5
      })
      theRoom.forEach((socket, index) => {
        socket.emit('gameCanStart', index)
      })
      theRoom.forEach((socket, index) => {
        socket.on('gameMove', methods.onMove(roomNumber, theRoom, index))
        socket.on('disconnect', () => {
          io.of(roomNumber).emit('gameEnd')
          delete rooms[roomNumber]
        })
        socket.on('gameEnd', () => {
          delete rooms[roomNumber]
        })
      })
    } else {
      socket.emit('roomError', 'room not found or full')
    }
  } ,
  onCreateRoom : (socket) => function () {
    let name = randName()
    rooms[name] = [socket]
    socket.join(name)
    io.to(name).emit('roomCreated', name)

    console.log('create ' + name)
    log()
  } ,
  onMove : (roomNumber, theRoom, player) => function (rawMove) {
    console.log('move '+roomNumber+' '+player+' '+rawMove)
    theRoom[0].emit('gameMove', rawMove)
    theRoom[1].emit('gameMove', rawMove)
    new Move({
      roomNumber : roomNumber,
      time : Date.now(),
      player : rawMove.split(':')[0],
      rawString : rawMove,
      points : rawMove.split(':')[1].split('|').map((edgeStr) => {
        return edgeStr.split('$').map((pointStr) => {
          return pointStr.split(',').map((coordinate) => parseInt(coordinate))
        })
      })
    })
  }
}
return methods
}

module.exports = handlers