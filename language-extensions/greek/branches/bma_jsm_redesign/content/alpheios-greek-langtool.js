/*
 * @fileoverview Greek extension of Alph.LanguageTool class
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

Alph.LanguageToolFactory.addLang('greek','LanguageTool_Greek');

/**
 * @class  Alph.LanguageTool_Greek extends {@link Alph.LanguageTool} to define
 * Greek-specific functionality for the alpheios extension.
 *
 * @constructor
 * @param {String} a_language  the source language for this instance
 * @param {Properties} a_properties additional properties to set as private members of
 *                                  the object (accessor methods will be dynamically created)
 * @see Alph.LanguageTool
 */
Alph.LanguageTool_Greek = function(a_lang, props)
{
    Alph.LanguageTool.call(this,a_lang,{});
};

/**
 * @ignore
 */
Alph.LanguageTool_Greek.prototype = new Alph.LanguageTool();

/**
 * Greek-specific startup method in the derived instance which
 * loads the dictionary files. Called by the derived instance
 * keyed by the preference setting 'extensions.alpheios.greek.methods.startup'.
 * @returns true if successful, otherwise false
 * @type boolean
 */
Alph.LanguageTool_Greek.prototype.loadShortDefs = function()
{
    this.d_defsFile = Array();
    this.d_shortLexCode =
            Alph.BrowserUtils.getPref("dictionaries.short", this.d_sourceLanguage).split(',');

    for (var i = 0; i < this.d_shortLexCode.length; ++i)
    {
        // load the local short definitions dictionary data file
        try
        {
            this.d_defsFile[i] =
                new Alph.Datafile(
                        "chrome://alpheios-greek/content/dictionaries/" +
                        this.d_shortLexCode[i] +
                        "/grc-" +
                        this.d_shortLexCode[i] +
                        "-defs.dat",
                        "UTF-8");
            Alph.BrowserUtils.log(
                "Loaded Greek defs for " +
                this.d_shortLexCode[i] +
                "[" +
                this.d_defsFile[i].getData().length +
                " bytes]");

        }
        catch (ex)
        {
            alert("error loading definitions: " + ex);
            return false;
        }
    }
    return true;
};

/**
 * Greek-specific startup method in the derived instance which
 * loads the lemma id lookup file. Called by the derived instance
 * keyed by the preference setting 'extensions.alpheios.greek.methods.startup'.
 * @returns true if successful, otherwise false
 * @type boolean
 */
Alph.LanguageTool_Greek.prototype.loadLexIds = function()
{
    this.d_idsFile = Array();
    this.d_fullLexCode = Alph.BrowserUtils.getPref("dictionaries.full",
                                      this.d_sourceLanguage).split(',');

    for (var i = 0; i < this.d_fullLexCode.length; ++i)
    {
        try
        {
           this.d_idsFile[i] =
                new Alph.Datafile(
                        "chrome://alpheios-greek/content/dictionaries/" +
                        this.d_fullLexCode[i] +
                        "/grc-" +
                        this.d_fullLexCode[i] +
                        "-ids.dat",
                        "UTF-8");
            Alph.BrowserUtils.log(
                "Loaded Greek ids for " +
                this.d_fullLexCode[i] +
                "[" +
                this.d_idsFile[i].getData().length +
                " bytes]");
        }
        catch (ex)
        {
            // the ids file might not exist, in particular for remote, non-alpheios
            // provided dictionaries
            // so just quietly log the error in this case
            // later code must take a null ids file into account
            Alph.BrowserUtils.log("error loading ids: " + ex);
            return false;
        }
    }
    return true;
}

/**
 * Greek-specific startup method in the derived instance which
 * xslt for stripping the unicode. Called by the derived instance
 * keyed by the preference setting 'extensions.alpheios.greek.methods.startup'.
 * @returns true if successful, otherwise false
 * @type boolean
 */
Alph.LanguageTool_Greek.prototype.loadStripper = function()
{
    try
    {
        this.d_stripper = Alph.Util.getXsltProcessor('alpheios','alpheios-unistrip.xsl');
    }
    catch (ex)
    {
        alert("error loading xslt: " + ex);
        return false;
    }

    return true;
}

