/**
 * @fileoverview Greek specific implementation of the interactive query template 
 * functionality
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

/**
 * constant strings - inflection attributes
 */
const IND = 'indicative';
const SUB = 'subjunctive';
const OPT = 'optative';
const IMP = 'imperative';
const PRE = 'present';
const IPF = 'imperfect';
const FUT = 'future';
const AOR = 'aorist';
const PER = 'perfect';
const PLU = 'pluperfect';
const FPF = 'future_perfect';
const AOR2 = '2nd_aorist';
const FUT2 = '2nd_future';
const PER2 = '2nd_perfect';
const PLU2 = '2nd_pluperfect';
const ACT = 'active';
const MID = 'middle';
const PAS = 'passive';
const SIN = 'singular';
const DUA = 'dual';
const PLUR = 'plural';
const FIRST = '1st';
const SECOND = '2nd';
const THIRD = '3rd';
const VOICE = 'voice';
const MOOD = 'mood';
const TENSE = 'tense';
const TENSE2 = 'second_tense';
const PERS = 'pers';
const NUM = 'num';
const DECL = 'decl';
const CASE = 'case';
const GEND = 'gend';
const ACC = 'accusative';
const NOM = 'nominative';
const DAT = 'dative';
const VOC = 'vocative';
const GEN = 'genitive';
const MAS = 'masculine';
const FEM = 'feminine';
const NEU = 'neuter';
const COM = 'common';
const MF = 'masculine_feminine'
const MFN = 'masculine_feminine_neuter'
/*
 * temporary string object for table headers - to be moved to a properties file
 */
var str = {};
str[NUM] = 'Number';
str[VOICE] = 'Voice';
str[TENSE] = 'Tense';
str[MOOD] = 'Mood';
str[PERS] = 'Person';
str[GEND] = 'Gender';
str[CASE] = 'Case';
str[DECL] = 'Declension';
str[FEM] = 'F';
str[MAS] = 'M';
str[NEU] = 'N';
str[MF] = 'M/F';
str[MFN] = 'M/F/N';
str[SIN] = 'Singular';
str[DUA] = 'Dual';
str[PLUR] = 'Plural';
str[IND] = 'Indicative';
str[SUB] = 'Subjunctive';
str[OPT] = 'Optative';
str[IMP] = 'Imperative';
str[PRE] = 'Present';
str[IPF] = 'Imperfect';
str[FUT] = 'Future';
str[AOR] = 'Aorist';
str[PER] = 'Perfect';
str[PLU] = 'Pluperfect';
str[FPF] = 'Future Perfect';
str[AOR2] = '2nd Aorist';
str[FUT2] = '2nd Future';
str[PER2] = '2nd Perfect';
str[PLU2] = '2nd Pluperfect';
str[ACT] = 'Active';
str[MID] = 'Middle';
str[PAS] = 'Passive';

/**
 * @singleton 
 */
