/*
 * @fileoverview Greek extension of Alph.LanguageTool class
 * @version $Id$
 *
 * Copyright 2008 Cantus Foundation
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
 * 
 * Morpheus is from Perseus Digital Library http://www.perseus.tufts.edu
 * and is licensed under the Mozilla Public License 1.1. 
 * You should have received a copy of the MPL 1.1
 * along with this program. If not, see http://www.mozilla.org/MPL/MPL-1.1.html.
 * 
 * The Smyth Grammar and LSJ Meanings come from the Perseus Digital Library
 * They are licensed under Creative Commons NonCommercial ShareAlike 3.0
 * License http://creativecommons.org/licenses/by-nc-sa/3.0/us
 */

/**
 * @class  Alph.LanguageToolSet.greek extends {@link Alph.LanguageTool} to define
 * Greek-specific functionality for the alpheios extension.
 *
 * @constructor
 * @param {String} a_language  the source language for this instance
 * @param {Properties} a_properties additional properties to set as private members of
 *                                  the object (accessor methods will be dynamically created)
 * @see Alph.LanguageTool
 */
Alph.LanguageToolSet.greek = function(a_lang, props)
{
    Alph.LanguageTool.call(this,a_lang,{});
};

/**
 * @ignore
 */
Alph.LanguageToolSet.greek.prototype = new Alph.LanguageTool();

/**
 * Flag to indicate that this class extends Alph.LanguageTool.
 * (Shouldn't be necessary but because they are not packaged in the same extension
 * the instanceof operator won't work.)
 * TODO - address this by making Alph.LanguageTool a JS Module??
 * @type boolean
 */
Alph.LanguageToolSet.greek.implementsAlphLanguageTool = true;

/**
 * Greek-specific startup method in the derived instance which
 * loads the dictionary file. Called by the derived instance
 * keyed by the preference setting 'extensions.alpheios.greek.methods.startup'.
 * @returns true if successful, otherwise false
 * @type boolean
 */
Alph.LanguageToolSet.greek.prototype.loadDictionary = function()
{
    try
    {
        this.dictionary = 
            new Alph.Datafile("chrome://alpheios-greek/content/lsj-meanings.dat",
                              "UTF-8", ",");
        Alph.util.log("Loaded Greek dictionary [" + this.dictionary.getData().length + " bytes]");
    }
    catch (ex)
    {
        alert("error loading dictionary: " + ex);
        return false;
    }
    return true;
};

/**
 *  Mapping table which maps the part of speech or mood
 *  to the key name for producing the inflection table
 *  Format is:
 *      pofs or mood: { keys: [array of inflectable table keys]
 *                      links: [array of other links] }
 */
Alph.LanguageToolSet.greek.INFLECTION_MAP =
{     noun: { keys: ['noun'], links: [] },
};

Alph.LanguageToolSet.greek.IRREG_VERBS =
[
];

/**
 * Greek-specific implementation of {@link Alph.LanguageTool#getInflectionTable}.
 * @param {Node} a_node the node containing the target word
 * @param {String} a_params optional requested parameters
 * @return the parameters object for the inflection window
 */