/**
 *  Mapping table which maps the part of speech or mood
 *  to the key name for producing the inflection table
 *  Format is:
 *      pofs or mood: { keys: [array of inflectable table keys]
 *                      links: [array of other links] }
 */
Alph.LanguageTool_Greek.INFLECTION_MAP =
{     noun: { keys: ['noun'], links: [] },
      adjective: {keys: ['adjective'], links:[] },
      adjective_simplified: {keys: ['adjective_simplified'], links:[] },
      noun_simplified: {keys: ['noun_simplified'], links:[] },
      pronoun: { keys: ['pronoun'],links:[] },
      irregular: { keys: ['pronoun_interrogative'],links:[] },
      article: { keys: ['article'],links:[] },
      numeral: { keys: ['numeral'],links:[] },
      verb: { keys: ['verb'],links:['verb_all'] },
      verb_participle: { keys: ['verb_participle'],links:['verb_all'] },
      verb_all: { keys: ['verb_all'],links:['verb'] },
      adverb: {keys: ['adverb'],links:[]}
};

Alph.LanguageTool_Greek.IRREG_VERBS =
[
];

/**
 * lookup table for pronouns
 * array of pronoun types and the constraints for matching
 * [0] = pronoun type abbreviation 
 *       (matches suffix on the inflection table xml file alph-infl-pronoun-<type>.xml)
 * [1] = Array of possible lemmas for this pronoun type
 * [2] = Optional morpheus stemtype value restriction (when lemma alone isn't enough)
 */
Alph.LanguageTool_Greek.PRONOUNS =
[
    ['dem',['ὅδε','οὗτος','ἐκεῖνος']],
    ['rel',['@ὅς','ὅς']],// there's a special flag on lemma for ὅς
    ['genrel',['ὅστις']],
    ['pers',['ἐγώ','σύ','ἕ']],
    ['indef',['τις']],
    ['inter',['τίς']],
    ['inten',['αὐτός']],
    ['recip',['ἀλλήλων']],
    ['refl',['ἐμαυτοῦ','σαυτοῦ','ἑαυτοῦ','σφεῖς']],
    ['pos',['ἐμός','ἡμέτερος','σός','ὑ̄μέτερος','ὅς','σφέτερος'],['pronoun_pos1','pronoun_pos2','pronoun_pos3']],
    ['pos1',['ἐμός','ἡμέτερος']],
    ['pos2',['σός','ὑ̄μέτερος']],
    ['pos3',['ὅς','σφέτερος']]
];

/**
 * Greek-specific implementation of {@link Alph.LanguageTool#getInflectionTable}.
 * @param {Node} a_node the node containing the target word
 * @param {String} a_params optional requested parameters
 * @return the parameters object for the inflection window
 */