var TEMPLATE =
{
    /**
     * verb query template
     */
    verb:
          { data_file: "chrome://alpheios-greek/content/inflections/alph-query-verb.xml",
            xslt_file: "chrome://alpheios/skin/alph-infl-verbform.xsl",
            load_data_on_start: false,
            invalidate_empty_cells: true,
            /* table columns */
            cols: 
            [
                [VOICE,[ACT,MID,PAS],{
                    group1: MOOD,
                    group4: TENSE }],
                [TENSE,[PRE,IPF,FUT,AOR,PER,PLU,FPF],{
                    group1: MOOD,
                    group4: VOICE }],
                [TENSE2,function(args){ return []}],
                [MOOD,[IND,SUB,OPT,IMP],{
                    group1: TENSE,
                    group4: VOICE } ],
                [NUM,[SIN,DUA,PLUR]],
                [PERS,[FIRST,SECOND,THIRD]]
            ],
            /* filters defining invalid combinations of attributes */
            filters: [
                { mood: SUB,
                  tense: IPF  
                },
                { mood: SUB,
                  tense: FUT  
                },  
                { mood: SUB,
                  tense: PLU  
                },
                { mood: SUB,
                  tense: FPF  
                },
                { mood: OPT,
                  tense: IPF  
                },
                { mood: OPT,
                  tense: PLU  
                },
                { mood: IMP,
                  tense: IPF  
                },
                { mood: IMP,
                  tense: FUT  
                },  
                { mood: IMP,
                  tense: PLU  
                },
                { mood: IMP,
                  tense: FPF  
                },
                { num: DUA,
                  pers: FIRST
                },
                { voice: ACT,
                  tense: FPF
                },
                { voice: MID,
                  tense: FPF
                },
                { mood: IMP,
                  pers: FIRST
                }                   
            ],
            /* temporary - additional noun definitions for testing */
            test_defs: ['tell', 'seek', 'plan']
    },
    /**
     * noun query template
     */
    noun:
          { data_file: "chrome://alpheios-greek/content/inflections/alph-infl-noun.xml",
            xslt_file: "chrome://alpheios/skin/alph-infl-substantive-query.xsl",
            xslt_params: this.get_noun_params,
            load_data_on_start: true,
            invalidate_empty_cells: false,

            /* table columns */
            cols: 
            [
                [CASE,[NOM,ACC,DAT,GEN,VOC]],
                [NUM,[SIN,DUA,PLUR]],
                [GEND,[MAS,FEM,NEU]]
            ],
            filters: [
            ],
            /* temporary - additional noun definitions for testing */
            test_defs: ['life', 'a man', 'end']
          },
     /**
     * noun query template
     */
    adjective:
          { data_file: "chrome://alpheios-greek/content/inflections/alph-infl-adjective.xml",
            xslt_file: "chrome://alpheios/skin/alph-infl-substantive-query.xsl",
            xslt_params: this.get_noun_params,
            load_data_on_start: true,
            invalidate_empty_cells: false,

            /* table columns */
            cols: 
            [
                [CASE,[NOM,ACC,DAT,GEN,VOC]],
                [NUM,[SIN,DUA,PLUR]],
                [GEND,[MAS,FEM,NEU]]
            ],
            filters: [
            ],
            /* temporary - additional noun definitions for testing */
            test_defs: ['life', 'a man', 'end']
          },
    /**
     * article query template
     */
    article:
          { data_file: "chrome://alpheios-greek/content/inflections/alph-query-article.xml",
            xslt_file: "chrome://alpheios/skin/alph-infl-substantive-query.xsl",
            load_data_on_start: true,
            invalidate_empty_cells: false,

            /* table columns */
            cols: 
            [
                [CASE,[NOM,ACC,DAT,GEN,VOC]],
                [NUM,[SIN,DUA,PLUR]],
                [GEND,[MAS,FEM,NEU]]
            ],
            filters: [
            ],
            /* temporary - additional definitions for testing */
            test_defs: ['who','he','a']
          }

};


/**
 * make the inflection query element
 * @param {Element} a_elem the DOM node to which the query element is appended
 * @param {String} a_pofs the part of speech for the query
 * @param {Element} a_ans the object containing the correct inflection data
 * @param {Function} a_callback callback function to be called when the correct
 *                              answer is found   
 */
function make_infl_query(a_elem,a_pofs,a_ans,a_callback)
{
    var template = TEMPLATE[a_pofs];
    var html = '<div class="query-table">\n<div class="query-cols">\n';    

    // col headers
    template.cols.forEach(
        function(a_col,a_i)
        {
            var attname = a_col[0];
            var att_list;
            if (typeof a_col[1] == 'function')
            {
                att_list = a_col[1]();
            }
            else 
            {
                att_list = a_col[1];
            }
            if (att_list.length > 0)
            {
                var div = 
                    '<div class="query-col" context="' + attname + '">\n' +
                    '<div class="query-col-header">' + str[attname] + '</div>\n';
                att_list.forEach(
                    function(a_att)
                    {
                        div = div +
                            '<div class="choice" context="' + a_att + '">' +
                            '<input type="radio" name="' + attname + 
                            '"  value="' + a_att + '"/>' + 
                            '<span class="attribute">' + a_att.replace(/_/,' ') + '</span></div>\n'; 
                    }
                );
                div = div + '</div>\n';
                html = html + div;
            }
        }
    );
    
    html = html + "</div>";
   
    var buttons = '<div class="buttons"><button id="reset">reset</button></div>';
    html = html + '<div class="query-decl"/>' + buttons + '</div>';
    $(a_elem).append(html);
    
    var bind_data = 
    {
        answer:a_ans,
        base_elem: a_elem,
        template: template,
        callback:a_callback
    };
    
    $(".choice input",a_elem).bind('click',bind_data,check_answer);
   
    $("#reset",a_elem).bind('click',bind_data,reset_table);
         
    if (template.load_data_on_start)
    {
        var xslt_params = template.xslt_params(a_ans);
        activate_table(a_elem,a_ans,template,a_callback,xslt_params);
    }
}

