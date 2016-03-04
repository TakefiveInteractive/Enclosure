'use strict'

let mongoose = require('mongoose')
mongoose.connect('mongodb://localhost/enclosure-game')

let moveSchema = new mongoose.Schema({
  roomNumber : String,
  time : {
    type : Date,
    default : Date.now()
  },
  player : String,
  rawString : String,
  points : {
    type : [{
      type : Number
    }, {
      type : Number
    }]
  }
})

let Move = mongoose.model('game-move', moveSchema)
module.exports = {
  Move : Move,
}