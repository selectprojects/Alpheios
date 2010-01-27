/**
 * @fileoverview Javascript functionality for Alpheios text pages
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
 * Supported Firefox versions
 */
var FIREFOX_VERSION_TEST = 'Firefox/3.';
var FIREFOX_VERSION_STRING = 'Firefox 3.x';

var ALPHEIOS_INSTALL_URL = 'http://alpheios.net/content/installation';

/**
 * Supported Alpheios extensions
 */
var ALPHEIOS_EXT_REQS = 
{
	'basic':  {  id: '{4816253c-3208-49d8-9557-0745a5508299}',
	             name: 'Alpheios Basic Libraries',
		     url: 'http://alpheios.net/xpi-install/alpheios-basic-latest.xpi',
		     min_version: '1.0alpha5'
	          },
	'grc':    { id: '{0f1d7e06-6ce8-40b0-83f0-9783ee65ab9b}',
	            name: 'Alpheios Greek Tools',
	            url: 'http://alpheios.net/xpi-install/alpheios-greek-latest.xpi',
		    min_version: '1.0alpha1'
		  },
	'la':     { id: '{7dd2b42f-3db8-4833-88c4-5a9e3788017b}',
		    name: 'Alpheios Latin Tools',
		    url: 'http://alpheios.net/xpi-install/alpheios-latin-latest.xpi',
		    min_version: '1.0alpha1'
		  }
};

/**
 * Check for the presence of the Alpheios extensions required by the page
 * Note that this must be called upon load of the body tag, and not
 * from the jQuery document ready function because document ready is called
 * before the extension has time to insert the required metadata elements.
 * @param {Boolean} a_on_site flag to indicate whether or not we're on 
 *                          an alpheios-enabled site (in which case,
 *                          list the required extensions, with a single
 *                          link to the installation/download site)
 */
function check_for_alpheios(a_on_site)
{
    if (typeof a_on_site == "undefined")
    {
	a_on_site = true;
    }

    if ($("#alpheios-install-links").length == 0)
    {
	return;
    }
    // Firefox is currently the only supported browser
    if (navigator.userAgent.indexOf("Firefox") == -1 ||
        navigator.userAgent.indexOf(FIREFOX_VERSION_TEST) == -1)
    {
        $("#alpheios-install-links").html(
             '<li><div class="error">' + 
             'The Alpheios tools require ' + FIREFOX_VERSION_STRING + 
             ' plus the Alpheios Firefox extensions.</div></li>');
        disable_alpheios();
        return;
    }
	
    var has_basic = false;

    /*
     * The document can define the required Alpheios language tool
     * in one of the following ways:
     * 1) an element with the class 'alpheios-enabled-text' with the 
     *    attribute named 'lang' or xml:lang attribute set to the
     *    the IANA language codes of the required language 
     *    (or space-separated list of required languages)
     * 2) in the <html> element of the document, set the xml:lang or
     *    lang attribute to the required language (or space-separated
     *    list of required languages)
     */
    var needs_language = 
        $(".alpheios-enabled-text").attr("lang") ||
        $(".alpheios-enabled-text").attr("xml:lang") ||
	document.documentElement.getAttribute("xml:lang") ||
        document.documentElement.getAttribute("lang");
    
    var required_languages = [];
    needs_language.split(/\s+/).forEach(
	function(a_lang)
	{
	    required_languages.push(
                 [a_lang,false]);
	}
    );

    // iterate through the metadata elements added to the page
    // by the Alpheios Basic Libraries extension (if any) to see if the 
    // required ones are installed
    $("meta[name=_alpheios-installed-version]").each(
	function()
	{
	    var info = $(this).attr("content").split(/:/);
	    var id = info[0];
	    var version = info[1];
	    // check for the Basic Libraries extension
	    if (id == ALPHEIOS_EXT_REQS.basic.id && 
                check_version(ALPHEIOS_EXT_REQS.basic.min_version,version)
               )
	    {
		has_basic = true;
	    }
	    else
            {
		// check for the language extension for the required language(s)
                for (var i=0; i< required_languages.length; i++)
                {
                    var a_lang = required_languages[i];
		    if ( ALPHEIOS_EXT_REQS[a_lang[0]] &&
			 id == ALPHEIOS_EXT_REQS[a_lang[0]].id)
                    { 
			if (check_version(
			    ALPHEIOS_EXT_REQS[a_lang[0]].min_version,
			    version))
                        {
			    a_lang[1] = true;
                        }
                        else
                        {
			    a_lang[1] = false;
                        }
                        break;
                   }
		}
	    }

	}
    );
    // if we're missing any of the required extensions, add install links
    // to the placeholder element with the id=alpheios-install-links 
    // and hide the Alpheios toolbar
    if (! has_basic)
    { 
	$("#alpheios-install-links").append(
		'<li>' +
		get_install_link('basic',a_on_site) +
		'</li>'
	);
    }
    var install_lang = false;
    for (var i=0; i<required_languages.length; i++)
    {
	var a_lang = required_languages[i];
	if(! a_lang[1])
        {
	    $("#alpheios-install-links").append(
	      '<li>' +
	        get_install_link(a_lang[0],a_on_site) +
	      '</li>');
            install_lang = true;
	}
    }
    if (!(has_basic) || install_lang)
    {
         disable_alpheios();
    }

}