/**
 * reset the inflection query table clearing any answers found so far
 * @param {Event} a_event the reset button click event 
 */
function reset_table(a_event)
{
    $("#alph-infl-table .showform",a_event.data.base_elem).removeClass("showform");
    $("#alph-infl-table .correct",a_event.data.base_elem).removeClass("correct");
    $("#alph-infl-table .incorrect",a_event.data.base_elem).removeClass("incorrect");
    $("#alph-infl-table .matchingform",a_event.data.base_elem).removeClass("matchingform");
    $("#alph-infl-table .invalid",a_event.data.base_elem).removeClass("invalid");
    $(".query-col .correct",a_event.data.base_elem).removeClass("correct");
    $(".query-col .incorrect",a_event.data.base_elem).removeClass("incorrect");
    
    $(".query-col input",a_event.data.base_elem).each(
        function()
        {
            $(this).attr("checked",false);
        }
    );  
}

/**
 * add the inflection table element
 * @param {Element} a_elem the DOM node to which the query table is appended
 * @param {Element} a_ans the object containing the correct inflection details
 * @param {Object} a_tepmlate the table template data
 * @param {Function} a_callback callback executed upon correct answer selected
 * @param {Object} a_xslt_param optional xslt parameters 
 */
function activate_table(a_elem,a_ans,a_template,a_callback,a_xslt_param)
{
    var decl_table = load_forms(a_template.data_file, a_template.xslt_file, a_xslt_param);
    var table_elem = decl_table.getElementById("alph-infl-table") 
    $(a_elem).get(0).ownerDocument.importNode(table_elem,true);
    $(table_elem).tableHover({colClass: "",
                              rowClass: "",
                              headCols: true,
                              allowHead: false});
    this.hide_empty_cols(table_elem);
    

    $("th",table_elem).each(
        function()
        {
            replace_string(this);        
        }
    );
    
    $("th span",table_elem).each(
        function()
        {
            replace_string(this);        
        }
    );
    
    $("td.ending-group",table_elem)
        .hover(toggle_cell_hover,toggle_cell_hover)
        .bind('click',{ answer: a_ans,
                        template: a_template,
                        callback: a_callback}, show_table_form);


    if (a_template.invalidate_empty_cells)
    {
        // invalidate any empty cells
        $("td.ending-group",table_elem).each(
            function()
            {
                if ($(".ending",this).length == 0)
                {
                    $(this).addClass("invalid");
                }
            }
        );
    }
    
    var num_cols = $("col",table_elem).length;
    var width = ((1/num_cols)*100).toFixed(0);
    $("td",table_elem).css("width",width+'%');
    $("th",table_elem).css("width",width+'%');
    
    $("#alph-infl-table",a_elem).remove();
    
    $(".query-decl",a_elem).append(decl_table.getElementById("alph-infl-table"));
    
    // iterate through the incorrect choices so far, updating the table to gray out the
    // incorrect selections
    $(".query-col .choice.incorrect",a_elem).each(
        function()
        {
            mark_cell_incorrect(this,table_elem.ownerDocument);
        }
    );
    
}

function mark_cell_incorrect(a_choice,a_doc)
{
    var regex = $("input",a_choice).attr('name') + ':' + $("input",a_choice).attr("value");
    $("#alph-infl-table td.ending-group .ending[context*=" + regex + "]",a_doc)
        .parent("td").addClass("incorrect");

}
/**
 * Checks user input
 * @param {Event} a_event the user input event
 */
