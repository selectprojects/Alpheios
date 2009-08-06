/**
 * @fileoverview Alph.Datafile - access data from file
 *  
 * Copyright 2008-2009 Cantus Foundation
 * http://alpheios.net
 * 
 * This file is part of Alpheios.
 * 
 * Alpheios is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Alpheios is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @class Alph.Datafile contains the datafile lookup functionality.
 * @constructor
 *
 * @param {String} a_url URL to read
 * @param {String} a_charset character set (or null for no conversion)
 */
Alph.Datafile = function(a_url, a_charset)
{
    // save parameters for possible future reload
    this.url = a_url;
    this.charset = a_charset;
    this.separator = '|';
    this.specialFlag = '@';

    this.data = Alph.MozUtils.read_file(a_url,a_charset);

    // make sure file ends with newline
    if (this.data[this.data.length - 1] != '\n')
        this.data += '\n';
}

Alph.Datafile.prototype =
{
    /**
     * get data
     *
     * @return file contents
     * @type String
     */
    getData: function()
    {
        return this.data;
    },

    /**
     * get separator string
     *
     * @return separator string
     * @type String
     */
    getSeparator: function()
    {
        return this.separator;
    },

    /**
     * set separator string
     *
     * @param {String} a_separator the separator
     */
    setSeparator: function(a_separator)
    {
        this.separator = a_separator;
    },

    /**
     * get special handling flag
     *
     * @return special handling flag
     * @type String
     */
    getSpecialHandlingFlag: function()
    {
        return this.specialFlag;
    },

    /**
     * set special handling flag
     *
     * @param {String} a_specialFlag the special handling flag
     */
    setSpecialHandlingFlag: function(a_specialFlag)
    {
        this.specialFlag = a_specialFlag;
    },

    /**
     * do binary search in data
     * 
     * The data is assumed to be a sorted collection of newline-separated
     * lines.  The key being searched for must be at the start of the line.
     * The key/data separator is appended to the supplied key to ensure
     * that the key is uniquely identified.
     * 
     * Multiple lines with the same key are allowed.  The offset of the first
     * such line will be returned.
     *
     * @param {String} a_key   key to search for
     * 
     * @return offset of key in data or -1 if not found
     * @type int
     */
    binarySearch: function(a_key)
    {
        a_key += this.separator;

        const tlen = a_key.length;
        var mid;
        var midStr;

        // start with entire range of data
        var beg = 0;
        var end = this.data.length - 1;

        // while data still remains
        while (beg < end)
        {
            // find line containing midpoint of remaining data
            mid = this.data.lastIndexOf('\n', (beg + end) >> 1) + 1;
            midStr = this.data.substr(mid, tlen);

            // if too high, restrict to first half
            if (a_key < midStr)
                end = mid - 1;
            // if too low, restrict to second half
            else if (a_key > midStr)
                beg = this.data.indexOf('\n', mid) + 1;
            // if equal, done
            else
                break;
        }

        // if found, back up to first line with key
        if (beg < end)
        {
            // while non-empty preceding line exists
            while (mid >= 2)
            {
                // find start of preceding line
                prec = this.data.lastIndexOf('\n', mid - 2) + 1;

                // if preceding line has different key then done,
                // else back up to preceding line
                midStr = this.data.substr(prec, tlen);
                if (a_key != midStr)
                    break;
                mid = prec;
            }

            return mid;
        }

        // not found
        return -1;
    },

    /**
     * find data by key
     *
     * The data is assumed to be suitable for search using #binarySearch
     * 
     * @param {String} a_key    key to search for
     * 
     * @returns subset of data matching key, else null
     * @type String
     *
     */
    findData: function(a_key)
    {
        // if key not found at all, return empty string
        start = this.binarySearch(a_key);
        if (start == -1)
            return null;

        const tlen = a_key.length;
        end = start;

        // while more lines remain
        while (end < this.data.length)
        {
            // find start of next line
            end = this.data.indexOf('\n', end) + 1;
            if (end == 0)
                end = this.data.length;

            // if next line has different key then done,
            // else include this line in output
            test = this.data.substr(end, tlen);
            if (a_key != test)
                break;
        }

        return this.data.substring(start, end);
    }
};
