.pragma library

/* JSONPath 0.8.6 - XPath for JSON
 *
 * Copyright (c) 2007 Stefan Goessner (goessner.net)
 * Licensed under the MIT licence.
 */

var jsonPath = (function () {
    "use strict";

    var options = {
            resultType: "VALUE"
        },
        result,
        $;

    function normalize(expr) {
        var subx = [];
        return expr.replace(/[\['](\??\(.*?\))[\]']|\['(.*?)'\]/g, function ($0, $1, $2) {
            return "[#" + (subx.push($1 || $2) - 1) + "]";
        })
            .replace(/'?\.'?|\['?/g, ";")
            .replace(/;;;|;;/g, ";..;")
            .replace(/;$|'?\]|'$/g, "")
            .replace(/#([0-9]+)/g, function ($0, $1) {
                return subx[$1];
            });
    }

    function asPath(path) {
        var x = path.split(";"),
            p = "$";
        for (var i = 1, n = x.length; i < n; i++) {
            p += /^[0-9*]+$/.test(x[i]) ? ("[" + x[i] + "]") : ("['" + x[i] + "']");
        }
        return p;
    }

    function store(p, v) {
        if (p) {
            result[result.length] = options.resultType === "PATH" ? asPath(p) : v;
        }
        return !!p;
    }

    function trace(expr, val, path) {
        if (expr !== "") {
            var x = expr.split(";"),
                loc = x.shift();
            x = x.join(";");
            if (val && val.hasOwnProperty(loc)) {
                trace(x, val[loc], path + ";" + loc);
            }
            else if (loc === "*") {
                walk(loc, x, val, path, function (m, l, x, v, p) {
                    trace(m + ";" + x, v, p);
                });
            }
            else if (loc === "..") {
                trace(x, val, path);
                walk(loc, x, val, path, function (m, l, x, v, p) {
                    return typeof v[m] === "object" && trace("..;" + x, v[m], p + ";" + m);
                });
            }
            else if (/^\(.*?\)$/.test(loc)) {
                trace(protectedEval(loc, val) + ";" + x, val, path);
            }
            else if (/^\?\(.*?\)$/.test(loc)) {
                if (val instanceof Array) {
                    walk(loc, x, val, path, function (m, l, x, v, p) {
                        if (protectedEval(l.replace(/^\?\((.*?)\)$/, "$1"), v[m])) {
                            trace(m + ";" + x, v, p);
                        }
                    });
                } else if (typeof val === "object") {
                    if (protectedEval(loc.replace(/^\?\((.*?)\)$/, "$1"), val)) {
                        trace(x, val, path);
                    }
                }
            }
            else if (/^(-?[0-9]*):(-?[0-9]*):?([0-9]*)$/.test(loc)) {
                slice(loc, x, val, path);
            }
            else if (/,/.test(loc)) {
                for (var s = loc.split(/'?,'?/), i = 0, n = s.length; i < n; i++) {
                    trace(s[i] + ";" + x, val, path);
                }
            }
        }
        else {
            store(path, val);
        }
    }

    function walk(loc, expr, val, path, f) {
        if (val instanceof Array) {
            for (var i = 0, n = val.length; i < n; i++) {
                if (i in val) {
                    f(i, loc, expr, val, path);
                }
            }
        }
        else if (typeof val === "object") {
            for (var m in val) {
                if (val.hasOwnProperty(m)) {
                    f(m, loc, expr, val, path);
                }
            }
        }
    }

    function slice(loc, expr, val, path) {
        if (val instanceof Array) {
            var len = val.length,
                start = 0,
                end = len,
                step = 1;
            loc.replace(/^(-?[0-9]*):(-?[0-9]*):?(-?[0-9]*)$/g, function ($0, $1, $2, $3) {
                start = parseInt($1 || start, 10);
                end = parseInt($2 || end, 10);
                step = parseInt($3 || step, 10);
            });
            start = (start < 0) ? Math.max(0, start + len) : Math.min(len, start);
            end = (end < 0) ? Math.max(0, end + len) : Math.min(len, end);
            for (var i = start; i < end; i += step) {
                trace(i + ";" + expr, val, path);
            }
        }
    }

    function protectedEval(x, _v) {
        try {
            return $ && _v && eval(x.replace(/(@|'[^']+')/g, function (match, where) {
                return where[0] !== '\'' ? "_v" : match;
            }));
        }
        catch (e) {
            throw new SyntaxError("jsonPath: " + e.message + ": " + x.replace(/(@|'[^']+')/g, function (match, where) {
                return where[0] !== '\'' ? "_v" : match;
            }));
        }
    }

    return function (obj, expr, arg) {
        options = arg || options;
        result = [];
        if (obj && expr) {
            $ = obj;
            trace(normalize(expr).replace(/^\$;?/, ""), obj, "$");
        }
        return result.length ? result : false;
    };
})();

