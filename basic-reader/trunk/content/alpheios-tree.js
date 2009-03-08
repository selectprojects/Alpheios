/**
 * @fileoverview This file contains the Alph.Tree derivation of the Alph.Panel class.
 * Representation of the Treeology panel.
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
 * @class The Alph.Tree class is the representation of the Treeology
 * panel.
 * @constructor
 * @param {alpheiosPanel} a_panel DOM object bound to the alpheiosPanel tag
 * @see Alph.Panel
 */
Alph.Tree = function(a_panel)
{
    Alph.Panel.call(this,a_panel);
};

/**
 * @ignore
 */
Alph.Tree.prototype = new Alph.Panel();


/**
 * Tree panel specific implementation of
 * {@link Alph.Panel#show}
 * @return the new panel status
 * @type int
 */
Alph.Tree.prototype.show = function()
{
    var panel_obj = this;
    var bro = Alph.main.getCurrentBrowser();
    var treeDoc = Alph.$("browser",this.panel_elem).get(0).contentDocument;

    // clear out the prior tree
    Alph.$("#dependency-tree", treeDoc).empty();

    var svgDefault =
        '<svg xmlns="http://www.w3.org/2000/svg">' +
        '<g><text class="error">' +
        '<ERROR>' +
        '</text></g>' +
        '</svg>';

    var treebankUrl =
        Alph.$("#alpheios-treebank-diagram-url",bro.contentDocument).attr("content");

    var tbref;
    var sentence;
    var word;
    if (! treebankUrl)
    {
        panel_obj.parse_tree((new DOMParser()).parseFromString(
            svgDefault.replace(
                /<ERROR>/,
                Alph.$("#alpheios-strings").get(0).getString("alph-error-tree-notree")
            ), "text/xml"
        ));
    }
    else if (! Alph.xlate.popupVisible() && ! Alph.interactive.query_visible())
    {
        // Just add the default message to the display
        panel_obj.parse_tree((new DOMParser()).parseFromString(
            svgDefault.replace(
                /<ERROR>/,
                Alph.$("#alpheios-strings").get(0).getString("alph-info-tree-select")
            ), "text/xml"
        ));
    }
    else
    {
        try
        {
            var last_elem = Alph.main.get_state_obj(bro).get_var("lastElem");
            tbref = Alph.$(last_elem).attr("tbref");
            // if the selected element doesn't have a tbref attribute,
            // look for the first parent element that does
            if (! tbref)
            {
                tbref = Alph.$(last_elem).parents('[tbref]').attr("tbref");
            }
            var parts = tbref.split(/-/);
            sentence = parts[0];
            word = parts[1];
        }
        catch(a_e)
        {
            Alph.util.log("Error identifying sentence and id: " + a_e);
        }

        //var sentence  = Alph.$(".alph-proto-sentence",bro.contentDocument);
        //var sentence  = Alph.$(".l",bro.contentDocument);
        if (! sentence )
        {
            // Just add the default message to the display
            panel_obj.parse_tree((new DOMParser()).parseFromString(
                svgDefault.replace(
                    /<ERROR>/,
                    Alph.$("#alpheios-strings").get(0).getString("alph-error-tree-notree")
                ), "text/xml"
            ));
        }
        else
        {
            treebankUrl = treebankUrl.replace(/SENTENCE/, sentence);
            treebankUrl = treebankUrl.replace(/WORD/, word);
            Alph.$.ajax(
                {
                    type: "GET",
                    url: treebankUrl,
                    timeout: Alph.util.getPref("url.treebank.timeout") || 5000,
                    dataType: 'xml',
                    error: function(req,textStatus,errorThrown)
                    {
                        var data = (new DOMParser()).parseFromString(
                            svgDefault.replace(
                            /<ERROR>/,
                            Alph.$("#alpheios-strings")
                                .get(0).getString("alph-error-tree-notree")
                            ), "text/xml"
                        );
                        Alph.util.log("Error retrieving treebank diagram: "
                            + textStatus ||errorThrown);
                        panel_obj.parse_tree(data);
                    },
                    success: function(data, textStatus)
                    {
                        panel_obj.parse_tree(data, tbref);
                    }
                }
            );
        }
    }
    return Alph.Panel.STATUS_SHOW;

};