Alph.LanguageToolSet.greek.prototype.getInflectionTable = function(a_node, a_params)
{
    var params = a_params || {};

    // initialize the suffix arrays
    // TODO should flip this to be a single object keys on infl_type
    params.suffixes = {};
    params.entries = {};

    var form = Alph.$(".alph-word",a_node).attr("context");

    for (var infl_type in Alph.LanguageToolSet.greek.INFLECTION_MAP )
    {
        var key = Alph.LanguageToolSet.greek.INFLECTION_MAP[infl_type].keys[0];
        params.suffixes[key] = [];
        params.entries[key] = [];
    }

    // The word will have one more more alph-infl-set elements
    // Each alph-infl-set element should have a alph-suffix element
    // and one or more alph-infl elements.  Iterate through the alph-infl-sets
    // retrieving the alph-suffix elements which are applicable to
    // each supported part of speech
    Alph.$(".alph-infl-set",a_node).each(
        function(i)
        {
            var dict = Alph.$(this).siblings(".alph-dict");
            var word = Alph.$(this).attr("context");

            // check for the pofs first as a child of this element, and if not present,
            // then from the sibling dictionary entry
            var my_pofs;
            var infl_pofs = Alph.$(".alph-pofs",this);
            if (infl_pofs.length == 0)
            {
                infl_pofs = Alph.$(".alph-pofs",dict)
            }

            // check for irregular verbs

            var dict_hdwd = Alph.$(".alph-hdwd",dict).text();
            // remove the trailing :
            dict_hdwd = dict_hdwd.replace(/\:\s*$/,'');
            Alph.util.log("hdwd for inflection set: " + dict_hdwd);

            var irregular = false;
            for (var i=0; i< Alph.LanguageToolSet.greek.IRREG_VERBS.length; i++)
            {
                if (dict_hdwd == Alph.LanguageToolSet.greek.IRREG_VERBS[i])
                {
                    // reset the context
                    params.hdwd = dict_hdwd;
                    irregular = true;
                    break;
                }
            }
            Alph.util.log("irregular:" + irregular);
            var infls = {};

            // gather the moods for the verbs
            // TODO - look at handling multiple cases separately for the nouns and adjectives?
            Alph.$(".alph-infl",this).each(
                function()
                {
                    // some verb moods (infinitive, imperative and gerundive) link to
                    // a supplemental table rather than primary verb pofs table

                    var mood = Alph.$(".alph-mood",this).attr('context');
                    if (Alph.LanguageToolSet.greek.INFLECTION_MAP[mood])
                    {
                        infls[Alph.LanguageToolSet.greek.INFLECTION_MAP[mood].keys[0]] = Alph.$(this).get(0);
                    }
                }
            );
            if (irregular)
            {
                infls[Alph.LanguageToolSet.greek.INFLECTION_MAP['verb_irregular'].keys[0]] = Alph.$(this).get(0);
            }
            for (var pofs in Alph.LanguageToolSet.greek.INFLECTION_MAP)
            {
                var map_pofs = Alph.LanguageToolSet.greek.INFLECTION_MAP[pofs].keys[0];


                // if we couldn't find the part of speech or the part of speech
                // isn't one we support then just move on to the next part of speech
                if ( infl_pofs.length == 0 ||
                     (pofs == 'verb_irregular' && ! irregular) ||  // context pofs for irregular verbs is just 'verb'
                     (pofs != 'verb_irregular' && Alph.$(infl_pofs[0]).attr("context") != pofs)
                   )
                {
                    continue;
                }

                // make sure we look at at least the first inflection from
                // this inflection set. If we need to look at multiple inflections they
                // will already have been identified above.
                // this will also add in a general verb inflection for those verbs which use a supplemental table
                if (! infls[map_pofs] )
                {
                    infls[map_pofs] = Alph.$(".alph-infl",this).get(0)
                }

                for (var infl_type in infls)
                {

                    // if a particular pofs wasn't requested
                    // and this is the first pofs processed, set it
                    // as the default
                    if (typeof params.showpofs == 'undefined')
                    {
                        params.showpofs = infl_type;
                    }
                    params.suffixes[infl_type].push(
                        Alph.$(".alph-suff",this).get());

                    params.entries[infl_type].push(
                        Alph.$(this).parent(".alph-entry").get(0));

                    // duplicate suffixes if necessary
                    var num_pofs = Alph.LanguageToolSet.greek.INFLECTION_MAP[pofs].keys.length;
                    for (var i=1; i<num_pofs; i++)
                    {
                        var extra_pofs = Alph.LanguageToolSet.greek.INFLECTION_MAP[pofs].keys[i];
                        params.suffixes[extra_pofs].push(
                        Alph.$(".alph-suff",this).get());
                    }

                    // identify the correct file and links for the inflection type
                    // being displayed
                    // TODO - this doesn't work right if multiple different possibilities
                    // of the same pofs (e.g. look at estote). Handle differently.

                    if (params.showpofs == infl_type)
                    {
                        params.links = Alph.LanguageToolSet.greek.INFLECTION_MAP[pofs].links;
                        //Alph.LanguageToolSet.greek.setInflectionXSL(params,infl_type,pofs,a_node,Alph.$(this).get(0));
                    }

                } // end infl-type
            }
        }
    );
    // identify the correct xslt parameters for the requested inflection type
    if (params.showpofs)
    {
        Alph.LanguageToolSet.greek.setInflectionXSL(params,params.showpofs,form);
        // TODO -remove this HACK which suppresses the Javascript matching algorithm
        //params.suppress_match = true;
        params.always_expand = true;
    }
    return params;
}

