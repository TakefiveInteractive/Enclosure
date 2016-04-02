'use strict'
const l = (obj) => {
  try {
    console.log('log : ' + JSON.stringify(obj))
  } catch(e) {
    console.log('log failed')
  }
}
const errorHandler = (err) => console.log('error : ' + JSON.stringify(err))

let models = require('./db')
let uuid = require('uuid')
let Game = models.Game

let randName = () => Math.floor(Math.random() * 100000).toString()
let boardNumGen = () => {
  let ans = Math.round((Math.floor(Math.random()*100) + 1) * (Math.floor(Math.random()*100) + 1) / 1500)
  if (ans == 0)
    ans = 1
  return ans
}

let waitingPlayers = {
  '1' : [],
  '2' : []
}
let moves = {}
let maps = {}
let levels = {}
let ids = {}

let handlers = (conns, rooms, io) => {
  const ifNotInGame = (personalSocket, roomNumber) => {
    return !rooms[roomNumber] || rooms[roomNumber].indexOf(personalSocket) == -1
  }
  const log = () => {
    //console.log('Conns : ' + JSON.stringify(conns.map((c) => c.id)))
    console.log('rooms : ' + JSON.stringify(Object.keys(rooms)))
  }
  let gameOn = (roomNumber) => {
    let theRoom = rooms[roomNumber]
    let requestedRestart = [false, false]
    //io.to(roomNumber).emit('gameCanStart', '')
    io.to(roomNumber).emit('mapUpdate', 
      maps[roomNumber].join('|'))
    theRoom.sort(() => {
      Math.random() > 0.5
    })
    l(ids[roomNumber])
    Promise.all(ids[roomNumber].map((id) => {
      return models.Player.findOne({deviceId : id})
    }))
    .then(docs => {
      l(docs)
      let gameId = uuid.v4()
      let names = docs.map((doc) => doc.name)
      theRoom.forEach((socket, index) => {
        socket.emit('gameCanStart', JSON.stringify({
          index : index,
          names : names,
          ids : docs.map((doc) => doc.deviceId),
          level : levels[roomNumber],
          gameId : gameId,
        }))
      })
    })
    theRoom.forEach((socket, index) => {
      socket.on('gameMove', !ifNotInGame(socket, roomNumber) ? methods.onMove(roomNumber, theRoom, index) : () => {})
      socket.on('disconnect', () => {
        io.to(roomNumber).emit('userDisconnect', '😲')
        delete rooms[roomNumber]
        delete moves[roomNumber]
        delete ids[roomNumber]
      })
      socket.on('gameEnd', () => {
        if (!rooms[roomNumber])
          return
        let thisGame = new Game({
          roomNumber : roomNumber,
          players : rooms[roomNumber].map((socket) => socket.id),
          move : moves[roomNumber]
        })
        //thisGame.save()
      })
      socket.on('gameRestart', () => {
        l('1')
        if (ifNotInGame(socket, roomNumber))
          return
        l('2')
        if (requestedRestart[theRoom.indexOf(socket)])
          return
        l('3')
        requestedRestart[theRoom.indexOf(socket)] = true
        if (requestedRestart[0] && requestedRestart[1]) {
          io.to(roomNumber).emit('mapUpdate', 
            maps[roomNumber].join('|'))
          requestedRestart = [false, false]
          theRoom.sort(() => {
            Math.random() > 0.5
          })
          theRoom.forEach((socket, index) => {
            socket.emit('gameCanRestart', index)
          })
          methods.updateMap(roomNumber, levels[roomNumber])
        } else {
          theRoom[1 - theRoom.indexOf(socket)].emit('inviteToRestart')
        }
      })
      socket.on('refuseRestart', () => {
        if (ifNotInGame(socket, roomNumber))
          return
        requestedRestart = [false, false]
      })
    })
  }
  let methods = {
    onJoinRoom: (socket) => function (req) {
      req = JSON.parse(req)
      let id = req.id
      let roomNumber = req.room
      console.log('join ' + roomNumber)
      log()
      if (rooms[roomNumber] && rooms[roomNumber].length == 1) {
        let theRoom = rooms[roomNumber]
        theRoom.push(socket)
        socket.join(roomNumber)
        ids[roomNumber].push(id)
        gameOn(roomNumber)
      } else {
        socket.emit('roomError', 'room not found or full😲')
      }
    } ,
    onCreateRoom : (socket) => function (req) {
      req = JSON.parse(req)
      let id = req.id
      let level = req.level

      let roomNumber = randName()
      rooms[roomNumber] = [socket]
      ids[roomNumber] = [id]
      socket.join(roomNumber)
      io.to(roomNumber).emit('roomCreated', roomNumber)
      levels[roomNumber] = level
      methods.updateMap(roomNumber, levels[roomNumber])
      console.log('create ' + roomNumber)
      log()
    } ,
    onJoinRankingGame : (socket) => function (req) {
      req = JSON.parse(req)
      req.socket = socket
      let existed = waitingPlayers[req.level].findIndex(p => req.id == p.id) > -1
      if (existed)
        return
      waitingPlayers[req.level].push(req)
      socket.on('disconnect', () => {
        let q = waitingPlayers['1']
        let idx = q.findIndex(p => p.socket == socket)
        l(idx)
        if (idx != -1)
          q.splice(idx, 1)
      })
    } ,
    onMove : (roomNumber, theRoom, player) => function (rawMove) {
      console.log('move '+roomNumber+' '+player+' '+rawMove)
      theRoom[0].emit('gameMove', rawMove)
      theRoom[1].emit('gameMove', rawMove)
      if (!moves[roomNumber])
        moves[roomNumber] = [[], []]
      //1:3,7$3,8|3,6$3,7|3,5$3,6
      moves[roomNumber][parseInt(rawMove.split(':')[0])].push(rawMove.split(':')[1]
        .split('|').map((edgeStr) => 
          edgeStr.split('$').map((pointStr) => 
            pointStr.split(',').map((coordinate) => parseInt(coordinate)))))
    } ,
    updateMap : (roomNumber, level) => {
      let room = rooms[roomNumber]
      maps[roomNumber] = []
      const size = 9
      if (level == '1') {
        for (let i = 0; i<=8; i++) {
          maps[roomNumber][i] = []
          for (let j = 0; j<=8; j++)
            maps[roomNumber][i].push(1)
        }
      }
      if (level == '2') {
        for (let i = 0; i<=8; i++) {
          maps[roomNumber][i] = []
          for (let j = 0; j<=8; j++)
            maps[roomNumber][i].push(boardNumGen())
        }
      }
    } ,
  }
  let rankingTick = () => {
      let queue = waitingPlayers['1']
    process.stdout.write('...')
    process.stdout.write(queue.length.toString())
      if (queue.length >= 2) {
        let p1 = queue.pop()
        let p2 = queue.pop()
        let roomNumber = randName()
        rooms[roomNumber] = [p1.socket, p2.socket]
        ids[roomNumber] = [p1.id, p2.id]
        p1.socket.join(roomNumber)
        p2.socket.join(roomNumber)
        levels[roomNumber] = p1.level
        methods.updateMap(roomNumber, levels[roomNumber])
        console.log('create ranking ' + roomNumber)
        log()
        gameOn(roomNumber)
      }

  }
  setInterval(rankingTick,1000)
  return methods
}

module.exports = handlers