Alph.LanguageTool_Greek.prototype.getInflectionTable = function(a_node, a_params)
{
    var params = a_params || {};

    // initialize the suffix arrays
    // TODO should flip this to be a single object keys on infl_type
    params.entries = {};
    // clear out the links
    params.links = [];

    var form = Alph.$(".alph-word",a_node).attr("context");

    for (var infl_type in Alph.LanguageTool_Greek.INFLECTION_MAP )
    {
        var key = Alph.LanguageTool_Greek.INFLECTION_MAP[infl_type].keys[0];
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
            var stemtype = Alph.$(".alph-stemtype",this).attr("context");
            var lemma = Alph.$(dict).attr("lemma-key");

            // check for the pofs first as a child of this element, and if not present,
            // then from the sibling dictionary entry
            var my_pofs;
            var infl_pofs = Alph.$(".alph-pofs",this);
            if (infl_pofs.length == 0)
            {
                infl_pofs = Alph.$(".alph-pofs",dict)
            }

            // check for irregular verbs

            Alph.BrowserUtils.log("lemma for inflection set: " + lemma);

            var irregular = false;
            for (var i=0; i< Alph.LanguageTool_Greek.IRREG_VERBS.length; i++)
            {
                if (lemma == Alph.LanguageTool_Greek.IRREG_VERBS[i])
                {
                    // reset the context
                    params.hdwd = lemma;
                    irregular = true;
                    break;
                }
            }
            Alph.BrowserUtils.log("irregular:" + irregular);

            var infls = {};

            // gather the moods for the verbs
            // TODO - look at handling multiple cases separately for the nouns and adjectives?
            Alph.$(".alph-infl",this).each(
                function()
                {
                    // some verb moods (infinitive, imperative and gerundive) link to
                    // a supplemental table rather than primary verb pofs table

                    var mood = Alph.$(".alph-mood",this).attr('context');
                    if (Alph.LanguageTool_Greek.INFLECTION_MAP[mood])
                    {
                        infls[Alph.LanguageTool_Greek.INFLECTION_MAP[mood].keys[0]] = Alph.$(this).get(0);
                    }
                }
            );
            if (irregular)
            {
                infls[Alph.LanguageTool_Greek.INFLECTION_MAP['verb_irregular'].keys[0]] = Alph.$(this).get(0);
            }
            for (var pofs in Alph.LanguageTool_Greek.INFLECTION_MAP)
            {
                var map_pofs = Alph.LanguageTool_Greek.INFLECTION_MAP[pofs].keys[0];


                var check_pofs = pofs.replace(/_simplified$/,'');
                // if we couldn't find the part of speech or the part of speech
                // isn't one we support then just move on to the next part of speech
                if ( infl_pofs.length == 0 ||
                     Alph.$(infl_pofs[0]).attr("context") != check_pofs)
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

                    params.entries[infl_type].push(
                        Alph.$(this).parent(".alph-entry").get(0));

                    // identify the correct file and links for the inflection type
                    // being displayed
                    if (params.showpofs == infl_type)
                    {
                        params.links = Alph.LanguageTool_Greek.INFLECTION_MAP[pofs].links;
                    

                        // if it's a pronoun, what type?
                        if (infl_type.match(/^pronoun/))
                        {
                             params.type = '';
                             for (var i=0; i< Alph.LanguageTool_Greek.PRONOUNS.length; i++)
                             {
                                var pronoun_list = Alph.LanguageTool_Greek.PRONOUNS[i];
                                var type = pronoun_list[0];
                                for (var j=0; j < pronoun_list[1].length; j++)
                                {

                                    if (lemma == pronoun_list[1][j])
                                    {
                                        // if there is an additional stemtype restriction
                                        // make sure it matches
                                        if (typeof pronoun_list[2] == "undefined" 
                                            || (stemtype == pronoun_list[2]))
                                        {
                                            if (params.type == '')                                            {
                                                params.type = type;
                                            }
                                            else if (params.type != type)
                                            {
                                                // TODO handling multiple pronoun
                                                // types for a single lemma isn't
                                                // implemented 
                                            }
                                        }
                                        break;
                                    }
                                }
                            }
                            Alph.BrowserUtils.log("Pronoun type="+params.type);
                        } // end pronoun identification
                    }
                } // end infl-type
            }
        }
    );
    // identify the correct xslt parameters for the requested inflection type
    if (params.showpofs)
    {
        params.html_url = "chrome://alpheios-greek/content/html/alph-infl-substantive.html";
        Alph.LanguageTool_Greek.setInflectionXSL(params,params.showpofs,form);
        
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
Alph.LanguageTool_Greek.setInflectionXSL = function(a_params,a_infl_type,a_form)
{
    a_params.xslt_params = {};
    a_params.xslt_params.fragment = 1;
    a_params.xslt_params.selected_endings = a_params.entries[a_infl_type];
    a_params.xslt_params.form = a_form || "";
    a_params.xslt_params.normalize_greek = true;


    // get rid of the selected endings parameter if we couldn't find any
    if (typeof a_params.xslt_params.selected_endings == "undefined" ||
         a_params.xslt_params.selected_endings.length == 0)
    {
        delete a_params.xslt_params.selected_endings;
    }

    if (a_infl_type.match(/^verb/))
    {
        a_params.xml_url = 'chrome://alpheios-greek/content/inflections/alph-infl-verb-paradigms.xml';
        a_params.xslt_processor = Alph.Util.getXsltProcessor('alpheios','alph-infl-paradigm.xsl');
        if (a_infl_type.match(/_all$/))
        {
            a_params.xslt_params.paradigm_id = 'all';
            a_params.xslt_params.match_pofs = 'verb';
            a_params.xslt_params.selected_endings = 
                a_params.entries.verb.concat(a_params.entries.verb_participle);
        }
        else if (typeof a_params.paradigm_id != 'undefined' && a_params.paradigm_id != null)
        {
            a_params.xslt_params.paradigm_id = a_params.paradigm_id;
        }
        a_params.html_url = "chrome://alpheios-greek/content/html/alph-infl-verb-paradigms.html";
        a_params.title = 'alph-infl-title-verb-paradigms';
        a_params.xslt_params.normalize_greek = false;
    }
    else if (a_infl_type == 'article')
    {
             a_params.xml_url =
            'chrome://alpheios-greek/content/inflections/alph-infl-' + a_infl_type + '.xml';
        a_params.xslt_processor = Alph.Util.getXsltProcessor('alpheios','alph-infl-single-grouping.xsl');
        a_params.xslt_params.group4 = 'gend';
        a_params.xslt_params.match_form = true;
    }
    else if (a_infl_type.match(/^pronoun/))
    {
        a_params.title = 'alph-infl-title-pronoun-' + a_params.type;
        // morpheus specifies 'irregular' as the part of speech for the interrogative pronoun
        if (a_infl_type.match(/_interrogative$/))
        {
            a_params.xslt_params.match_pofs = 'irregular';
            a_infl_type = a_infl_type.replace(/_interrogative$/,'');
        }
        a_params.xml_url =
            'chrome://alpheios-greek/content/inflections/alph-infl-' +
            a_infl_type + '-' + a_params.type + '.xml';
        // pronoun tables contain full forms
        a_params.xslt_params.match_form = true;
        
        if (a_params.type == 'dem')
        {
            a_params.xslt_processor = Alph.Util.getXsltProcessor('alpheios','alph-infl-substantive.xsl');
            a_params.xslt_params.group4 = 'hdwd';
        }
        else if (a_params.type == 'refl' || a_params.type.match(/^pos/))
        {
            a_params.xslt_processor = Alph.Util.getXsltProcessor('alpheios','alph-infl-substantive.xsl');
            a_params.xslt_params.group4 = 'pers';
            if (a_params.type.match(/^pos/))
            {
                a_params.xslt_params.group1 = 'objnum';
            }
        }
        else if (a_params.type != '')
        {
            a_params.xslt_processor = Alph.Util.getXsltProcessor('alpheios','alph-infl-single-grouping.xsl');
            if (a_params.type == 'pers')
            {
                a_params.xslt_params.group4 = 'pers';
            }
            else
            {
                a_params.xslt_params.group4 = 'gend';
            }
        }
        else
        {
            // if we don't have a specific mapping for this type of pronoun, just
            // present a link to Smyth's Pronouns
            a_params.xml_url = null;
            a_params.xml_obj =
                (new DOMParser()).parseFromString("<infl-data/>","text/xml");
            a_params.xslt_processor = Alph.Util.getXsltProcessor('alpheios','alph-infl-substantive.xsl');
            a_params.xslt_params.link_content="grammar:smyth:s325|See Smyth Sections 325-340 Pronouns"
        }
    }
    else if (a_infl_type.match(/^(noun|adjective|numeral)/))
    {
        var is_simple = a_infl_type.match(/^(.+)_simplified$/)
        if (is_simple != null)
        {
            /*
             * simplified noun/adj table is just the regular table
             * for that part of speech, reorded by gend-decl-type,
             * and deduping duplicate endings (by attributes case, number, gender)
             */
            a_infl_type = is_simple[1];
            a_params.xml_url =
                'chrome://alpheios-greek/content/inflections/alph-infl-' +
                a_infl_type + '-simpl.xml';
            a_params.xslt_processor = Alph.Util.getXsltProcessor('alpheios','alph-infl-single-grouping.xsl');
            a_params.xslt_params.group4 = 'gend';
            a_params.title = 'alph-infl-title-'+a_infl_type;
        }
        else
        {
            a_params.xml_url =
                'chrome://alpheios-greek/content/inflections/alph-infl-' + a_infl_type + '.xml';
            a_params.xslt_processor = Alph.Util.getXsltProcessor('alpheios','alph-infl-substantive.xsl');

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
        if (a_infl_type == 'numeral')
        {
            a_params.xslt_params.group4 = 'hdwd';
            a_params.xslt_params.match_form = true;
        }
    }
    else if (a_infl_type == 'adverb')
    {
        a_params.xml_url = null;
        a_params.xml_obj =
            (new DOMParser()).parseFromString("<infl-data/>","text/xml");
        a_params.xslt_processor = Alph.Util.getXsltProcessor('alpheios','alph-infl-substantive.xsl');
        a_params.xslt_params.link_content="grammar:smyth:s341|See Smyth Sections 341-346 Adverbs"

    }
    if (typeof a_params.xslt_params.match_pofs  == 'undefined')
    {
        a_params.xslt_params.match_pofs = a_infl_type;
    }
}

/**
 * Greek specific inflection table display code
 * @param {Element} a_tbl the inflection table element
 * @param {Elemen} a_str the strings for the table display
 * @param {Object} a_params the inflection window parameters
 */
Alph.LanguageTool_Greek.prototype.handleInflectionDisplay = function(a_tbl,a_str,a_params)
{
    // collapse all non-primary endings
    // TODO - this may only be temporary - experimenting with different approaches
    //window.opener.Alph.BrowserUtils.log("Handling inflection display");
    var ret_cells = [];
    var show_stem_classes = [];
    Alph.$("td.ending-group",a_tbl).each(
        function(c_i)
        {
            var tdIndex = Alph.$(this).get(0).realIndex;
            var collapsed = false;

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
                                collapsed = true;
                            }
                        }
                        else if (last_col_index != null &&
                                 (Alph.$(this).hasClass("footnote") || Alph.$(this).hasClass("footnote-delimiter")))
                        {
                                Alph.$(this).addClass("ending-collapsed");
                                Alph.$(this).attr("ending-index",last_col_index);
                                collapsed = true;

                        }
                        else
                        {
                            // do nothing
                        }
                    }
                );




            }
            // push the index of this table cell onto the return arry if
            // if it has been flagged as containg any collapsed endings
            if (collapsed)
            {
                ret_cells.push(tdIndex);
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

    if (a_params.showpofs.indexOf('_simplified')!= -1)
    {
        // in the simplified view of the table,
        // hide the declension headerrow and flag the
        // table as simplified to enable
        // other modifications via the css
        Alph.$('#headerrow2',a_tbl).css('display','none');
        Alph.$(a_tbl).addClass("simplified");
    }

    return ret_cells;

}