Alph.Tree.prototype.parse_tree = function(a_svgXML, a_id)
{
    var marginLeft = 10;
    var marginTop = 0;
    var fontSize = 20;
    var treeDoc = Alph.$("browser",this.panel_elem).get(0).contentDocument;
    try
    {
        Alph.$("#dependency-tree", treeDoc).
            append(a_svgXML.firstChild.childNodes);
        var svgXML = Alph.$("#dependency-tree", treeDoc).get(0);
        var returned =
                position(
                    Alph.$(svgXML).children('g:first').children('g').get(0),
                    true,
                    marginLeft,
                    marginTop + fontSize,
                    fontSize,
                    0);
        positionText(treeDoc, returned[2], returned[3], fontSize);
//      Alph.util.log("SVG: " + XMLSerializer().serializeToString(svgXML));
        highlight(treeDoc, a_id);
//      Alph.util.log("SVG: " + XMLSerializer().serializeToString(svgXML));

        // jQuery doesn't seem to support retrieving svg nodes by class
        // or attribute, so just get by tag name and retrieve the attribute
        // directly using the javascript getAttribute function to filter for
        // the nodes we want

        // for each text element
        Alph.$("text",treeDoc).each(
            function()
            {
                var thisNode = Alph.$(this);

                // if this is a text word
                if (thisNode.attr('class') == 'text-word')
                {
                    // turn on highlighting for the word
                    var tbrefid = thisNode.attr('tbref');
                    thisNode.bind(
                        'mouseenter',
                        function() { highlight(this.ownerDocument, tbrefid) }
                    );
                }
                // if this is a label
                else if (thisNode.attr('class') == 'node-label')
                {
                    // highlight the word while hovering
                    var id = thisNode.parent().attr('id');
                    thisNode.hover(
                        function() { highlight(this.ownerDocument, id) },
                        function() { highlight(this.ownerDocument, null) }
                    );
                }
            }
        );
        // for each group
        Alph.$("g",treeDoc).each(
            function()
            {
                var thisNode = Alph.$(this);

                // if this is container of text words
                if (thisNode.attr('class') == 'text')
                {
                    // turn off highlighting when we leave
                    thisNode.bind(
                        'mouseleave',
                        function() { highlight(this.ownerDocument, null) }
                    );
                }
            }
        );
    }
    catch(e)
    {
        Alph.util.log(e);
    }

    // make sure to update the detached window document too...
    // update the panel document whether or not the window is detached
    // because otherwise the screen doesn't seem to redraw right
    if (this.panel_window != null)
    {
        var window_doc =
            this.panel_window.Alph.$("#" + this.panel_id + " browser").get(0).contentDocument;
        var panel_tree = Alph.$("#dependency-tree", treeDoc);
        Alph.$("#dependency-tree", window_doc).empty();
        Alph.$("#dependency-tree", window_doc).append(Alph.$(panel_tree).children().clone(true));
        Alph.$("#dependency-tree", window_doc).attr("width",Alph.$(panel_tree).attr("width"));
        Alph.$("#dependency-tree", window_doc).attr("height",Alph.$(panel_tree).attr("height"));
        this.panel_window.focus();
    }

}


/**
 * Tree panel specific implementation of
 * {@link Alph.Panel#get_detach_chrome}
 * @return the chrome url as a string
 * @type String
 */
Alph.Tree.prototype.get_detach_chrome = function()
{
    return 'chrome://alpheios/content/alpheios-tree-window.xul';
}

//
// Function to highlight a word in the tree
// Parameters:
//   a_doc       the tree
//   a_id        id of word in tree
//
//  The word and its surrounding lines and nodes
//  are left with normal coloring.  The remainder
//  of the tree is grayed out.
//
//  If no id or a bad id is specified, the entire tree is
//  ungrayed.
//
//  Note: jquery seems not to work well with selectors requiring
//  testing of attribute values.  Hence, the expressions below
//  are sometimes a bit contorted.  The assumption is made
//  that the text element of class "node-label" immediately precedes the
//  text element of class "arc-label", and that the top-level group of class
//  "tree" immediately precedes the group of class "text".
//
function highlight(a_doc, a_id)
{
    // find node of interest
    var focusNode = Alph.$("#" + a_id, a_doc);

    // if no id or bad id
    if (focusNode.size() == 0)
    {
        // display everything normally
        Alph.$("text", a_doc).attr("showme", "normal");
        Alph.$("line", a_doc).attr("showme", "normal");
        Alph.$("rect", a_doc).attr("showme", "normal");
        return;
    }

    // gray everything out in tree (but not text words)
    Alph.$("text", a_doc).attr("showme", "grayed");
    Alph.$("svg", a_doc).children("g").next().children("text").attr("showme", "normal")
    Alph.$("line", a_doc).attr("showme", "grayed");
    Alph.$("rect", a_doc).attr("showme", "grayed");

    // display this node and things connected to it with focus:
    //   text node itself and label on line to parent
    //   rectangle around node
    //   line to parent
    //   dependent words (children of sibling groups)
    //   line to dependent words
    //   label on parent word
    focusNode.children("text").attr("showme", "focus");
    focusNode.children("rect").attr("showme", "focus");
    focusNode.children("line").attr("showme", "focus");
    focusNode.children("g").children("text").attr("showme", "focus-child");
    focusNode.children("g").children("rect").attr("showme", "focus-child");
    focusNode.children("g").children("line").attr("showme", "focus-child");
    if (focusNode.parent().children("text").size() > 0)
    {
        focusNode.parent().children("text:first").attr("showme", "focus-parent");
        focusNode.parent().children("rect").attr("showme", "focus-parent");
    }

    // set highlights on text words below tree
    highlightTextWord(a_doc, a_id, "focus");
    highlightTextWord(a_doc, focusNode.parent().attr("id"), "focus-parent");
    focusNode.children("g").each(
        function()
        {
            highlightTextWord(a_doc, Alph.$(this).attr("id"), "focus-child");
        }
    );
}

