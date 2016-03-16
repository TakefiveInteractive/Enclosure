'use strict'

let mongoose = require('mongoose')
let mongoosePaginate = require('mongoose-paginate')

mongoose.connect('mongodb://localhost/enclosure-game')

let gameSchema = new mongoose.Schema({
  roomNumber : String,
  time : {
    type : Date,
    default : Date.now()
  },
  players : [String],
  move: []
}, {
  strict: false
})

let playerSchema = new mongoose.Schema({
  createAt : {
    type: Date,
    default: Date.now()
  },
  name : {
    type:String,
    default : '',
  },
  elo : {
    type:Number,
    default:1000,
  },
  deviceId : {
    type : String
  }
})

gameSchema.plugin(mongoosePaginate)
playerSchema.plugin(mongoosePaginate)

let Game = mongoose.model('record', gameSchema)
let Player = mongoose.model('player', playerSchema)

module.exports = {
  Game : Game,
  Player : Player,
}