/**
 * Greek-specific implementation of {@link Alph.LanguageTool#postTransform}.
 * Looks up the lemma in the file of LSJ short meanings
 */
Alph.LanguageTool_Greek.prototype.postTransform = function(a_node)
{
    var lang_obj = this;
    var defs = this.d_defsFile;
    var lex = this.d_shortLexCode;
    var stripper = this.d_stripper;
    Alph.$(".alph-entry", a_node).each(
        function()
        {
            // get lemma
            var lemmaKey = Alph.$(".alph-dict", this).attr("lemma-key");
            var defReturn = Array(null, null);
            var i;

            // for each lexicon
            for (i = 0; i < lex.length; ++i)
            {
                // get data from defs file
                var defReturn =
                    Alph.LanguageTool_Greek.lookupLemma(lemmaKey,
                                                           null,
                                                           defs[i],
                                                           stripper);
                if (defReturn[1])
                    break;
            }

            // if we found definition
            if (defReturn[1])
            {
                // if extra info occurs in meaning, flag it with <span>
                defReturn[1] =
                    defReturn[1].replace(
                        '(also possessive pronoun)',
                        '<span class="alph-mean-extra">' +
                          '(also possessive ' +
                          '<span class="alph-nopad alph-pofs-extra" ' +
                            'context="pronoun">' +
                            'pronoun' +
                          '</span>)' +
                        '</span>');

                // build meaning element
                var meanElt = '<div class="alph-mean">' +
                                defReturn[1] +
                              '</div>';

                // insert meaning into document
                Alph.BrowserUtils.log("adding " + meanElt);
                Alph.$(".alph-dict", this).after(meanElt);
                
                // build dictionary source element
                var srcElt = '<div class="alph-dict-source">' +
                    lang_obj.getString('dict.' + lex[i] + '.copyright') +
                    '</div>';
                Alph.$(".alph-dict", this).append(srcElt);

                // set lemma attributes
                Alph.BrowserUtils.log('adding @lemma-lang="grc"');
                Alph.BrowserUtils.log('adding @lemma-key="' + defReturn[0] + '"');
                Alph.BrowserUtils.log('adding @lemma-lex="' + lex[i] + '"');
                Alph.$(".alph-dict", this).attr("lemma-lang", "grc");
                Alph.$(".alph-dict", this).attr("lemma-key", defReturn[0]);
                Alph.$(".alph-dict", this).attr("lemma-lex", lex[i]);
            }
            else
            {
                Alph.BrowserUtils.log("meaning for " +
                              lemmaKey +
                              " not found [" + lex.join() + "]");
            }
        }
    );
    var copyright = this.getString('popup.credits');
    Alph.$('#alph-morph-credits',a_node).html(copyright);
    
}

