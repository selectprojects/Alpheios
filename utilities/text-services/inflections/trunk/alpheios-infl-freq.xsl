<?xml version="1.0" encoding="UTF-8"?>
<!--
    Copyright 2010 Cantus Foundation
    http://alpheios.net
    
    This file is part of Alpheios.
    
    Alpheios is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    
    Alpheios is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.    
-->

<!--
    Transforms an Alpheios Inflection Frequency List from to XHTML     
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:forms="http://alpheios.net/namespaces/forms">

    <xsl:variable name="total_count" select="count(//forms:urn)"/>
    
    <xsl:param name="e_sort">
        <xsl:choose>
            <xsl:when test="//forms:ending-set">ending</xsl:when>
            <xsl:otherwise>inflection</xsl:otherwise>
        </xsl:choose>
    </xsl:param>
    
    <xsl:template match="/">
        <html>
            <head>                
                <link type="text/css" rel="stylesheet" href="../css/alpheios-infl-freq.css"/>
                <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.js"></script>
                <script type="text/javascript" src="../script/alpheios-infl-freq.js"></script>
                <meta name="alpheios-docid" content="{/forms:endings/@docid}"></meta>
                <meta name="alpheios-lang" content="{/forms:endings/@lang}"></meta>
            </head>
            <title></title>
            <body>
                <div class="links">
                    <div class="doclink"><span class="caption">Part of Speech:</span>
                    <xsl:element name="select">
                        <xsl:attribute name="id">select-pofs</xsl:attribute>
                        
                        <xsl:for-each select="//forms:order-table/forms:order-item[@attname='pofs']">                                                 
                            <xsl:element name="option">
                                <xsl:if test='text() = /forms:endings/@pofs'>
                                    <xsl:attribute name="selected">selected</xsl:attribute>
                                </xsl:if>
                                <xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
                                <xsl:value-of select="."/>                        
                            </xsl:element>                        
                        </xsl:for-each>
                    </xsl:element>
                    </div>
                    <div class="doclink"><span class="caption">Sort by:</span>
                        <label>
                        <xsl:element name="input">
                            <xsl:attribute name="type">radio</xsl:attribute>
                            <xsl:attribute name="name">sort</xsl:attribute>
                            <xsl:attribute name="value">ending</xsl:attribute>
                            <xsl:attribute name="checked">checked</xsl:attribute>                        
                        </xsl:element>Ending
                        </label>
                        <label>
                        <xsl:element name="input">
                            <xsl:attribute name="type">radio</xsl:attribute>
                            <xsl:attribute name="name">sort</xsl:attribute>
                            <xsl:attribute name="value">inflection</xsl:attribute>                        
                        </xsl:element>Inflection
                        </label>
                            
                    </div>                                
                </div>            
                <div class="infl-table">
                    <xsl:call-template name="header"/>                                                
                    <xsl:choose>
                        <xsl:when test="$e_sort='ending'">
                            <xsl:for-each select="//forms:ending-set">
                                <xsl:sort select="@count" data-type="number" order="descending"/>
                                <xsl:apply-templates select="."/>
                            </xsl:for-each>                                        
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="//forms:infl-ending-set">
                                <xsl:sort select="@count" data-type="number" order="descending"/>
                                <xsl:apply-templates select="."/>
                            </xsl:for-each>                                        
                        </xsl:otherwise>
                    </xsl:choose>                                
                 </div>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="forms:infl-ending-set">
        <div class="row_group row">               
            <xsl:variable name="infl_ending_count" select="@count"/>
            <div class="infl-ending-set-count">(<xsl:value-of select="$infl_ending_count"/> of <xsl:value-of select="$total_count"/>)</div>
            <div class="column infl-ending-set">
                <xsl:for-each select="@*[not(local-name() = 'count')]">
                    <div class="infl-att" context="{local-name(.)}"><xsl:value-of select="."/></div>
                </xsl:for-each>                        
            </div>                                                
            <xsl:for-each select="descendant::forms:infl-ending">
                <xsl:sort select="@count" data-type="number" order="descending"/>
                <div class="row forms-all">                
                    <div class="column infl-ending"><xsl:apply-templates/></div>
                    <div class="column infl-ending-count"><xsl:value-of select="@count"/> of <xsl:value-of select="$infl_ending_count"/></div>
                    <div class="column ending-urn-set collapsed">    
                        <div class="toggle"><span class="toggle-text collapsed">Hide</span><span class="toggle-text">Show...</span></div>                         
                        <xsl:for-each select="forms:refs/forms:ptr">
                            <div class="urn"><a href="{@href}"><xsl:value-of select="forms:urn"/></a></div>
                        </xsl:for-each>
                    </div>
                </div>
            </xsl:for-each>
            
        </div>
    </xsl:template>
    
    <xsl:template match="forms:ending-set">
        <div class="row_group row">               
            <xsl:variable name="ending_count" select="@count"/>
            <div class="ending-count">(<xsl:value-of select="$ending_count"/> of <xsl:value-of select="$total_count"/>)</div>
            <div class="column infl-ending"><xsl:value-of select="forms:infl-ending"/></div>                                
            <div class="row forms-all">
                <xsl:for-each select="descendant::forms:infl-ending-set">
                    <xsl:sort select="@count" data-type="number" order="descending"/>
                    <div class="row infl-set">
                        <div class="column infl-att-set">                             
                            <xsl:for-each select="@*[not(local-name() = 'count')]">
                                <div class="infl-att" context="{local-name(.)}"><xsl:value-of select="."/></div>
                            </xsl:for-each>
                        </div>
                        <div class="column infl-set-count"><xsl:value-of select="@count"/> of <xsl:value-of select="$ending_count"/></div>                   
                        <div class="column ending-urn-set collapsed">    
                            <div class="toggle"><span class="toggle-text collapsed">Hide</span><span class="toggle-text">Show...</span></div>                         
                            <xsl:for-each select="forms:refs/forms:ptr">
                                <div class="urn"><a href="{@href}"><xsl:value-of select="forms:urn"/></a></div>
                            </xsl:for-each>
                        </div>
                    </div>
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="forms:infl-ending">
        <xsl:value-of select="."/>
    </xsl:template>
    
    <xsl:template match="forms:refs"/>
                    
    <xsl:template name="header">        
        <div class="row header1">
            <div class="ending-count">(Frequency)</div>
            <div class="column infl-ending header">
                <xsl:value-of select="
                    translate(substring(/forms:endings/@pofs,1,1),'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ')"
                /><xsl:value-of select="substring(/forms:endings/@pofs,2)"/> Ending</div>          
        </div>
        <xsl:variable name="sort_heading">
            <xsl:choose>
                <xsl:when test="$e_sort='ending'">Ending</xsl:when>
                <xsl:otherwise>Inflection</xsl:otherwise>
            </xsl:choose>
            
        </xsl:variable>
        <div class="row header-row header2 forms-all">
            <div class="column infl-att-set header"><xsl:value-of select="$sort_heading"/></div>
            <div class="column infl-set-count header">Frequency</div>
            <div class="column infl-urn-set header">Sources</div>
        </div>   
    </xsl:template>
</xsl:stylesheet>