function check_answer(a_event)
{
    
    var filters = a_event.data.template.filters;
    
    var parent_doc = this.ownerDocument;
    var parent_tbl = $(this).parents('div.query-table').get(0);
    var all_cols = $('.query-col',parent_tbl);
    var num_cols = $(all_cols).length;
    var parent_col = $(this).parents('div.query-col').get(0);
    var selected_name = this.getAttribute('name');
    var selected_val = this.getAttribute('value');
    var table_regex = selected_name + ':' + selected_val;
    selected_val = selected_val.replace(/_/,' ');
    if (selected_val == a_event.data.answer.attributes['alph-'+ selected_name])
    {
        // if the table isn't already activated check to
        // see if we should now show it
        if ( $("#alph-infl-table",parent_doc).length == 0)
        {
            a_event.data.template.cols.forEach(
                function(a_tcol)
                {
                    // if this is a filtering attribute,
                    // activate the table
                    if (a_tcol[0] == selected_name &&
                        typeof a_tcol[2] == 'object')
                    {
                        activate_table(
                            a_event.data.base_elem,
                            a_event.data.answer,
                            a_event.data.template,
                            a_event.data.callback,
                            $.extend(
                                { filter_by: selected_name + '=' + selected_val
                                  
                                },a_tcol[2])
                         );
                    }
                }
            );
        }
        
        $(this).parent('.choice').addClass("correct").siblings(".choice").each(
            function()
            {
                $(this).addClass("incorrect");
                mark_cell_incorrect(this,parent_doc);
            }
        );
        
        $(this).unbind('click',check_answer);
        
        $(parent_col).siblings('.query-col').each(
            function()
            {
                var col = this;
                var other_att = $(this).attr('context');
        
                // iterate through the filters, and if we find one which 
                // has a matching pair of attributes, invalidate the cell
                for (var i=0; i<filters.length; i++)
                {
                    if (
                        filters[i][other_att] &&
                        filters[i][selected_name] && 
                        filters[i][selected_name]==selected_val
                        )
                    {
                       $(".choice input[value='" + filters[i][other_att] + "']",col)
                                    .parent('.choice').addClass("invalid");
                    }
                }
            }
            

            
        );
    }
    else
    {
        $(this).parent('.choice').addClass("incorrect");
        
        $("#alph-infl-table td.ending-group .ending[context*=" + table_regex + "]",
            parent_doc).parent("td").addClass("incorrect");
        
    }
    $(all_cols).each(
            function()
            {
                var auto_correct = $(".choice:not('.invalid'):not('.incorrect')",this);
                
                // if there's only one possible choice left for a column,
                // auto-select it
                if ($(auto_correct).length == 1)
                {
                    var selected = auto_select_answer(this,a_event.data);                    
                }
            }
    );
    var num_correct = $(".choice.correct",parent_tbl).length;
    // if we have only one column remaining, we can show 
    // on the next select
    if ((num_cols - num_correct) == 1)
    {
        $(".choice input",parent_tbl).one('click',a_event.data,show_form);
        
    }
    // if all the answers are found, show all the forms in the table
    if (num_cols ==  num_correct)
    {
        show_all_forms(parent_doc,a_event);
    }
}

/**
 * Show a form identified by user input
 * @param {Event} a_event the user input event
 */
function show_form(event)
{
    var a_elem = this;
    var parent_col = $(a_elem).parents('div.query-col').get(0);
    var selected_att= $(parent_col).attr('context');
    
    var parent_doc = a_elem.ownerDocument;
    
    var a_ans = event.data.answer.attributes;
    var att_names = [];
    $(parent_col).siblings(".query-col").each(
        function()
        {
            
            att_names.push($(this).attr('context'));
        }
    );
    var xpath = '[context *=' + selected_att + ":" + $(a_elem).attr('value') + "]";
    att_names.forEach(
        function(a_att)
        {
            var value = a_ans['alph-' + a_att];
            value = value.replace(/\_/, " ");
            xpath = 
                xpath + 
                "[context *= " + a_att + ":" + 
                 value
                + "]"; 
        }
    );
    var cell = $("#alph-infl-table td.ending-group .ending"+xpath,parent_doc).get(0);
    show_table_form({data:event.data},cell);        
}

/**
 * load the inflection form data
 * @param {String} a_file the url to the xml file containing the data
 * @param {String} a_xslt the url to the xslt to use to transform the data
 * @param {Object} a_xslt_param optional xslt transform parameters
 */