/**
 * Removes the previous/next block from the Harvard LSJ output
 */
Alph.LanguageTool_Greek.prototype.fixHarvardLSJ = function(a_html)
{
    // look for the first <hr/> and remove everything before it
    var match_hr = a_html.match(/(<hr\s*\/>)/m);
    if (match_hr)
    {
        a_html = a_html.substring(match_hr.index+match_hr[1].length);
    }
    return a_html;
}

/**
 * Greek-specific implementation of {@link Alph.LanguageTool#observePrefChange}.
 *
 * calls loadShortDefs and loadLexIds if the dictionary list changed
 * @param {String} a_name the name of the preference which changed
 * @param {Object} a_value the new value of the preference
 */
Alph.LanguageTool_Greek.prototype.observePrefChange = function(a_name,a_value)
{
    if (a_name.indexOf('dictionaries.short') != -1)
        this.loadShortDefs();

    if (a_name.indexOf('dictionaries.full') != -1)
    {
        this.loadLexIds();
        this.lexiconSetup();
    }
}

/**
 * Greek-specific implementation of {@link Alph.LanguageTool#getLemmaId}.
 *
 * @param {String} a_lemmaKey the lemma key
 * @return {Array} (lemma id, lexicon code) or (null, null) if not found
 * @type Array
 */
