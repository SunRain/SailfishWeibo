.pragma library

var reg = /http:\/\/[\w-]*(\.[\w-]*)+/ig;

function replaceReg(str){
    return str=str.replace(/([^>=\]])((http|https|ftp|rtsp|mms):(\/\/|\\\\)[A-Za-z0-9%\-_@]+\.[A-Za-z0-9%\-_@]+[A-Za-z0-9\.\/=\?%\-&_~`@\[\]\':\+!;]*)/gi,"$1<a href=\"$2\" target='_blank'>$2</a>");
}

