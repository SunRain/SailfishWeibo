.pragma library

var reg = /http:\/\/[\w-]*(\.[\w-]*)+/ig;

//http://weibo.com
function replaceReg(str, color){
    return str=str.replace(/([^>=\]])((http|https|ftp|rtsp|mms):(\/\/|\\\\)[A-Za-z0-9%\-_@]+\.[A-Za-z0-9%\-_@]+[A-Za-z0-9\.\/=\?%\-&_~`@\[\]\':\+!;]*)/gi,"$1<a href=\"$2\" target='_blank'>$2</a>");
    
//    var replacedText, replacePattern1, replacePattern2, replacePattern3;
    
//    //URLs starting with http://, https://, or ftp://
//    replacePattern1 = /(\b(https?|ftp):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/gim;
//    replacedText = str.replace(replacePattern1, '<a href="$1">$1</a>');
    
//    //URLs starting with "www." (without // before it, or it'd re-link the ones done above).
//    replacePattern2 = /(^|[^\/])(www\.[\S]+(\b|$))/gim;
//    replacedText = replacedText.replace(replacePattern2, '$1<a href="http://$2">$2</a>');
    
//    //Change email addresses to mailto:: links.
//    //replacePattern3 = /(\w+@[a-zA-Z_]+?\.[a-zA-Z]{2,6})/gim;
//    //replacedText = replacedText.replace(replacePattern3, '<a href="mailto:$1">$1</a>');
//    replacePattern3 = /([0-9a-zA-Z]+[-._+&])*[0-9a-zA-Z]+@([-0-9a-zA-Z]+[.])+[a-zA-Z]{2,6}/gim
//    replacedText = replacedText.replace(replacePattern3, '<a href="mailto:$&">$&</a>');
    
//    return '<style type="text/css">a:link {color:'+color+';}</style>' + replacedText
}

//Ugly Code
//<a href=\"http://weibo.com/\" rel=\"nofollow\">微博 weibo.com</a>"
function linkToStr(str) {
    str = str.split(">")[1].split("<")[0];
    return str;
    
}

