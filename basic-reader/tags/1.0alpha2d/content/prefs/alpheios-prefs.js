/**
 * @fileoverview This file contains the Alph.prefs class which defines
 * the functionality for the Preferences dialog
 * 
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
 
 /**
 * @singleton
 */
Alph.prefs = {

    _selected_dict_item: null,
    _selected_site_item:  null,
    _IO_SVC: Components.classes["@mozilla.org/network/io-service;1"]
                      .getService(Components.interfaces.nsIIOService),
        
    
    init: function()
    {
        this._PREFS = Components.classes["@mozilla.org/preferences-service;1"]
                      .getService(Components.interfaces.nsIPrefService)
                      .getBranch("extensions.alpheios."),
        this._PREFS.QueryInterface(Components.interfaces.nsIPrefBranch2);
    },
   
    /**
     * Initializes the panel preferences on the window preferences pane
     * - copies the main panel preferences grid to the language-specific
     *   panel prefs tabs, if any
     * - adds a click handler to the override defaults checkbox to
     *   toggle the disabled status of the language-specific panel prefs
     */
    init_panel_prefs: function()
    {
        
        var prefs = Alph.$("#alpheios-panel-prefs preferences").get(0);
        
        Alph.$("[id^=panel-prefs-box-]").each(
        
            function() {
                
                var box = this;
                var lang = this.id.match(/panel-prefs-box-(.+)$/)[1];
                
                var use_defs_cbx = Alph.$("#panel-override-"+lang).get(0);
                // if we don't have a control for overriding the panel
                // prefs for this language just continue to the next language
                if (typeof use_defs_cbx != "undefined")
                {                
                
                    // clone the default panel preferences grid
                    // repurpose the cloned copy for this language
                    var grid = Alph.$("grid#alpheios-panel-prefs-default").clone();
                    Alph.$(grid).get(0).setAttribute("id","alpheios-panel-prefs-"+lang);
                    
                    // iterate through the checkboxes on the grid, updating
                    // attributes to reference this language and adding a preference
                    // to the prefpane for each item
                    Alph.$("checkbox",grid).each(
                        function()
                        {
                            
                            var id = this.getAttribute("id");
                            if (id != null)
                            {
                                this.setAttribute("id",id + "-" + lang);
                            }
                            
                            var pref_id = this.getAttribute("preference");
                            var new_pref_id = pref_id + "-" + lang;
                            
                            this.setAttribute("preference",new_pref_id);
                            
           
                            // add a preference to the pane for this checkbox
                            var def_pref = Alph.$("preference#"+pref_id);
                            
                            var new_pref_name = 
                                def_pref.attr("name").
                                replace(
                                    /(extensions.alpheios)/,
                                    "$1."+lang);
                                    
                            var new_pref = document.createElementNS(
                                    "http://www.mozilla.org/keymaster/gatekeeper/there.is.only.xul", 
                                    "preference");
                                    
                            new_pref.setAttribute("id",new_pref_id);
                            new_pref.setAttribute("type","int");
                            new_pref.setAttribute("name",new_pref_name); 
                            prefs.appendChild(new_pref);
                            
                            // if we're using the defaults, show whatever
                            // we last had set for the language preferences
                            // but disable the checkboxes
                            if (use_defs_cbx.checked)
                            {
                                this.setAttribute("disabled",true);
                            }
                        
                            
                        }
                    );
                    
                    // add a handler to the override checkbox
                    Alph.$(use_defs_cbx).click(
                        function()
                        {
                            Alph.prefs.toggle_panel_pref_cbx(this);
                        }
                    );
        
                    // add the new grid to the box
                    box.appendChild(Alph.$(grid).get(0));
                }        
            }
        );
    },
    
    /**
     * respond to a change to a panel preference checkbox -- since
     * the values of these preferences are not simple booleans, need
     * to return the correct Alph.Panel static variable for the state
     * @param {XULElement} a_cbx the XUL Checkbox element for the panel preference
     * @return one of Alph.Panel.STATUS_SHOW or Alph.Panel.STATUS_HIDE
     * @type int
     */
    update_panel_pref: function(a_cbx)
    {
        if (a_cbx.checked)
        {
            return Alph.Panel.STATUS_SHOW;      
        }
        else 
        {
            return Alph.Panel.STATUS_HIDE;
        }         
    },
    
    /**
     * Toggle the disabled state of the language-specific panel
     * preferences checkboxes
     * @param {XULElement} a_cbx the XUL Checkbux element for using panel defaults 
     */
    toggle_panel_pref_cbx: function(a_cbx)
    {
        // if the use defaults checkbox is checked, then  
        // the per-language panel preference checkboxes should be disabled
        var disabled = a_cbx.checked;
        // Pickup the language from the checkbox id
        try
        {
            var lang = a_cbx.id.match(/-(\w+)$/)[1];
            var grid = Alph.$("#alpheios-panel-prefs-"+lang);
            // iterate through the panel preference checkboxes for this
            // language, updating the disabled status
            Alph.$("checkbox",grid).each(
                function()
                {
                    this.setAttribute("disabled",disabled);
                }
            );
        }
        catch(e)
        {
            // no match 
        }
    },
    
    /**
     * Restore the default panel settings for a language
     * @param {String} a_lang the language
     */
    restore_panel_defaults: function(a_elem)
    {
            var grid_id = "#alpheios-panel-prefs";
            if (typeof a_lang == "undefined")
            {
                grid_id = grid_id + "-default";
            }
            else
            {
                grid_id = grid_id + "-" + a_lang;
            }
            var tabpanel = Alph.$(a_elem).parents("tabpanel").get(0);
            var grid = Alph.$(grid_id);
            // iterate through the panel preference checkboxes for this
            // language, refreshing the defaults
            Alph.$("checkbox",tabpanel).each(
                function()
                {
                    var pref_id = this.getAttribute("preference");
                    var pref = document.getElementById(pref_id);
                    if (pref.defaultValue == null)
                    {
                        // get the global default if none was specified
                        // in the language defaults
                        var match_string = new RegExp('\.' + a_lang);
                        var g_pref_id = pref_id.replace(match_string,"");
                        pref.value = 
                            document.getElementById(g_pref_id)
                            .defaultValue;
                    }
                    else
                    {
                        pref.value = pref.defaultValue;
                    }
                }
                
            );
        
    },
    
    /**
     * Initialize the dictionary preferences screen
     * populates the language-specific tabs in the Dictionary
     * preferences pane with the default dictionary preference 
     * elements for the language. 
     */
    init_dict_prefs: function()
    {
        var strings = document.getElementById("alpheios-prefs-strings");

        var prefs = Alph.$("#alpheios-prefs-dictionaries preferences").get(0);

        var dict_types = ['short','full'];
        
        // iterate through the languages which have containers for the
        // dictionary preferences defined
        Alph.$("[id^=dicts-prefs-language-details-]").each(
            function() {
                var dict_parent = this;
                var lang = this.id.match(/dicts-prefs-language-details-(.+)$/)[1];
                if (lang != null && typeof lang != "undefined")
                {
                    var lang_strings = document.getElementById("alpheios-prefs-strings-"+lang);
                    var short_list = null;
                    var full_list = null;
                    try
                    {
                        short_list = Alph.prefs._PREFS.getCharPref(lang + '.dictionaries.short');
                        short_list = short_list.split(/,/).sort().join(',');
                    }
                    catch(a_e){}
                    try 
                    {
                        full_list = Alph.prefs._PREFS.getCharPref(lang + '.dictionaries.full');
                        full_list = full_list.split(/,/).sort().join(',');
                    }
                    catch(a_e){}
                    
                    dict_types.forEach(
                        function(a_type)
                        {
                            var list = (a_type == 'short') ? short_list : full_list;
                            // if there are more than one dictionary of this type
                            // present controls to set the search order
                            if (list && list.indexOf(',') != -1)
                            {
                                // add preference 
                                prefs.appendChild(
                                Alph.util.makePref(
                                    'pref-' + lang + '-dict-' + a_type,
                                    'extensions.alpheios.' + lang + '.dictionaries.' + a_type,
                                    'string')
                                );
                                var grid = Alph.util.makeXUL(
                                    'grid',
                                    'alph-dict-grid-'+lang,
                                    [],[]
                                );
                                var cols = Alph.util.makeXUL('columns',null,[],[]);
                                cols.appendChild(Alph.util.makeXUL('column',null,['flex'],['1']));
                                cols.appendChild(Alph.util.makeXUL('column',null,[],[]));
                                grid.appendChild(cols);
                                var rows = Alph.util.makeXUL('rows',null,[],[]);
                                var row = Alph.util.makeXUL('row',null,[],[])
                                var lb_ordered = Alph.util.makeXUL('listbox',
                                    'dict-order-'+lang + '-' + a_type,
                                    ['seltype','preference','onsyncfrompreference'],
                                    ['single','pref-' + lang + '-dict-' + a_type,
                                     'Alph.prefs.read_dict_list("' + lang + '","' + a_type +'");' 
                                    ]);
                                var button_box = Alph.util.makeXUL('vbox',null,[],[]);
                                button_box.appendChild(
                                    Alph.util.makeXUL(
                                        'button',
                                        'up_'+a_type,
                                        ['label','disabled'],
                                        [strings.getString('dict.buttons.moveup'),'true'])
                                );
                                button_box.appendChild(
                                    Alph.util.makeXUL(
                                        'button',
                                        'down_'+ a_type,
                                        ['label','disabled'],
                                        [strings.getString('dict.buttons.movedown'),'true'])
                                );
                                if (short_list == full_list)
                                {
                                    button_box.appendChild(
                                        Alph.util.makeXUL(
                                            'button',
                                            'reset_' + a_type,
                                            ['label'],
                                            [strings.getString('dict.buttons.copy.'+a_type),'true'])
                                    );
                                }
                                Alph.$(lb_ordered).select(Alph.prefs.on_dict_select); 
                                row.appendChild(lb_ordered);
                                row.appendChild(button_box);
                                rows.appendChild(row);
                                grid.appendChild(cols);
                                grid.appendChild(rows);
                                var label = Alph.util.makeXUL(
                                    'label',
                                    null,
                                    ['value'],
                                    [strings.getString('dict.labels.order.'+a_type)]);
                                dict_parent.appendChild(label);
                                dict_parent.appendChild(grid);
                            }
                            // if there is only one dictionary of this type
                            // just display it
                            else if (list)
                            {
                                var label_str = 
                                    strings.getFormattedString(
                                        'dict.labels.single.' + a_type,
                                        [lang_strings.getString('dict.' + list)]);
                                dict_parent.appendChild(
                                    Alph.util.makeXUL(
                                        'label',
                                         '',
                                         ['value'],
                                         [label_str]
                                    )
                                );
                            }
                        }
                    );
                    Alph.$("button",dict_parent).click(Alph.prefs.write_dict_list);
                    var hbox = Alph.util.makeXUL('hbox',null,[],[]);
                    var command_str = 
                            'document.documentElement.openSubDialog(' + 
                            '"chrome://alpheios/content/alpheios-dict-prefs-adv.xul","",' + 
                            '{lang: "' + lang + '"}' +
                            ');'
                    hbox.appendChild(
                        Alph.util.makeXUL(
                            'button',
                            'advanced',
                            ['label','oncommand'],
                            [strings.getString('dict.buttons.advanced'),command_str])
                    );
                    dict_parent.appendChild(hbox);
                    
                }
            }            
        );
    },
    
    /**
     * Initialize the advanced dictionary preferences screen
     */
    init_adv_dict_prefs: function()
    {
        var a_lang = window.arguments[0].lang;
        var strings = document.getElementById("alpheios-prefs-strings");

        var prefs = Alph.$("#alpheios-prefs-dict-advanced-dlg preferences").get(0);
        
        var URL = '.url';
        var LEMMA = '.lemma_param';
        var ID = '.id_param';
        var MULTI = '.multiple_lemmas';
        
        var dict_parent = 
            Alph.$("#dicts-prefs-language-details-adv-" + a_lang).get(0);
        if (dict_parent)
        {
            dict_parent.setAttribute("hidden",'false');
            var lang_strings = document.getElementById("alpheios-prefs-strings-"+a_lang);
                                        
            var ctl_id = a_lang+'-dict-url';
            var pref_id = 'pref-' + ctl_id;
                        
            var pref_base = 
                    'extensions.alpheios.' + 
                    a_lang +
                    '.dictionary.full' 
            var pref_base_s = pref_base + '.search';
            // add the preferences for url and lemma
            prefs.appendChild(
                Alph.util.makePref(
                    pref_id,
                    pref_base_s + URL,
                    'string')
            );
            prefs.appendChild(
                Alph.util.makePref(
                    pref_id + LEMMA,
                    pref_base_s + LEMMA,
                    'string')
            );
            prefs.appendChild(
                Alph.util.makePref(
                    pref_id + ID,
                    pref_base_s + ID,
                    'string')
            );
            prefs.appendChild(
                Alph.util.makePref(
                    pref_id + MULTI,
                    pref_base_s + MULTI,
                    'bool')
            );
                
            var hbox =
                Alph.util.makeXUL('hbox','',[],[]);
            hbox.appendChild(
                Alph.util.makeXUL(
                    'label',
                    '',
                    ['control','value'],
                    [ctl_id,strings.getString('dict.url.search')]
                )
            );
            hbox.appendChild(
                Alph.util.makeXUL(
                    'textbox',
                    ctl_id,
                    ['preference','class'],
                    [pref_id,'url']
                )
            );
             var hbox_lemma =
                Alph.util.makeXUL('hbox','',[],[]);
            hbox_lemma.appendChild(
                Alph.util.makeXUL(
                    'label',
                    '',
                    ['control','value'],
                    [ctl_id+LEMMA,
                     strings.getString('dict.url' + LEMMA)]
                )
            );
            hbox_lemma.appendChild(
                Alph.util.makeXUL(
                    'textbox',
                    ctl_id + LEMMA,
                    ['preference','class'],
                    [pref_id+LEMMA,'param']
                )
            );
            var hbox_id =
                Alph.util.makeXUL('hbox','',[],[]);
            hbox_id.appendChild(
                Alph.util.makeXUL(
                    'label',
                    '',
                    ['control','value'],
                    [ctl_id+ID,
                     strings.getString('dict.url' + ID)]
                )
            );
            hbox_id.appendChild(
                Alph.util.makeXUL(
                    'textbox',
                    ctl_id + ID,
                    ['preference','class'],
                    [pref_id+ID,'param']
                )
            );
            var hbox_multi =
                Alph.util.makeXUL('hbox','',['align'],['top']);
            hbox_multi.appendChild(
                Alph.util.makeXUL(
                    'checkbox',
                    ctl_id + MULTI,
                    ['preference','label'],
                    [pref_id+MULTI,strings.getString('dict.url' + MULTI)]
                )
            );
              
            dict_parent.appendChild(hbox);
            dict_parent.appendChild(hbox_id);
            dict_parent.appendChild(hbox_lemma);
            dict_parent.appendChild(hbox_multi);
        }
    },
    
    /**
     * handler which responds to selection of a dictionary name
     * in the dictionary order listboxes
     * 'this' is the listbox element
     * Adapted from chrome://browser/content/preferences/languages.js
     */
    on_dict_select: function()
    {
        var button_col = Alph.$(this).next().get(0);
        if (button_col)
        {
            var upButton = Alph.$("button[id^=up_]",button_col).get(0);
            var downButton = Alph.$("button[id^=down_]",button_col).get(0);
            switch (this.selectedCount) {
            case 0:
              upButton.disabled = downButton.disabled = true;
              break;
            case 1:
              upButton.disabled = this.selectedIndex == 0;
              downButton.disabled = this.selectedIndex == this.childNodes.length - 1;
              break;
            default:
              upButton.disabled = true;
              downButton.disabled = true;            
          }
        }
    },
    
    /**
     * Populates the dictionary order list from preferences
     * @param {String} a_lang the language 
     * @param {String} a_type short or full
     * Adapted from chrome://browser/content/preferences/languages.js
     */
    read_dict_list: function(a_lang,a_type)
    {
        var lang_strings = document.getElementById("alpheios-prefs-strings-"+a_lang);
        var dictionary_list = 
            Alph.$("#pref-" + a_lang + '-dict-' + a_type).get(0).value;
        
        var listbox = Alph.$("#dict-order-" + a_lang + '-' + a_type).get(0);
        // clear out any current contents of the dictionary order list box
        while (listbox.hasChildNodes())
            listbox.removeChild(listbox.firstChild);
        var selected_index=0;
        // iterate through the new preference value, repopulating the order listbox
        dictionary_list.split(/,/).forEach(
            function(a_dict,a_i)
            {
                var item_id = a_dict + '.' + a_type;
                listbox.appendChild(
                    Alph.util.makeXUL(
                    'listitem',
                    item_id,
                    ['label'],[lang_strings.getString('dict.' + a_dict)])
                );   
                if (item_id == Alph.prefs._selected_dict_item)
                {
                    selected_index = a_i;    
                }
            }
        );
        listbox.selectedIndex = selected_index || 0;
                                                        
    },
    /**
     * Handler which responds to a click on one of the action buttons
     * for ordering a dictionary list
     * 'this' is the button element which was clicked
     * Adapted from chrome://browser/content/preferences/languages.js
     */
    write_dict_list: function()
    {
        var button_id = this.id.split(/_/);
        var list = Alph.$(this).parent().prev().get(0);
        if (button_id[0] == 'up')
        {
            var selectedItem = list.selectedItems[0];
            var previousItem = selectedItem.previousSibling;
            var string = "";
            for (var i = 0; i < list.childNodes.length; ++i) 
            {
                var item = list.childNodes[i];
                string += (i == 0 ? "" : ",");
                if (item.id == previousItem.id) 
                    string += selectedItem.id.match(/^(.+)\./)[1];
                else if (item.id == selectedItem.id)
                    string += previousItem.id.match(/^(.+)\./)[1];
                else
                    string += item.id.match(/^(.+)\./)[1];
            }
            Alph.prefs._selected_dict_item = selectedItem.id;

        }
        else if (button_id[0] == 'down')
        {
            var selectedItem = list.selectedItems[0];
            var nextItem = selectedItem.nextSibling;
    
            var string = "";
            for (var i = 0; i < list.childNodes.length; ++i) 
            {
                var item = list.childNodes[i];
                string += (i == 0 ? "" : ",");
                if (item.id == nextItem.id) 
                    string += selectedItem.id.match(/^(.+)\./)[1];
                else if (item.id == selectedItem.id)
                    string += nextItem.id.match(/^(.+)\./)[1];
                else
                    string += item.id.match(/^(.+)\./)[1];
            }
            Alph.prefs._selected_dict_item = selectedItem.id;
        }
        else if (button_id[0] == 'reset')
        {
            var pref = list.getAttribute("preference");
            if (button_id[1] == 'short')
            {
                pref = pref.replace('short','full');
            }
            else
            {
                pref = pref.replace('full','short');
            }
            string = Alph.$("#"+pref).get(0).value;
            Alph.prefs._selected_dict_item = 0;
        }
        else
        {
            return true;
        }
                
        // Update the preference and force a UI rebuild
        var preference = Alph.$("#" + list.getAttribute("preference")).get(0);
        preference.value = string;
        //Alph.prefs.read_dict_list(list.id.match(/dict-order-(.*?)-/)[1],button_id[1]);
    },
   
    /**
     * Initialize the site preferences screen
     * populates the language-specific tabs in the Dictionary
     * preferences pane with the default dictionary preference 
     * elements for the language. 
     */
    init_site_prefs: function()
    {
        var strings = document.getElementById("alpheios-prefs-strings");
        var prefs = Alph.$("#alpheios-prefs-sites preferences").get(0);
        // iterate through the languages which have containers for the
        // site preferences defined
        Alph.$("[id^=site-prefs-language-details-]").each(
            function() {
                var lang_parent = this;
                var lang = this.id.match(/site-prefs-language-details-(.+)$/)[1];
                if (lang != null && typeof lang != "undefined")
                {
                    var lang_strings = document.getElementById("alpheios-prefs-strings-"+lang);
                    
                    prefs.appendChild(
                                Alph.util.makePref(
                                    'pref-' + lang + '-autoenable-sites',
                                    'extensions.alpheios.' + lang + '.sites.autoenable',
                                    'string')
                                );
                    var grid = Alph.util.makeXUL(
                        'grid',
                        'alph-site-grid-'+lang,
                        [],[]
                    );
                    var cols = Alph.util.makeXUL('columns',null,[],[]);
                    cols.appendChild(Alph.util.makeXUL('column',null,['flex'],['1']));
                    cols.appendChild(Alph.util.makeXUL('column',null,[],[]));
                    grid.appendChild(cols);
                    var rows = Alph.util.makeXUL('rows',null,[],[]);
                    var row = Alph.util.makeXUL('row',null,[],[])
                    var lb_ordered = Alph.util.makeXUL('listbox',
                        'site-list-autoenable-'+lang,
                        ['seltype','preference','onsyncfrompreference'],
                        ['single','pref-' + lang + '-autoenable-sites',
                        'Alph.prefs.read_site_list("' + lang + '");' 
                    ]);
                    var button_box = Alph.util.makeXUL('vbox',null,[],[]);
                    button_box.appendChild(
                        Alph.util.makeXUL(
                        'button',
                        'disable-site',
                        ['label','disabled'],
                        [strings.getString('sites.buttons.disable'),'true'])
                    );
                    button_box.appendChild(
                        Alph.util.makeXUL(
                        'button',
                        'enable-site',
                        ['label','disabled'],
                        [strings.getString('sites.buttons.enable'),'true'])
                    );
                    Alph.$(lb_ordered).select(Alph.prefs.on_site_select); 
                    row.appendChild(lb_ordered);
                    row.appendChild(button_box);
                    rows.appendChild(row);
                    grid.appendChild(cols);
                    grid.appendChild(rows);
                    var label = Alph.util.makeXUL(
                        'label',
                        null,
                        ['value'],
                        [strings.getString('site.labels.autoenable')]);
                        lang_parent.appendChild(label);
                        lang_parent.appendChild(grid);
                    Alph.$("button",lang_parent).click(Alph.prefs.toggle_site);
                }
                
            }
        );
    },
    
    /**
     * Populates the site list from preferences
     * @param {String} a_lang the language 
     * Adapted from chrome://browser/content/preferences/languages.js
     */
    read_site_list: function(a_lang)
    {
        var lang_strings = document.getElementById("alpheios-prefs-strings-"+a_lang);
        var site_list = 
            Alph.$("#pref-" + a_lang + '-autoenable-sites').get(0).value;
        
        var listbox = Alph.$("#site-list-autoenable-" + a_lang).get(0);
        // clear out any current contents of the list box
        while (listbox.hasChildNodes())
            listbox.removeChild(listbox.firstChild);
        var selected_index=-1;
        
        var key = 'alpheios-auto-enable-'+a_lang;
        site_list.split(/,/).forEach(
            function(a_site,a_i)
            {
      
                var uri = Alph.prefs._IO_SVC.newURI(a_site,"UTF-8",null);
                var perm = Alph.PermissionMgr.testPermission(uri,key);
                var status = perm == Alph.PermissionMgr.ALLOW_ACTION ? 'site-enabled' : 'site-disabled';
      
                var item_id = a_lang + '-autoenable-' + a_i;
                listbox.appendChild(
                    Alph.util.makeXUL(
                    'listitem',
                    item_id,
                    ['label','class'],[a_site,status])
                );   
                if (item_id == Alph.prefs._selected_site_item)
                {
                    selected_index = a_i;    
                }
            }
        );
        listbox.selectedIndex = selected_index;
    },
    
    /**
     * Handler which responds to a click on one of the action buttons
     * for enabling/disabling an autoenabled site
     * 'this' is the button element which was clicked
     * Adapted from chrome://browser/content/preferences/languages.js
     */
    toggle_site: function()
    {
        var button_id = this.id;
        var list = Alph.$(this).parent().prev().get(0);
        var selectedItem = list.selectedItems[0];
        var lang = selectedItem.id.match(/^(\w+)-/)[1];
        var key = 'alpheios-auto-enable-'+lang;
        var selectedURL = selectedItem.getAttribute('label');
        var uri = Alph.prefs._IO_SVC.newURI(selectedURL,"UTF-8",null); 
        if (button_id == 'enable-site')
        {
            Alph.PermissionMgr.add(uri,key,Alph.PermissionMgr.ALLOW_ACTION);
        }
        else
        {
            Alph.PermissionMgr.add(uri,key,Alph.PermissionMgr.DENY_ACTION);
        }
        Alph.prefs._selected_site_item = selectedItem.id;
        // update the site list                     
        Alph.prefs.read_site_list(lang);
    },
   
    
    /**
     * handler which responds to selection of a site name
     * in the autoenable site listboxes
     * 'this' is the listbox element
     * Adapted from chrome://browser/content/preferences/languages.js
     */
    on_site_select: function()
    {
        var button_col = Alph.$(this).next().get(0);
        var lang = this.id.match(/-(\w+)$/)[1];
        var key = 'alpheios-auto-enable-'+lang;
        var selectedItem = this.selectedItem;
        if (this.selectedItem)
        {
            var selectedURL = selectedItem.getAttribute('label');
            var uri = Alph.prefs._IO_SVC.newURI(selectedURL,"UTF-8",null);
            var perm = Alph.PermissionMgr.testPermission(uri,key);
            if (button_col)
            {
                var enableButton = Alph.$("button#enable-site",button_col).get(0);
                var disableButton = Alph.$("button#disable-site",button_col).get(0);
                switch (perm) {
                    case Alph.PermissionMgr.ALLOW_ACTION:
                      enableButton.disabled = true;
                      disableButton.disabled = false;
                      break;
                    case Alph.PermissionMgr.DENY_ACTION:
                      enableButton.disabled = false;
                      disableButton.disabled = true;
                      break;
                    default:
                      enableButton.disabled = true;
                      disableButton.disabled = true;            
                    }
            }
        }
    },
};

Alph.prefs.init();