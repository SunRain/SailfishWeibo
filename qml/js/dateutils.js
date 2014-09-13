/*
 * Copyright 2013 Canonical Ltd.
 *
 * This file is part of ubuntu-rssreader-app.
 *
 * ubuntu-rssreader-app is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * ubuntu-rssreader-app is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

.pragma library

var MILLIS_IN_SECOND = 1000
var SECONDS_LIMIT = 60 * MILLIS_IN_SECOND; // used as reference
var MINUTES_LIMIT = 60 * SECONDS_LIMIT;    // print minutes up to 1h
var HOURS_LIMIT = 12 * MINUTES_LIMIT;      // print hours up to 12h
var DAY_LIMIT = 24 * MINUTES_LIMIT;        // print '<val> days ago' up to 30 days back
var DAYS_LIMIT = 30 * DAY_LIMIT;           // print '<val> days ago' up to 30 days back

// Convert date string to a number of seconds since 1970-01-01
function parseDate(dateAsStr) {
    return new Date(dateAsStr).getTime()/MILLIS_IN_SECOND;
}

// date is a number of seconds since  1970-01-01
function formatRelativeTime(i18n, date) {
    // fallback if none of the other formatters matched
    function defaultFallbackFormat(then) {
        // TRANSLATORS: this is a time formatting string,
        // see http://qt-project.org/doc/qt-5.0/qtqml/qml-qtquick2-date.html#details for valid expressions
        return Qt.formatDateTime(then, i18n.tr("MMMM d"))
    }

    // Simple matches all diffs < limit, formats using the format function.
    function SimpleFormatter(limit, format) {
        this.matches = function (now, then, diff) { return diff < limit }
        this.format = format
    }

    // Matches yesterday date
    function YesterdayFormatter() {
        this.matches = function (now, then, diff) {
            return diff < DAY_LIMIT && now.getDate() !== then.getDate();
        }
        this.format = function (now, then, diff) {
            return i18n.tr("Yesterday at %1").arg(
                        /* TRANSLATORS: this is a time formatting string,
                           see http://qt-project.org/doc/qt-5.0/qtqml/qml-qtquick2-date.html#details for valid expressions */
                        Qt.formatDateTime(then, i18n.tr("h:mm AP")))
        }
    }

    // Matches up to 7 days ago (formats date as a weekday + time)
    function WeekFormatter() {
        this.matches = function (now, then, diff) {
            return diff < 7 * DAY_LIMIT
        }
        this.format = function (now, then, diff) {
            // TRANSLATORS: this is a time formatting string,
            // see http://qt-project.org/doc/qt-5.0/qtqml/qml-qtquick2-date.html#details for valid expressions
            return Qt.formatDateTime(then, i18n.tr("ddd, h:mm AP"));
        }
    }

    // An array of formatting object processed from 0 up to a matching object.
    // If none of the object matches a default fallback formatter will be used.
    var FORMATTERS = [
                new SimpleFormatter(SECONDS_LIMIT, function (now, then, diff) { return i18n.tr("A few seconds ago...") }),
                new SimpleFormatter(MINUTES_LIMIT, function (now, then, diff) {
                    var val = Math.floor(diff / SECONDS_LIMIT)
                    return i18n.tr("%1 minute ago", "%1 minutes ago", val).arg(val)
                }),
                new SimpleFormatter(HOURS_LIMIT, function (now, then, diff) {
                    var val = Math.floor(diff / MINUTES_LIMIT)
                    return i18n.tr("%1 hour ago", "%1 hours ago", val).arg(val)
                }),
                new YesterdayFormatter(),
                new WeekFormatter(),
                new SimpleFormatter(DAYS_LIMIT, function (now, then, diff) {
                    var val = Math.floor(diff / DAY_LIMIT)
                    return i18n.tr("%1 day ago", "%1 days ago", val).arg(val)
                })
            ]

    function formatDiff(now, then, diff) {
        for (var i=0; i<FORMATTERS.length; ++i) {
            var formatter = FORMATTERS[i]
            if (formatter.matches(now, then, diff)) {
                return formatter.format(now, then, diff)
            }
        }
        return defaultFallbackFormat(then)
    }

    var now = new Date();
    var then = new Date(date*MILLIS_IN_SECOND);
    var diff = now - then;
    var formattedDiff = formatDiff(now, then, diff);
    return formattedDiff;
}