/**
 * Helper method to set the XML/XSLT params for the inflection table
 * @param {String} a_params the other params for the window
 * @param {String} a_infl_type the inflection type
 */
Alph.LanguageToolSet.greek.setInflectionXSL = function(a_params,a_infl_type,a_form)
{
    a_params.xslt_params = {};
    a_params.xslt_params.fragment = 1;
    a_params.xslt_params.selected_endings = a_params.entries[a_infl_type];
    a_params.xslt_params.form = a_form || "";

    // get rid of the selected endings parameter if we couldn't find any
    if (typeof a_params.xslt_params.selected_endings == "undefined" ||
         a_params.xslt_params.selected_endings.length == 0)
    {
        delete a_params.xslt_params.selected_endings;
    }

    if (a_infl_type == 'verb_irregular')
    {
        a_params.xml_url = 'chrome://alpheios-greek/content/inflections/alph-verb-conj-irreg.xml';
        a_params.xslt_url = 'chrome://alpheios-greek/skin/alph-verb-conj-irreg.xsl';
        a_params.xslt_params.hdwd = a_params.hdwd;
    }
    else if ( a_infl_type.indexOf('verb_') == 0 )
    {
        a_params.xml_url = 'chrome://alpheios-greek/content/inflections/alph-verb-conj-supp.xml';
        a_params.xslt_url = 'chrome://alpheios-greek/skin/alph-verb-conj-supp.xsl';

        var mood = (a_infl_type.split(/_/))[1];
        a_params.xslt_params.mood = mood;

    }
    else if (a_infl_type == 'verb')
    {
        a_params.xml_url = 'chrome://alpheios-greek/content/inflections/alph-verb-conj.xml';
        a_params.xslt_url = 'chrome://alpheios/skin/alph-verb-conj-group.xsl';

        if (! a_params.order )
        {
            // default sort order
            a_params.order = "voice-conj-mood";
        }

        var order = a_params.order.split('-');
        if (order.length > 0)
        {
            a_params.xslt_params.group4 = order[0];
            a_params.xslt_params.group5 = order[1];
            a_params.xslt_params.group6 = order[2];
        }
    }
    else
    {
        a_params.xml_url =
            'chrome://alpheios-greek/content/inflections/alph-infl-' + a_infl_type + '.xml';
        a_params.xslt_url = 'chrome://alpheios-greek/skin/alph-infl-' + a_infl_type + '.xsl';

        if (a_params.order )
        {

            var order = a_params.order.split('-');
            if (order.length > 0)
            {
                a_params.xslt_params.group4 = order[0];
                a_params.xslt_params.group5 = order[1];
                a_params.xslt_params.group6 = order[2];
            }
        }

    }

}

/**
 * Greek specific inflection table display code
 * @param
 * @param
 */