function load_forms(a_file,a_xslt,a_xslt_param)
{
        var formXML = document.implementation.createDocument("", "", null);
        formXML.async = false;
        formXML.load(a_file);
        
        var xsltDoc = document.implementation.createDocument("", "", null);
        xsltDoc.async = false;
        xsltDoc.load(a_xslt);

        var xsltProcessor = new XSLTProcessor();
        xsltProcessor.importStylesheet(xsltDoc);
        
        if (typeof a_xslt_param != "undefined")
        {
            for (var param in a_xslt_param)
            {
                xsltProcessor.setParameter("",param,a_xslt_param[param]);
            }
        }
        var formHTML = '';
        try
        {
            // add the xslt parameters
            formHTML = xsltProcessor.transformToDocument(formXML);
        }
        catch(a_e)
        {
            alert(a_e);
        }
        return formHTML;
}

/**
 * replace a string from properties
 * @param {Element} a_elem the DOM node containing the text to be replaced
 * @param {Object} a_props the properties file with the string to be displayed
 * TODO - make this really use a properties file rather than the temporary 
 * hardcoded STR object
 */
function replace_string(a_elem,a_props)
{
    var text = jQuery.trim($(a_elem).text());
    text = text.replace(/ /,'_');
    try 
    {
        //var newtext = a_props.getString(text);
        var newtext = str[text];
        if (newtext)
        {
            $(a_elem).text(newtext);        
        }
        
    } 
    catch(e)
    {
        alert(e)   
    }  
}

/**
 * Show all the forms in the inflection table
 * @param {Document} a_doc the parent document
 * @param {Event} a_event the event which initated the action
 */
function show_all_forms(a_doc,a_event)
{
    $("#alph-infl-table .ending",a_doc).each(
        function()
        {
            show_table_form(a_event,this);    
        }
    );
}

/**
 * Show a specific form in the inflection table - may be in response
 * to a user click on the cell, or selection of the correct answer
 * by process of elimination
 * @param {Event} a_event the event which initiated the action
 * @param {Element} a_cell the DOM node containing the form 
 */
function show_table_form(a_event,a_cell)
{
    // if a_cell is null, then called from an event handler
    if (a_cell == null) {
        a_cell = $(".ending",this).get(0);
    }
    
    var atts = $(a_cell).attr("context").split(/-/);
    var match = true;
    
    atts.forEach(
        function(a_att)
        {
            if (a_att)
            {
                var pair = a_att.split(/:/);
                var ans_key = 'alph-' + pair[0];
                // only check attributes which are actually defined in the answer
                if (typeof a_event.data.answer.attributes[ans_key] != "undefined")
                {
                    if (pair[1].indexOf(a_event.data.answer.attributes[ans_key]) == -1)
                    {
                        match = false;
                    }
                }
            }
        }   
    );
    
    $(a_cell).addClass("showform");
    // if it's a match, indicate that it's correct, and show the rest of the forms
    if (match)
    {
        $(a_cell).parent('td').addClass("correct");
        // add the ending to the correct cell if it's not already there
        var found_form = false
        $(a_cell).siblings('.ending').andSelf().each(
            function()
            {
                if ($(this).text() == a_event.data.answer.ending)
                {
                    found_form = true;
                }
            }
        );
        if (! found_form)
        {
            $(a_cell).parent('td').children('.ending').eq(0).addClass('notfirst');
            $(a_cell).parent('td')
                     .prepend('<span class="ending">'+a_event.data.answer.ending + '</span>');
        }        
        var table = $(a_cell).parents('table').get(0);
        
        $(".ending",table).each(
            function()
            {
                $(this).addClass("showform");
                if ($(this).text() == a_event.data.answer.ending)
                {
                    $(this).addClass('matchingform');
                }
            }
        )
        $('td:not(.correct)',table).addClass("incorrect");
        var parent_doc = a_cell.ownerDocument;
        $(".query-col",parent_doc).each(
            function()
            {
                auto_select_answer(this,a_event.data);
            }
        );
        $("#reset",parent_doc).css("display","none");
         
        atts.forEach(
        function(a_att)
        {
            if (a_att)
            {
                var pair = a_att.split(/:/);
                var ans_key = 'alph-' + pair[0];
                // only check attributes which are actually defined in the answer
                if (typeof a_event.data.answer.attributes[ans_key] != "undefined")
                {
                    if (a_event.data.answer.attributes[ans_key] != pair[1])
                    {
                        match = false;
                    }
                }
            }
        }   
    );
        var answer_terms = [];
        for (var prop in a_event.data.answer.attributes)
        {
            if (prop.match(/^alph-/) && a_event.data.answer.attributes[prop] != '' )
            {
                answer_terms.push(a_event.data.answer.attributes[prop]);
            }
        }
        a_event.data.callback(answer_terms.join(', '));
    }
    else
    {
        $(a_cell).parent('td').addClass("incorrect");
        $(a_cell).addClass("showform");
        if ($(a_cell).text() == a_event.data.answer.ending )
        {
            $(this).addClass('matchingform');
        }

    }
    
}

