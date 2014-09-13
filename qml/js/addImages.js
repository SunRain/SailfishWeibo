WorkerScript.onMessage = function(message) {
    console.log("model and pic: ", message.model, message.pic_urls)
//    for (var i=0; i<message.pic_urls.count; i++) {
//        message.model.append( message.pic_urls.get(i) )
//        message.model.sync()
//    }
//    WorkerScript.sendMessage({ 'reply': 'done' })
}
