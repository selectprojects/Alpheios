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
    Transforms a TEI list to  XHTML for display as a Table of Contents for an Alpheios Enhanced Text Display     
-->

<xsl:stylesheet     
        xmlns="http://www.w3.org/1999/xhtml"
        exclude-result-prefixes="tei"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
        xmlns:tei="http://www.tei-c.org/ns/1.0">
        <xsl:include href="alpheios-tei.xsl"/>
        <xsl:output
            method="xml"
            doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
            indent="yes"/>
            
        <xsl:template match="/tei:TEI">
            <xsl:variable name="title">
                <xsl:call-template name="generateAlpheiosTitle">
                     <xsl:with-param name="htmlTitlePrefix"/>   
                </xsl:call-template>
            </xsl:variable>
            <html>
                <head>
                    <title><xsl:value-of select="$title"/></title>                    
                    <xsl:call-template name="cssHook"/>
                    <xsl:call-template name="javascriptHook"/>                    
                </head>
                <body>
                    <xsl:call-template name="generateAlpheiosTitleHtml"/>
                    <div id="toc" class="alpheios-ignore">
                        <xsl:call-template name="toc">
                            <xsl:with-param name="a_tocBody" select="tei:TEI/tei:text/tei:front/tei:div[@type='contents']"></xsl:with-param>
                        </xsl:call-template>
                    </div>
                </body>
            </html>
        </xsl:template>
        
        <xsl:template name="toc">
            <xsl:param name="a_tocBody"/>
            <xsl:apply-templates/>
        </xsl:template>
        
        <xsl:template match="tei:list">            
            <ul><xsl:apply-templates/></ul>
        </xsl:template>
        
        <xsl:template match="tei:item">
            <xsl:element name="li">
                <xsl:choose>
                    <xsl:when test="count(tei:ptr[@rend='text']) > 0">
                        <xsl:attribute name="class">tocitem</xsl:attribute>
                        <xsl:variable name="url">
                            <xsl:value-of select="tei:ptr[@rend='text']/@target"/>
                        </xsl:variable>
                        <a class="alpheios-toc-link" href="{$url}">
                            <xsl:value-of select="normalize-space(text())"/></a>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="class">tochead</xsl:attribute>
                        <xsl:attribute name="href"><xsl:value-of select="tei:ptr[@rend='toc']/@target"/></xsl:attribute>
                        <xsl:value-of select="normalize-space(text())"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="tei:list">
                    <xsl:apply-templates select="tei:list"/>
                </xsl:if>
            </xsl:element>
        </xsl:template>
    
        <xsl:template name="cssHook">
            <link type="text/css" rel="stylesheet" href="../css/alpheios-toc.css"/>        
        </xsl:template>
    
    <xsl:template name="javascriptHook">            
            <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.js"></script>
            <script type="text/javascript" src="../script/alpheios-toc.js"></script>
            <script type="text/javascript">
                // document ready function
                $(function(){
                    alpheiosTocReady()
                });
            </script>           
    </xsl:template>
        
    <xsl:template match="tei:teiHeader"/>        
 </xsl:stylesheet>