Alph.LanguageTool_Greek.prototype.getLemmaId = function(a_lemmaKey)
{
    // for each lexicon
    for (var i = 0; i < this.d_fullLexCode.length; ++i)
    {
        // get data from ids file
        var lemma_id =
            Alph.LanguageTool_Greek.lookupLemma(a_lemmaKey,
                                                   a_lemmaKey,
                                                   this.d_idsFile[i],
                                                   this.d_stripper)[1];
        if (lemma_id)
            return Array(lemma_id, this.d_fullLexCode[i]);
    }

    Alph.BrowserUtils.log("id for " +
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
 * @return {Array} (key, data)
 * @type String
 */
Alph.LanguageTool_Greek.lookupLemma =
function(a_lemma, a_key, a_datafile, a_stripper)
{
    if (!a_datafile)
        return Array(null, null);

    var key;
    var x = null;
    if (!a_key)
    {
        // if no key given, strip vowel length diacritics and capitalization
        a_stripper.setParameter(null, "input", a_lemma);
        a_stripper.setParameter(null, "strip-vowels", true);
        a_stripper.setParameter(null, "strip-caps", true);
        x = (new DOMParser()).parseFromString("<dummy/>", "text/xml");
        key = a_stripper.transformToDocument(x).documentElement.textContent;
    }
    else
    {
        // use supplied key
        key = a_key;
    }

    // count trailing digits
    var toRemove = 0;
    for (; toRemove <= key.length; ++toRemove)
    {
        // if not a digit, done
        var c = key.substr(key.length - (toRemove + 1), 1);
        if ((c < "0") || ("9" < c))
            break;
    }

    // try to find data
    var data = a_datafile.findData(key);
    if (!data && (toRemove > 0))
    {
        // if not found, remove trailing digits and retry
        key = key.substr(0, key.length - toRemove);
        data = a_datafile.findData(key);
    }

    // if data found
    if (data)
    {
        var sep = a_datafile.getSeparator();
        var specialFlag = a_datafile.getSpecialHandlingFlag();

        // find start and end of definition
        var startText = data.indexOf(sep, 0) + 1;
        var endText = data.indexOf('\n', startText);
        if (data.charAt(endText - 1) == '\r')
            endText--;

        // if special case
        if (((endText - startText) == 1) &&
            (data.charAt(startText) == specialFlag))
        {
            // retry using flag plus lemma without caps removed
            a_stripper.setParameter(null, "input", a_lemma);
            a_stripper.setParameter(null, "strip-vowels", true);
            a_stripper.setParameter(null, "strip-caps", false);
            if (!x)
                x = (new DOMParser()).parseFromString("<dummy/>", "text/xml");
            key = specialFlag +
                   a_stripper.transformToDocument(x).
                            documentElement.
                            textContent;
            data = a_datafile.findData(key);
            if (!data)
            {
                // if not found, remove trailing digits and retry
                key = key.substr(0, key.length - toRemove);
                data = a_datafile.findData(key);
            }

            if (data)
            {
                startText = data.indexOf(sep, 0) + 1;
                endText = data.indexOf('\n', startText);
                if (data.charAt(endText - 1) == '\r')
                    endText--;
            }
        }

        // real data found
        if (data)
            return Array(key, data.substr(startText, endText - startText));
    }

    // nothing found
    return Array(key, null);
}

  /**
     * greek ascii transliteration (unicode to betacode)
     * @param {String} a_str the string to convert
     * @return the converted string
     * @type {String}
     */
Alph.Convert.bind('greekToAscii',
    function(a_str)
    {
        /* initialize the XSLT converter if we haven't done so already */
        if (this.u2bConverter == null)
        {
            this.d_u2bConverter = Alph.Util.getXsltProcessor('alpheios','alpheios-uni2betacode.xsl');
        }
        var betaText = '';
        try
        {
            this.d_u2bConverter.setParameter(null, "input", a_str);
            var dummy = (new DOMParser()).parseFromString("<root/>","text/xml");
            betaText = this.d_u2bConverter.transformToDocument(dummy).documentElement.textContent;
        }
        catch (e)
        {
            Alph.BrowserUtils.log(e);
        }
        return betaText;
    }
);

/**
 * greek normalization (precomposed/decomposed Unicode)
 * @param {String} a_str the string to normalize
 * @param {Boolean} a_precomposed whether to output precomposed Unicode
 *   (default = true)
 * @param {String} a_strip characters/attributes to remove
 *   (specified as betacode characters - e.g. "/\\=" to remove accents)
 *   (default = no stripping)
 * @param {Boolean} a_partial whether this is partial word
 *   (if true, ending sigma is treated as medial not final)
 *   (default = false)
 * @return the normalized string
 * @type {String}
 */
Alph.Convert.bind('normalizeGreek',
    function(a_str, a_precomposed, a_strip, a_partial)
    {
        /* initialize the XSLT converter if we haven't done so already */
        if (this.d_uNormalizer == null)
        {
            this.d_uNormalizer = Alph.Util.getXsltProcessor('alpheios','alpheios-normalize-greek.xsl');
        }

        // set defaults for missing params
        if (typeof a_precomposed == "undefined")
            a_precomposed = true;
        if (typeof a_strip == "undefined")
            a_strip = "";
        if (typeof a_partial == "undefined")
            a_partial = false;

        var normText = '';
        try
        {
            this.d_uNormalizer.setParameter(null, "input", a_str);
            this.d_uNormalizer.setParameter(null, "precomposed", (a_precomposed ? 1 : 0));
            this.d_uNormalizer.setParameter(null, "strip", a_strip);
            this.d_uNormalizer.setParameter(null, "partial", (a_partial ? 1 : 0));
            var dummy = (new DOMParser()).parseFromString("<root/>","text/xml");
            normText = this.d_uNormalizer.transformToDocument(dummy).documentElement.textContent;
        }
        catch (e)
        {
            Alph.BrowserUtils.log(e);
        }
        return normText;
    }
);