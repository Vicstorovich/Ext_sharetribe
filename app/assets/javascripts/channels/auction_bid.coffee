App.cable.subscriptions.create('AuctionBidsChannel', {
  connected: ->
    console.log("Connected!")
    @perform "follow"

  received: (data) ->
    $(".price_auction_bid").replaceWith data
    console.log(data)
})