function disable_alpheios()
{
     // show the install links and hide the toolbar
     $("#alpheios-install-links").css("display","block");
     $("#alph-toolbar").css("display","none");
     $("#alpheios-current-level").css("display","none");
}

/**
 * Compare installed extension version with required extension version
 * @param a_req_v the required version
 * @param a_has_v the installed version
 * @return true if installed version meets requirement otherwise false
 * @param Boolean
 */
function check_version(a_req_v,a_has_v) 
{
    /** 
     * this code implements only part of the logic
     * specified for the Mozilla Toolkit version format
     * see https://developer.mozilla.org/en/Toolkit_version_format
     * The 4 parts of the Alpheios version string are:
     * <major version>.<minor version>.<svn revision>.<build date>
     * The following code compares up to the first three parts only
     * and if a string part is missing, it assumes that we won't
     * use any string part which evaluates higher than 'zzzzzzzzzzzzzzz'
     */
    var req_parts = String(a_req_v).split(/\./);
    var has_parts = String(a_has_v).split(/\./);
    if (has_parts.length == 0)
    {
        return false;
    }

    var met_requirement = true;
    var met_part = 0;
    PARTS:
    for (var i=0; i<=req_parts.length; i++)
    {
         if (met_part > 0)
         { 
             break;
         }
         if (met_part < 0)
         {
             met_requirement = false;
             break;
         }
       
         if (i == req_parts.length)
         {
             break;
         } 
         if (req_parts[i] == '*')
         {
             continue;
         }
         var req_part_match = req_parts[i].match(/^(\d+)(\w+)?(\d+)?$/);
         var has_part_match = has_parts[i].match(/^(\d+)(\w+)?(\d+)?$/);
         VERSION_PART:
         for (var j=1; j<4; j++)
         {

             met_part = 0;
             var missing_part = j == 2 ? 'zzzzzzzzzzzzzzzz' : '0'; 
             if (!req_part_match[j]) req_part_match[j]=missing_part;
             if (!has_part_match[j]) has_part_match[j]=missing_part;

             // first and third parts are numbers
             if (j==1 || j==3)
             {  
                 req_part_match[j] = parseInt(req_part_match[j]);
                 has_part_match[j] = parseInt(has_part_match[j]);
             
             }
             if (has_part_match[j] > req_part_match[j])
             {
                 met_part = 1;
                 break VERSION_PART;
             }
             else if (has_part_match[j] < req_part_match[j])
             {
                 met_part = -1;
                 break VERSION_PART;
             }
             // parts were equal so go on to next part
         }
         
    }
    return met_requirement;
    
}

/**
 * Construct a link to install the requested extension
 * @param {String} a_tool extension identifier
 * @param {Boolean} a_on_site flag to indicate whether or not we're on 
 *                          an alpheios-enabled site (in which case,
 *                          list the required extensions, with a single
 *                          link to the installation/download site)
 * @return an HTML <a> element
 * @type {HTMLElement}
 */
function get_install_link(a_tool,a_on_site)
{
    var url = ALPHEIOS_EXT_REQS[a_tool].url;
    var name = ALPHEIOS_EXT_REQS[a_tool].name;
    var xpi_name = url.match(/\/([^\/]+\.xpi)/)[1];

    var link = "";
    if (typeof url != "undefined")
    {
	if (! a_on_site)
	{
	    link = "<a href=\"javascript:install_xpi('" + 
		url + 
		"','" + 
		xpi_name + 
		"')\"><span class='alpheios-install-plus'>+</span>" + 
		name + '</a>';
	}
	else
	{
	    link = '<a href="' + 
		ALPHEIOS_INSTALL_URL + 
		'" class="alpheios-site-link">' + 
		name + 
		'</a>';
	}

    }
    return link;
}

/**
 * Function to install the specified xpi file
 * @param {String} a_file xpi file url
 * @param {String} a_release name of the xpi file (for display during install)
 */ 
function install_xpi(a_file,a_release) {
    if (navigator.userAgent.indexOf("Firefox") == -1)
    {
        alert("Firefox is required to install these browser extensions.");
        return;
    }
    var xpi = new Object();
    xpi[a_release] = a_file;
    InstallTrigger.install(xpi,function(){});
}

