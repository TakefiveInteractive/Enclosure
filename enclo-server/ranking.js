'use strict'
//https://www.wikiwand.com/en/Elo_rating_system#/Mathematical_details

let log = (info) =>
  console.log(JSON.stringify(info))

let expection = (ranks) =>
  ranks.map((val, index) =>
    1 / (1+ Math.pow(10, (ranks[1 - index] - val)/400)))

let growthFactor = (ranks) =>
  10
  //Math.abs(ranks[0] - ranks[1]) / 2


log(growthFactor([10, 1]))

module.exports = function (info) {
  log(info)
  let ranks = info.ranks
  let scores = info.scores
  let rankChange = [0, 0]
  rankChange = rankChange.map((_, index) => {
    return growthFactor(ranks)*(info.scores[index] - expection(ranks)[index])
  })
  //log(rankChange)
  return rankChange
}