Alph.LanguageToolSet.greek.prototype.handleInflectionDisplay = function(a_tbl)
{
    // collapse all non-primary endings
    // TODO - this may only be temporary - experimenting with different approaches
    //window.opener.Alph.util.log("Handling inflection display");
    var ret_cells = [];
    var show_stem_classes = [];
    Alph.$("td.ending-group",a_tbl).each(
        function(c_i)
        {
            var endings = Alph.$("span.ending", this);
            var children = Alph.$(this).children();
            // collapse lists of endings unless the cell has a highlighted ending,
            // in which case just display them all
            if (Alph.$(endings).length >0 )
            {
                var last_col_index = null;
                children.each(

                    function(a_i)
                    {
                        if (Alph.$(this).hasClass('ending'))
                        {
                            // reset the ending index
                            last_col_index=null;
                            // never hide selected or matched endings
                            // and make sure to unhide any endings
                            // of the same stem class
                            if (Alph.$(this).hasClass("highlight-ending")
                                // TODO - need to disambiguate stems for matched 
                                //(vs. selected) endings
                                && ! Alph.$(this).hasClass("matched")) 
                            {
                                var stem_class = Alph.$(this).attr("stem-class");
                                if (stem_class != null && stem_class != '')
                                {
                                    stem_class.split(/\s/).forEach(
                                        function(a_stem,a_si)
                                        {
                                            show_stem_classes.push(a_stem);
                                        }
                                    );

                                }

                            }
                            // never hide the primary endings
                            else if (! Alph.$(this).hasClass("primary"))
                            {
                                Alph.$(this).addClass("ending-collapsed");
                                Alph.$(this).attr("ending-index",a_i);
                                last_col_index=a_i;

                            }
                        }
                        else if (last_col_index != null &&
                                 (Alph.$(this).hasClass("footnote") || Alph.$(this).hasClass("footnote-delimiter")))
                        {
                                Alph.$(this).addClass("ending-collapsed");
                                Alph.$(this).attr("ending-index",last_col_index);

                        }
                        else
                        {
                            // do nothing
                        }
                    }
                );

                var realIndex = Alph.$(this).get(0).realIndex;
                ret_cells.push(this);

            }
        }
    );

    show_stem_classes = Alph.$.unique(show_stem_classes);
    show_stem_classes.forEach(
        function(a_stemclass,a_i)
        {
            Alph.$("#" + a_stemclass,a_tbl).addClass("highlight-ending");
            
            // don't unhide the related endings for now -- too cluttered
            //var like_stems = Alph.$("span.ending[stem-class='" + a_stemclass + "']",a_tbl);
            //Alph.$(like_stems).each(
                //function() {
                    //if (Alph.$(this).hasClass("ending-collapsed"))
                    //{
                        //Alph.$(this).removeClass("ending-collapsed");
                        //var ending_index = Alph.$(this).attr("ending-index");
                        //Alph.$(this).nextAll("[ending-index='" + ending_index + "']").removeClass("ending-collapsed");
                    //}
                //}
                
            //)

        }
    );
    return ret_cells;
}

/**
 * Greek-specific implementation of {@link Alph.LanguageTool#postTransform}.
 * Looks up the lemma in the file of LSJ short meanings
 */
Alph.LanguageToolSet.greek.prototype.postTransform = function(a_node)
{
    var dict = this.dictionary;
    var sep = this.dictionary.getSeparator();
    Alph.$(".alph-entry", a_node).each(
        function()
        {
            // get headword, remove trailing ": "
            var hdwd = Alph.$(".alph-dict", this).attr("key");
            var meanData = dict.findData(hdwd);

            // if not found
            if (!meanData)
            {
                // count trailing digits
                var toRemove = 0;
                for (; toRemove <= hdwd.length; ++toRemove)
                {
                    // if not a digit, done
                    var c = hdwd.substr(hdwd.length - (toRemove + 1), 1);
                    if ((c < "0") || ("9" < c))
                        break;
                }

                // if trailing digits exist, remove them and retry
                if (toRemove > 0)
                {
                    hdwd = hdwd.substr(0, hdwd.length - toRemove);
                    meanData = dict.findData(hdwd);
                }
            }

            // if entry found
            if (meanData)
            {
                // find start and end of definition
                var startDef = meanData.indexOf(sep, 0) + 1;
                var endDef = meanData.indexOf('\n', startDef);

                // build meaning element
                var meanElt = '<div class="alph-mean">' +
                              meanData.substr(startDef, endDef - startDef) +
                              '</div>';

                // insert meaning into document
                Alph.util.log("adding " + meanElt);
                Alph.$(".alph-dict", this).after(meanElt);
            }
            else
            {
                Alph.util.log("meaning for " + hdwd + " not found");
            }
        }
    );
}
