<?xml version="1.0" encoding="UTF-8"?>

<!--
    Stylesheet for transformation of noun inflection data to HTML
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xmlns:exsl="http://exslt.org/common"
    xmlns:xlink="http://www.w3.org/1999/xlink">
    
    <!--
        This stylesheet groups the data on 3 attributes for the rows, 
        and groups on 3 attributes for the columns.
        Grouping attributes are supplied as parameters.
        Grouping parameters are required.
        A optional ending parameter can be used to identify the ending
        to be indicated as 'selected' in the HTML table.     
    -->
    
    <xsl:output method="html" encoding="UTF-8" indent="yes"/>
    
    <xsl:strip-space elements="*"/>
    
    <xsl:key name="footnotes" match="footnote" use="@id"/>
                
    <!-- all parameters may be supplied in transformation -->
    <!-- row groupings --> 
    <!-- default order is Number, Case -->
    
    <xsl:param name="group1" select="'num'"/>
    <xsl:param name="group2" select="'case'"/>
    
    <!-- column groupings -->
    <!-- default order is Declension, Gender-->
    <xsl:param name="group4" select="'decl'"/>
    <xsl:param name="group5" select="'gend'"/>
    <xsl:param name="group6" select="'type'"/>

    <!-- the following is optional, used to select specific inflection ending(s) -->
    <xsl:param name="selected_endings" select="/.." />
    
    <!-- debug -->
    <!--xsl:param name="test_endings">
        <div class="alph-entry">
            <div class="alph-dict">
                <span class="alph-hdwd">sono, sonere, sonui, sonitus: </span>
                <span context="verb" class="alph-pofs">verb</span>
                <span context="3rd" class="alph-conj">3rd conjugation</span>
                <span class="alph-attrlist">(early, very frequent)</span>
                <span class="alph-src">[Ox.Lat.Dict.]</span>
            </div>
            <div class="alph-mean">make a noise/sound; speak/utter, emit sound; be spoken of (as); express/denote;</div>
            <div class="alph-mean">echo/resound; be heard, sound; be spoken of (as); celebrate in speech;</div>
            <div class="alph-infl-set">
                <span class="alph-term">sonit•<span class="alph-suff">u</span></span>
                <span context="supine" class="alph-pofs">(supine)</span>
                <div class="alph-infl">Singular: <span context="ablative-singular-neuter-supine" class="alph-case">ablative (n)</span></div>
            </div>
        </div>
    </xsl:param>
    <xsl:param name='selected_endings' select="exsl:node-set($test_endings)"/-->
    
    <!-- skip the enclosing html and body tags -->
    <xsl:param name="fragment" />
        
    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="$fragment">
                <xsl:call-template name="infltable">
                    <xsl:with-param name="endings" select="//infl-ending-set"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <html>
                    <head>
                        <link rel="stylesheet" type="text/css" href="chrome://alpheios/skin/alph-infl.css"/>
                        <link rel="stylesheet" type="text/css" href="chrome://alpheios/skin/alph-infl-noun.css"/>
                    </head>
                    <body>
                        <xsl:call-template name="infltable">
                            <xsl:with-param name="endings" select="//infl-ending-set"/>
                        </xsl:call-template>                     
                    </body>
                </html>                
            </xsl:otherwise>
        </xsl:choose>            
    </xsl:template>
     
    <xsl:template name="infltable">
        <xsl:param name="endings" />
        <table id="alph-infl-table"> <!-- start table -->
            <caption>
                <xsl:for-each select="$selected_endings">
                    <xsl:if test="position() &gt; 1">
                        , 
                    </xsl:if>
                    <xsl:value-of select="."/>
                </xsl:for-each>
            </caption>
            <!-- write the colgroup elements -->
            <xsl:call-template name="colgroups">
                <xsl:with-param name="headerrow1" select="//order-item[@attname=$group4]"/>
                <xsl:with-param name="headerrow2" select="//order-item[@attname=$group5]"/>
                <xsl:with-param name="headerrow3" select="//order-item[@attname=$group6]"/>
            </xsl:call-template>        
            <!-- write the column header rows -->
            <xsl:call-template name="headers">
                <xsl:with-param name="headerrow1" select="//order-item[@attname=$group4]"/>
                <xsl:with-param name="headerrow2" select="//order-item[@attname=$group5]"/>
                <xsl:with-param name="headerrow3" select="//order-item[@attname=$group6]"/>
            </xsl:call-template>
            <!-- debugging 
            <pre class="debug">
                group1: <xsl:value-of select="$group1"/>
                group2: <xsl:value-of select="$group2"/>
                group4: <xsl:value-of select="$group4"/>
                group5: <xsl:value-of select="$group5"/>
                <xsl:copy-of select="$selected_endings"/>
            </pre>
            -->
            <!-- gather first level row grouping:
                all attribute values for group1 attribute -->
            <xsl:variable name="firstgroup" select="$endings/@*[local-name(.)=$group1]"/>
            <!-- iterate though the items in the first group -->
            <xsl:for-each select="$firstgroup">
                <!-- lookup sort order for this attribute from order-table in the inflection data -->
                <xsl:sort 
                    select="/infl-data/order-table/order-item[@attname=$group1 
                    and text()=current()]/@order" 
                    data-type="number"/>
                <!-- if this is the first instance of this attribute value proceed to 
                    2nd level grouping -->
                <xsl:if test="generate-id(.) = generate-id($firstgroup[.=current()])">
                    <xsl:variable name="lastgroup1" select="."/>
                    <!-- gather second level row grouping:
                        all group2 attribute values 
                        from all elements whose group1 attribute matches the current group1 value  
                    -->                    
                    <xsl:variable name="secondgroup" 
                        select="$endings/@*[local-name(.)=$group1 
                        and .=$lastgroup1]/../@*[local-name(.)=$group2]"/>                    
                    <!-- first instance of group1 row so add header row -->
                    <!-- TODO colspan should not be hardcoded -->
                    <tr id="header-{$lastgroup1}" class="group1row">
                        <th class="header-text always-visible" colspan="2">
                            <xsl:value-of select="$lastgroup1"/>
                            <xsl:call-template name="add-footnote">
                                <xsl:with-param name="item"
                                    select="/infl-data/order-table/order-item[@attname=$group1 
                                    and text()=$lastgroup1]" />
                            </xsl:call-template>                            
                        </th>
                        <xsl:call-template name="headerrow">
                            <xsl:with-param name="headerrow1" select="//order-item[@attname=$group4]"/>
                            <xsl:with-param name="headerrow2" select="//order-item[@attname=$group5]"/>
                            <xsl:with-param name="headerrow3" select="//order-item[@attname=$group6]"/>
                        </xsl:call-template>        
                    </tr>
                    <!-- if none in 2nd group, just add the items in the first group -->                    
                    <xsl:if test="count($secondgroup) = 0">
                        <tr class="data-row">
                            <th class="emptyheader" colspan="2">&#160;</th>
                            <xsl:for-each select="$endings/@*[local-name(.)=$group1 and .=$lastgroup1]/..">
                                <xsl:variable name="selected">
                                    <xsl:call-template name="check_infl_sets">
                                        <xsl:with-param name="current_data" select="." />
                                    </xsl:call-template>
                                </xsl:variable>                                
                                <xsl:call-template name="ending-cell">
                                    <xsl:with-param name="infl-endings" select="infl-ending"/>
                                    <xsl:with-param name="selected" select="$selected"/>
                                </xsl:call-template>                                    
                            </xsl:for-each>
                        </tr>
                    </xsl:if>                                         
                    
                    <!-- iterate through the items in the second group -->
                    <xsl:for-each select="$secondgroup">
                        <xsl:sort select="/infl-data/order-table/order-item[@attname=$group2 
                            and text()=current()]/@order" data-type="number"/>
                            <!-- start a new row to hold the data if this is the first instance of 
                                this attribute value -->
                            <xsl:if test="generate-id(.) = generate-id($secondgroup[.=current()])">
                                <xsl:variable name="lastgroup2" select="."/>
                                <xsl:variable name="row_id" select="concat($lastgroup1,$lastgroup2)"/>
                                <tr class="data-row" id="{$row_id}"> <!-- start new row -->
                                    <th class="emptyheader">&#160;</th>
                                    <!-- gather the actual ending data in this grouping:
                                        all elements whose 
                                        - group1 attribute matches the current group1 value and
                                        - group2 attribute matches the current group2 value
                                    -->
                                    <xsl:variable name="data"
                                        select="$endings/@*[local-name(.)=$group1 
                                        and .=$lastgroup1]/../@*[local-name(.)=$group2 
                                        and . = $lastgroup2]/.."/>
                                    <xsl:call-template name="rowgroup">
                                        <xsl:with-param name="data" select="$data"/>
                                        <xsl:with-param name="groupheader" select="$lastgroup2"/>
                                        <xsl:with-param name="colgroup" select="$lastgroup1"/>
                                    </xsl:call-template>
                                </tr> 
                            </xsl:if>
                    </xsl:for-each>                                  
                </xsl:if>
            </xsl:for-each>            
        </table> <!-- end infl table -->
    </xsl:template>
    
    <!-- template to write a group of rows of infl-ending data to the table -->
    <xsl:template name="rowgroup">
        <xsl:param name="data"/>
        <xsl:param name="groupheader"/>
        <xsl:param name="colgroup"/>
        <xsl:for-each select="$data">
            <xsl:sort 
                select="/infl-data/order-table/order-item[@attname=$group4 
                    and text()=current()/@*[local-name(.)=$group4]]/@order" 
                data-type="number"/>
            <xsl:sort 
                select="/infl-data/order-table/order-item[@attname=$group5 
                    and text()=current()/@*[local-name(.)=$group5]]/@order" 
                    data-type="number"/>
            <xsl:variable name="group4c" select="current()/@*[local-name(.)=$group4]"/>
            <xsl:variable name="group5c" select="current()/@*[local-name(.)=$group5]"/>
            <xsl:if test="position()=1">
                <!-- add the row header cell if it's the first cell in 
                    the row -->
                <th class="rowgroupheader header-text">
                    <xsl:value-of select="$groupheader"/>
                    <xsl:call-template name="add-footnote">
                        <xsl:with-param name="item" select="/infl-data/order-table/order-item[@attname=$groupheader]"/>
                    </xsl:call-template>
                </th>
            </xsl:if>
            <xsl:call-template name="ending-cell">
                <xsl:with-param name="infl-endings" select="infl-ending"/>
            </xsl:call-template>
        </xsl:for-each>        
    </xsl:template>
    
    <xsl:template name="ending-cell">
        <xsl:param name="infl-endings"/>
        <!--div class="debug_sel"><xsl:value-of select="$selected"/></div-->
        <xsl:variable name="ending-types" select="//order-item[@attname=$group6]"/>
        <xsl:for-each select="$ending-types">
            <xsl:sort 
                select="/infl-data/order-table/order-item[@attname=$group6 
                and text()=current()]/@order"/>
            <!-- start a new cell to hold the data if this is the first instance of 
                this attribute value -->
            <xsl:if test="generate-id(.) = generate-id($ending-types[.=current()])">
                <xsl:variable name="lasttype" select="."/>
                <td class="{$lasttype}"> <!-- start new cell -->
                    <xsl:variable name="cellgroup" 
                        select="$infl-endings/@*[local-name(.)=$group6 
                        and .=$lasttype]/.."/>
                    <!-- print an empty cell if there are no endings of this type -->
                    <xsl:if test="count($cellgroup) = 0">
                        &#160;
                    </xsl:if>
                    <xsl:for-each select="$cellgroup">
                        <xsl:variable name="selected">
                            <xsl:call-template name="check_infl_sets">
                                <xsl:with-param name="current_data" select="current()" />
                            </xsl:call-template>
                        </xsl:variable>                                    
                        <xsl:variable name="selected_class">
                            <!-- if this ending matches the one supplied in the template params
                                then add a 'selected' class to the data element -->
                            <xsl:if test="$selected &gt; 0">selected</xsl:if>    
                        </xsl:variable>
                        <xsl:variable name="notfirst">
                            <xsl:if test="position() &gt; 1">notfirst</xsl:if>
                        </xsl:variable>
                        <span class="ending {$selected_class} {$notfirst}">
                            <xsl:value-of select="."/>
                        </span>
                        <xsl:call-template name="add-dialect">
                            <xsl:with-param name="item" select="."/>
                        </xsl:call-template>                        
                        <xsl:call-template name="add-footnote">
                            <xsl:with-param name="item" select="."/>
                        </xsl:call-template>
                    </xsl:for-each>
                </td>
            </xsl:if>
        </xsl:for-each>    
        
    </xsl:template>
    
    <!-- template to produce header rows for the table columns -->    
    <xsl:template name="headers">
        <xsl:param name="headerrow1"/>
        <xsl:param name="headerrow2"/>
        <xsl:param name="headerrow3"/>
        <xsl:variable name="row2count" select="count($headerrow2)"/> 
        <xsl:variable name="row3count" select="count($headerrow3)"/>
        <tr id="headerrow1">
            <th colspan="2" class="always-visible">
                <span class="header-text"><xsl:value-of select="$group4"/></span>    
                <xsl:call-template name="stem-header">
                    <xsl:with-param name="header" select="$group4"/>
                </xsl:call-template>                
            </th>        
            <xsl:for-each select="$headerrow1">
                <xsl:sort select="@order" data-type="number"/>
                <xsl:variable name="colspan" 
                    select="$row2count * $row3count"/>
                    <th colspan="{$colspan}">
                        <span class="header-text"><xsl:value-of select="."/></span>
                        <xsl:apply-templates select="."/>                       
                    </th>
            </xsl:for-each>            
        </tr>
        <tr id="headerrow2">
            <th colspan="2" class="always-visible">
                <span class="header-text"><xsl:value-of select="$group5"/></span>
                <xsl:call-template name="stem-header">
                    <xsl:with-param name="header" select="$group5"/>
                </xsl:call-template>                
            </th>        
            <xsl:for-each select="$headerrow1">
                <xsl:sort select="@order" data-type="number"/>               
                <xsl:for-each select="$headerrow2">
                    <xsl:sort select="@order" data-type="number"/>
                     <th colspan="{$row3count}">
                         <span class="header-text" ><xsl:value-of select="."/></span>
                         <xsl:apply-templates select="."/>                        
                     </th>        
                </xsl:for-each>
            </xsl:for-each>
        </tr>
        <!--
        <tr id="headerrow3">
            <th colspan="2" class="always-visible">
                <span class="header-text"><xsl:value-of select="$group6"/></span>
                <xsl:call-template name="stem-header">
                    <xsl:with-param name="header" select="$group6"/>
                </xsl:call-template>                
            </th>        
            <xsl:for-each select="$headerrow1">
                <xsl:sort select="@order" data-type="number"/>               
                <xsl:for-each select="$headerrow2">
                    <xsl:sort select="@order" data-type="number"/>
                    <xsl:for-each select="$headerrow3">
                        <xsl:sort select="@order" data-type="number"/>
                        <th>
                            <span class="header-text" ><xsl:value-of select="."/></span>
                            <xsl:apply-templates select="."/>                        
                        </th>
                    </xsl:for-each>
                </xsl:for-each>
            </xsl:for-each>
        </tr>
        -->
        
    </xsl:template>
    
    <!-- template to produce header for stem header row -->
    <xsl:template name="stem-header">
        <xsl:param name="header"/>
        <xsl:if test="$header='decl'">
            <br/><span class="header-text">stem</span>
        </xsl:if>
    </xsl:template>
    
    <!-- template to produce data for stem header row -->
    <xsl:template name="stem-data" match="order-item[@attname='decl']">        
        <br/>
        <xsl:variable name="thisdecl" select="text()"/>
        <xsl:value-of select="/infl-data/stem-table/stem[@decl=$thisdecl]"/>
        <xsl:call-template name="add-footnote">
            <xsl:with-param name="item" select="."/>
        </xsl:call-template>                
    </xsl:template>
    
    <xsl:template name="no-sub" match="order-item">
        <xsl:call-template name="add-footnote">
            <xsl:with-param name="item" select="."/>
        </xsl:call-template>        
    </xsl:template>
    
    <!-- template to produce colgroups for the table columns -->
    <xsl:template name="colgroups">
        <xsl:param name="headerrow1"/>
        <xsl:param name="headerrow2"/>
        <xsl:param name="headerrow3"/>
        <xsl:variable name="row2count" select="count($headerrow2)"/>
        <xsl:variable name="row3count" select="count($headerrow3)"/>
        <colgroup class="leftheader">
            <col realIndex="0"/>
            <col realIndex="1"/>
        </colgroup>
        <xsl:for-each select="$headerrow1">
            <xsl:variable name="row1pos" select="position()-1"/>            
            <colgroup class="header1">              
                <xsl:for-each select="$headerrow2">
                    <xsl:variable name="row2pos" select="position()-1"/>
                    <xsl:for-each select="$headerrow3">
                        <xsl:variable name="row3pos" select="position()-1"/>
                        <xsl:variable name="index" 
                            select="($row1pos * $row3count * $row2count) + 
                                    ($row2pos * $row3count) + position() + 1"/>
                            <col class="header3col" realIndex="{$index}" 
                                row1pos="{$row1pos}"
                                row2pos="{$row2pos}"
                                row3pos="{$row3pos}"/>
                    </xsl:for-each>
                </xsl:for-each>
            </colgroup>
        </xsl:for-each>       
    </xsl:template>
    
    <xsl:template name="headerrow">
        <xsl:param name="headerrow1"/>
        <xsl:param name="headerrow2"/>
        <xsl:param name="headerrow3"/>
        <xsl:variable name="row2count" select="count($headerrow2)"/>
        <xsl:for-each select="$headerrow1">
                <xsl:for-each select="$headerrow2">
                    <xsl:for-each select="$headerrow3">
                        <td>&#160;</td>
                    </xsl:for-each>
                </xsl:for-each>
        </xsl:for-each>       
    </xsl:template>
    
    <xsl:template name="add-footnote">
        <xsl:param name="item"/>
        <xsl:if test="$item/@footnote">
            <xsl:call-template name="footnote-tokens">
                <xsl:with-param name="list" select="$item/@footnote"/>
                <xsl:with-param name="delimiter" select="','"/>
            </xsl:call-template>   
        </xsl:if>
    </xsl:template>    

    <xsl:template name="add-dialect">
        <xsl:param name="item"/>
        <xsl:if test="$item/@dialects">
            <a href="#dialect" class="footnote">D</a>
            <span class="footnote-text"><xsl:value-of select="$item/@dialects"/></span>
            <xsl:if test="$item/@footnote">
                <span class="footnote-delimiter">,</span>
            </xsl:if>
        </xsl:if>
    </xsl:template>    
    
    
    <xsl:template name="check_infl_sets">
        <xsl:param name="current_data"/>
        <xsl:variable name="matches">
            <xsl:for-each select="$selected_endings//div[@class='alph-infl-set' and 
                ../div[@class='alph-dict']/span[(@class='alph-conj') and (@context = $current_data/@conj)]]
                ">
                <xsl:for-each select="div[@class='alph-infl']">
                    <xsl:call-template name="find_infl_match">
                        <xsl:with-param name="current_data" select="$current_data"/>
                        <xsl:with-param name="filtered_data" select="(.)"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:for-each>    
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="contains($matches,'1')">
                1
            </xsl:when>
            <xsl:otherwise>
                0
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="find_infl_match">
        <xsl:param name="current_data"/>
        <xsl:param name="filtered_data"/>
        <xsl:param name="att_pos" select="0"/>
        <xsl:variable name="num_atts" select="count($current_data/@*)"/>
        <xsl:choose> 
            <xsl:when test="$att_pos = $num_atts">
                <!-- if we have tested all the possible attributes return the match count-->
                <xsl:value-of select="count($filtered_data)"/>
            </xsl:when>
            <xsl:when test="($att_pos &lt; $num_atts) and $filtered_data">
                <!-- variables are: voice, mood, tense, num, person, and case -->
                <!-- only try match if current conjugation data element has the attribute -->
                <xsl:for-each select="$current_data/@*">
                    <xsl:if test="position() = $att_pos + 1">
                        <xsl:variable name="att_name" select="name()"/>
                                <xsl:variable name="class_name">
                                    <xsl:value-of select="concat('alph-',$att_name)"/>        
                                </xsl:variable>
                                <xsl:variable name="latest_data"
                                    select="$filtered_data[
                                    ((span[@class=$class_name]/text() = $current_data/@*[local-name(.)=$att_name])
                                    or
                                    (span[@class=$class_name]/@context = $current_data/@*[local-name(.)=$att_name])
                                    or
                                    
                                    ($att_name='case' and substring-before(span[@class=$class_name]/@context,'-') = $current_data/@*[local-name(.)=$att_name])
                                 )]"/>
                                <xsl:call-template name="find_infl_match">
                                    <xsl:with-param name="current_data" select="$current_data"/>
                                    <xsl:with-param name="filtered_data" 
                                        select="$latest_data"/>
                                    <xsl:with-param name="att_pos" select="$att_pos+1"/>                           
                                </xsl:call-template>                                                                        
                    </xsl:if>
                </xsl:for-each>                
            </xsl:when>
            <xsl:otherwise>0</xsl:otherwise>
        </xsl:choose>
    </xsl:template>    
    
    <xsl:template name="footnote-tokens">
        <xsl:param name="list" />
        <xsl:param name="delimiter" />
        <xsl:variable name="newlist">
            <xsl:choose>
                <xsl:when test="contains($list, $delimiter)"><xsl:value-of select="normalize-space($list)" /></xsl:when>
                <xsl:otherwise><xsl:value-of select="concat(normalize-space($list), $delimiter)"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="first" select="substring-before($newlist, $delimiter)" />
        <xsl:variable name="remaining" select="substring-after($newlist, $delimiter)" />
        <xsl:variable name="num" select="substring-after($first,'-')"/>
        <a href="#{$first}" class="footnote"><xsl:value-of select="$num"/></a>
        <span class="footnote-text"><xsl:apply-templates select="key('footnotes',$first)"/></span>
        <xsl:if test="$remaining">
            <span class="footnote-delimiter">,</span>
            <xsl:call-template name="footnote-tokens">
                <xsl:with-param name="list" select="$remaining" />
                <xsl:with-param name="delimiter"><xsl:value-of select="$delimiter"/></xsl:with-param>
            </xsl:call-template>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="reflink">
        <a href="{@xlink:href}" class="alph-reflink"><xsl:value-of select="."/></a>
    </xsl:template>
    
</xsl:stylesheet>