/**
 * toggle the hover class over an inflection table cell
 * @param {Event} a_event the hover event
 */
function toggle_cell_hover(a_event)
{
    $(this).toggleClass("hovered");   
}

/**
 * auto-select an answer (because only one option left due to
 * process of elmination)
 * @param {Element} a_col the DOM element containing the set of data for which the answer
 *                        is to be selected
 * @param {Object} a_data the object containing the correct inflection data  
 */
function auto_select_answer(a_col,a_data)
{
    var col_name = $(a_col).attr('context').replace(/_/," ");
    var answer = a_data.answer.attributes['alph-'+col_name];
    var selector = $("[value='"+answer+"']",a_col);
    if (selector.length == 1)
    {
        $(selector).attr("checked",true);
        $(selector).parent('.choice').addClass('correct');
        $(selector).unbind('click',check_answer);
        $(a_col).siblings('.query-col').each(
            function()
            { 
                var col = this;
                var other_att = $(this).attr('context');
        
                // iterate through the filters, and if we find one which 
                // has a matching pair of attributes, invalidate the cell
                for (var i=0; i<a_data.template.filters.length; i++)
                {
                    if (
                            a_data.template.filters[i][other_att] &&
                            a_data.template.filters[i][col_name] && 
                            a_data.template.filters[i][col_name]==answer
                        )
                    {
                        $(".choice input[value='" + a_data.template.filters[i][other_att] + "']",col)
                        .parent('.choice').addClass("invalid");
                    }
                }
            }
        );
        return $(selector).get(0);
    }
    return null;
}

function get_noun_params(a_ans)
{
    var params = {};
    var declension = a_ans.attributes['alph-decl'];
    if (declension)
    {
        params.decl = declension;
    }
    return params;
}

function hide_empty_cols(a_tbl)
{
    var data_rows = $("tr.data-row",a_tbl).length;
    var empty_cols = [];
    // iterate through the columns, hiding any which are completely empty
    $('col',a_tbl).each (
          function() {
            var index = $(this).attr("realIndex");
            var num_empty = $("td[realIndex='" + index + "'] span.emptycell",a_tbl).length;
            if (num_empty == data_rows) 
            {
                empty_cols.push(index);    
            }
  
          }
    );

    var reduce_cols = {headerrow1: {},
                       headerrow2: {}};
    empty_cols.forEach( 
        function(a_o, a_i)
        {
            $("td[realIndex='" + a_o + "']",a_tbl).css("display","none");
                
            $("tr[id^=headerrow] th",a_tbl).each(
                function()
                {
                    var realIndex = this.realIndex;
                    var colspan;
                    var id = $(this).parent("tr").attr("id");
                    try 
                    {
                        colspan = parseInt($(this).attr("colspan"));
                    }
                    catch(e)
                    {
                    }
                    
                    if (typeof realIndex != "undefined" && 
                        (realIndex == a_o
                          || (a_o > realIndex && a_o < (realIndex + colspan))))
                    {
                        if (typeof reduce_cols[id][realIndex] == "undefined")
                        {
                            reduce_cols[id][realIndex] = 1;
                        }
                        else
                        {
                            reduce_cols[id][realIndex] = reduce_cols[id][realIndex] + 1;    
                        }
                        
                    }
                }
            );
        }
    );
    for (var id in reduce_cols)
    {
        if (id.substring("headerrow") == -1)
        {
            continue;
        }
        for (var colindex in reduce_cols[id])
        {
            if (typeof reduce_cols[id][colindex] == "number")
            {
                var col_header = 
                    $("tr#" + id + " th[realIndex='" + colindex + "']",a_tbl)
                    .get(0);
                var col_span = parseInt(col_header.getAttribute("colspan"));
                if (reduce_cols[id][colindex] == col_span)
                {
                    $(col_header).css("display","none");
                }
                else
                {
                    col_header.setAttribute("colspan",col_span - reduce_cols[id][colindex]);
                    col_header.setAttribute("origColspan",col_span);
                }
            }
        }
    } 
}
