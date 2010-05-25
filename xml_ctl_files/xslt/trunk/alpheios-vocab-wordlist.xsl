<?xml version="1.0" encoding="UTF-8"?>
<!--
    Copyright 2008-2009 Cantus Foundation
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
    Transforms an Alpheios Vocabulary List from TEI5 XML to HTML     
-->

<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0">
    <xsl:param name="e_sort"/>
    <xsl:template match="/">
        <html>
            <head></head>
            <body>
                <div id="alpheios-wordlist">
                    <div class="navigation">
                        <xsl:apply-templates select="//tei:ptr[starts-with(@type,'paging')]"/>
                    </div>
                    <div class="header">
                        <div class="lemma">Lemmas</div>
                        <div class="forms">Forms</div>                        
                    </div>
                    <xsl:choose>
                        <xsl:when test="$e_sort='alpha'">
                            <xsl:for-each select="//tei:entry">
                                <xsl:sort select="tei:form[@type='lemma']/text()" data-type="text" order="ascending"/>
                                <xsl:apply-templates select="."/>
                            </xsl:for-each>        
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:for-each select="//tei:entry">                                
                                <xsl:apply-templates select="."/>
                            </xsl:for-each>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>                                
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="tei:entry">
        <xsl:variable name="lang">
            <xsl:choose>
                <xsl:when test="attribute::xml:lang"><xsl:value-of select="attribute::xml:lang"/></xsl:when>            
                <xsl:otherwise><xsl:value-of select="@lang"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>                   
        <div class="entry">
            <div class="lemma">
            <xsl:element name="input">
                <xsl:attribute name="type">checkbox</xsl:attribute>
                <xsl:if test="tei:form[@type='lemma']/@rend='learned'">
                    <xsl:attribute name="checked">checked</xsl:attribute>    
                </xsl:if>                    
            </xsl:element>            
            <span lang="{$lang}"><xsl:value-of select="tei:form[@type='lemma']"/></span>
            </div>
            <div class="forms">
                <xsl:for-each select="tei:form[@type='inflection']">
                    <div class="form">         
                        <xsl:element name="input">
                            <xsl:attribute name="type">checkbox</xsl:attribute>
                            <xsl:if test="@rend='learned'">
                                <xsl:attribute name="checked">checked</xsl:attribute>    
                            </xsl:if>                    
                        </xsl:element>
                        <span lang="{$lang}"><xsl:value-of select="."/></span>
                    </div>          
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:ptr[starts-with(@type,'paging')]">
        <xsl:variable name="type_text" select="substring-after(@type,':')"/>
        <a href="{@target}" class="{@type}" title="{$type_text}"><xsl:value-of select="$type_text"/></a>
    </xsl:template>
    
</xsl:stylesheet>