/**
 * @fileoverview Arabic extension of Alph.LanguageTool class
 * @version $Id$
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

Alph.LanguageToolFactory.addLang('arabic','LanguageTool_Arabic');

/**
 * @class  Arabic implementation of {@link Alph.LanguageTool} 
 * @extends Alph.LanguageTool
 * @param {String} a_language  the source language for this instance
 * @param {Properties} a_properties additional properties to set as private members of
 *                                  the object (accessor methods will be dynamically created)
 */
Alph.LanguageTool_Arabic = function(a_lang, props)
{
    Alph.LanguageTool.call(this,a_lang,{});
};

/**
 * @ignore
 */
Alph.LanguageTool_Arabic.prototype = new Alph.LanguageTool();

/**
 * Arabic-specific implementation of {@link Alph.LanguageTool#observePrefChange}
 *
 * calls loadLexIds if the default full dictionary changed
 * @param {String} a_name the name of the preference which changed
 * @param {Object} a_value the new value of the preference
 */
Alph.LanguageTool_Arabic.prototype.observePrefChange = function(a_name,a_value)
{
    if (a_name.indexOf('dictionaries.full') != -1)
    {
        this.loadLexIds();
        this.lexiconSetup();
    }
}

/**
 * Arabic-specific startup method in the derived instance which
 * xslt for stripping the unicode. Called by the derived instance
 * keyed by the preference setting 'extensions.alpheios.greek.methods.startup'.
 * @returns true if successful, otherwise false
 * @type boolean
 */
Alph.LanguageTool_Arabic.prototype.loadStripper = function()
{
    try
    {
        this.d_stripper =
            Alph.BrowserUtils.getXsltProcessor('alpheios-ara-unistrip.xsl');
    }
    catch (ex)
    {
        alert("error loading xslt alpheios-ara-unistrip.xsl: " + ex);
        return false;
    }

    return true;
}

/**
 * Arabic-specific implementation of {@link Alph.LanguageTool#getLemmaId}.
 *
 * @param {String} a_lemmaKey the lemma key
 * @returns {Array} (lemma id, lexicon code) or (null, null) if not found
 * @type Array
 */
Alph.LanguageTool_Arabic.prototype.getLemmaId = function(a_lemmaKey)
{
    // for each lexicon
    for (var i = 0; i < this.d_fullLexCode.length; ++i)
    {
        // get data from ids file
        var lemma_id =
            Alph.LanguageTool_Arabic.lookupLemma(a_lemmaKey,
                                                 null,
                                                 this.d_idsFile[i],
                                                 this.d_stripper)[1];
        if (lemma_id)
            return Array(lemma_id, this.d_fullLexCode[i]);
    }

    this.s_logger.warn("id for " +
                  a_lemmaKey +
                  " not found [" +
                  this.d_fullLexCode.join() + ']');

    return Array(null, null);
}

/**
 * Lookup lemma
 *
 * @param {String} a_lemma original lemma
 * @param {String} a_key key to look up or null
 * @param {Alph.Datafile} a_datafile datafile to search with key
 * @param a_stripper transform to remove diacritics, etc.
 * @returns {Array} (key, data)
 * @type String
 */
Alph.LanguageTool_Arabic.lookupLemma =
function(a_lemma, a_key, a_datafile, a_stripper)
{
    if (!a_datafile)
        return Array(null, null);

    // try key or lemma first
    var key = (a_key ? a_key : a_lemma);
    var data = a_datafile.findData(key);
    var x = null;

    // if not found, try various drops
    if (!data)
    {
        var toDrop = ["tanwin", "hamza", "harakat", "shadda"];
        for (i in toDrop)
        {
            a_stripper.setParameter(null, "e_in", key);
            a_stripper.setParameter(null, "e_toDrop", toDrop[i]);
            if (!x)
                x = (new DOMParser()).parseFromString("<dummy/>", "text/xml");
            var key2 = a_stripper.transformToDocument(x)
                                 .documentElement.textContent;

            // if not a new key, don't bother trying to find it
            if (key2 == key)
                continue;

            // if found, stop looking
            key = key2;
            data = a_datafile.findData(key);
            if (data)
                break;
        }
    }

    // if data found
    if (data)
    {
        // find start and end of definition
        var startText = data.indexOf(a_datafile.getSeparator(), 0) + 1;
        var endText = data.indexOf('\n', startText);
        if (data.charAt(endText - 1) == '\r')
            endText--;

        // real data found
        if (data)
            return Array(key, data.substr(startText, endText - startText));
    }

    // nothing found
    return Array(a_lemma, null);
}