//
// Function to highlight a text word below tree
// Parameters:
//   a_doc       the tree
//   a_id        id of word (tbref attribute on text word)
//   a_focus     value to set focus to
//
function highlightTextWord(a_doc, a_id, a_focus)
{
    Alph.$("rect", a_doc).each(
        function()
        {
            if (Alph.$(this).attr('tbref') == a_id)
            {
                Alph.$(this).attr("showme", a_focus);
            }
        }
    );
}

//
// Function to position text words in tree
// Parameters:
//   a_doc       the tree
//   a_width     width of tree
//   a_height    height of tree
//   a_fontSize  size of font to use for text
//
// The text words are placed underneath the tree itself, wrapping
// at the width of the tree (except if the tree is narrow, wrapping
// at 300 pixels).
//
// The height and width including the text are set as the values for
// the parent svg element.
//
function positionText(a_doc, a_width, a_height, a_fontSize)
{
    // if no words, just set width and height
    var words = Alph.$("svg", a_doc).children("g").next().children("text");
    var rects = Alph.$("svg", a_doc).children("g").next().children("rect");
    if (words.size() == 0)
    {
        Alph.$("svg", a_doc).attr("width", a_width);
        Alph.$("svg", a_doc).attr("height", a_height);
        return;
    }

    // 300 = minimum width allowed for text to avoid excessive wrapping
    var width = (a_width > 300) ? a_width : 300;
    var padding = a_fontSize / 4;
    var lineHeight = a_fontSize + padding;
    var x = 0;
    var y = a_height + lineHeight;

    // for each word
    for (var i = 0; i < words.size(); ++i)
    {
        var word = words.get(i);
        var rect = rects.get(i);

        // if word goes past end of line
        var wlen = word.getComputedTextLength();
        if (x + wlen > width)
        {
            // if not first word in line, wrap
            if (x > 0)
            {
                x = 0;
                y += lineHeight;
            }
            // if first word, widen line
            else
            {
                width = x + wlen;
            }
        }

        // position word and bounding rectangle
        word.setAttribute('x', x + 'px');
        word.setAttribute('y', y + 'px');
        rect.setAttribute('x', x + 'px');
        rect.setAttribute('y', (y - lineHeight + padding) + 'px');
        rect.setAttribute('width', wlen + 'px');
        rect.setAttribute('height', lineHeight + 'px');

        // advance in line
        x += wlen;
    }

    // set width and height
    Alph.$("svg", a_doc).attr("width", width);
    Alph.$("svg", a_doc).attr("height", y + padding);
}

/*
 * The following code is adapted from SVG tree drawer
 * Copyright (C) 2004 Weston Ruter <http://weston.ruter.net/>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will core useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */

//position the nodes in a tree structure
function position(a_containerNode,
                  a_isRoot,
                  a_shiftLeft,
                  a_shiftTop,
                  a_fontSize,
                  a_parentWidth)
{
    // constants
    var wordSpacing = 20; //wordSpacing/2 == text padding
    var branchHeight = a_fontSize * 3;
    var branchPaddingTop = a_fontSize/4;
    var branchPaddingBottom = 0;

    var isEmpty = false;
    var childrenWidth = 0;
    var children = Array();
    var nodeLabel;
    var nodeLabelWidth;
    var textWidth;
    var nodeBranch;
    var nodeBox;
    var lineLabel;
    var maxX = 0;
    var maxY = 0;

    //get and handle children ============================
    for (var i = 0; i < a_containerNode.childNodes.length; i++)
    {
        var node = a_containerNode.childNodes.item(i);
        var nodeName = node.nodeName;

        if ((nodeName == "text") &&
            (node.getAttribute("class") == "arc-label"))
        {
            lineLabel = node;
        }
        else if (nodeName == "text")
        {
            nodeLabel = node;

            //determine the width of the label
            if (!nodeLabel.firstChild ||
                !nodeLabel.firstChild.nodeValue ||
                nodeLabel.firstChild.nodeValue.match(/^\s*$/))
            {
                textWidth = 0;
                nodeLabelWidth = wordSpacing;
                isEmpty = true;
            }
            else
            {
                nodeLabelWidth = wordSpacing +
                                 nodeLabel.getComputedTextLength();
                textWidth = nodeLabelWidth;
                isEmpty = false;
            }
            if (nodeLabelWidth < a_parentWidth)
                nodeLabelWidth = a_parentWidth;
        }
        //connecting branch
        else if (nodeName == "line")
        {
            nodeBranch = node;
        }
        // bounding rectangle
        else if (nodeName == "rect")
        {
            nodeBox = node;
        }
        //children nodes
        else if (nodeName == "g")
        {
            var returned =
                  position(node,
                           false,
                           a_shiftLeft + childrenWidth,
                           a_shiftTop + (isEmpty ? branchHeight :
                                                   branchHeight + a_fontSize),
                           a_fontSize,
                           nodeLabelWidth);
            children.push(returned[0]);
            childrenWidth += returned[1];

            // update size
            if (returned[2] > maxX)
                maxX = returned[2];
            if (returned[3] > maxY)
                maxY = returned[3];
        }
    }

    //draw label, children, and branches ==================
    if (!childrenWidth) //there are no children; this is the branch end
        childrenWidth = nodeLabelWidth;
    if (nodeLabel == null)
        throw Error("Error: Every child must have a label");

    //position label
    var thisY = a_shiftTop;
    var thisX;
    if (children.length)
    {
        var firstChild =
                parseFloat(children[0].nodeLabel.getAttribute('x'));
        var lastChild =
                parseFloat(children[children.length-1].
                                nodeLabel.
                                getAttribute('x'));
        thisX = (firstChild + lastChild)/2;
    }
    else
        thisX = a_shiftLeft + childrenWidth/2;
    nodeLabel.setAttribute('y', thisY + 'px');
    nodeLabel.setAttribute('x', thisX + 'px');

    // position box around label
    if (nodeBox)
    {
        nodeBox.setAttribute('x', (thisX - textWidth/2) + 'px');
        nodeBox.setAttribute('y', (thisY - a_fontSize) + 'px');
        nodeBox.setAttribute('width', textWidth + 'px');
        nodeBox.setAttribute('height', (a_fontSize + branchPaddingTop) + 'px');
    }
    thisY += (isEmpty ? -a_fontSize : branchPaddingTop);

    //connect branches from child labels to parent label
    //and position line labels
    for (var i = 0; i < children.length; i++)
    {
        // set this end of line
        var node = children[i].branch;
        node.setAttribute('x1', thisX + 'px');
        node.setAttribute('y1', thisY + 'px');

        // position label
        var label = children[i].lineLabel;
        var width = label.getComputedTextLength() + wordSpacing;
        var midX = (thisX + parseFloat(node.getAttribute('x2'))) / 2;
        midX += ((midX <= thisX) ? -width/2 : width/2);
        var midY = (thisY + parseFloat(node.getAttribute('y2'))) / 2;
        label.setAttribute('x', midX + 'px');
        label.setAttribute('y', midY + 'px');
    }

    // update size
    thisX += nodeLabelWidth/2;
    if (thisX > maxX)
        maxX = thisX;
    thisY += (isEmpty ? 0: a_fontSize);
    if (thisY > maxY)
        maxY = thisY;

    //below root: anchor one end of the branch to the label
    if (!a_isRoot)
    {
        if (nodeBranch)
        {
            nodeBranch.setAttribute('x2', nodeLabel.getAttribute('x'));
            nodeBranch.setAttribute(
                            'y2',
                            (parseFloat(nodeLabel.getAttribute('y')) -
                             a_fontSize - branchPaddingBottom) +
                            'px');
        }
    }

    return Array({nodeLabel:nodeLabel, lineLabel:lineLabel, branch:nodeBranch},
                 childrenWidth,
                 maxX,
                 maxY);
}
