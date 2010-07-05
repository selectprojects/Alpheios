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
    Transforms an Alpheios Vocabulary List from TEI5 XML to HTML     
-->

<xsl:stylesheet     
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0">

    <xsl:template match="/">
        <xsl:variable name="vocab_lang" select="//tei:text/@*[local-name(.) = 'lang']"/>
        <html>
            <head>
                <link rel="stylesheet" type="text/css" href="../css/alpheios-vocab.css"/>  
                <script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1/jquery.js"></script>
                <script type="text/javascript" src="../script/alpheios-vocab.js"></script>                
            </head>
            <body>
                <div>                
                    <xsl:if test="//tei:fileDesc/tei:notesStmt"><div class="notes"><xsl:value-of select="//tei:fileDesc/tei:notesStmt"/></div></xsl:if>
                <div class="alpheios-toolbar"><button class="alpheios-toolbar-scanwords">Check Wordlist</button></div>
                <div class="alpheios-trigger-hint alpheios-hint"></div>
                  <div class="nav">
                        <xsl:apply-templates select="//tei:ptr[starts-with(@type,'paging')]"/>
                  </div>
                </div>
                <div id="alpheios-vocablist" class="alpheios-enabled-text" xml:lang="{$vocab_lang}">
                    <div class="header">
                        <div class="lemma">Lemmas</div>
                        <div class="forms">Forms</div>                        
                     </div>
                    <xsl:for-each select="//tei:entry[tei:form[@type='lemma']]">                        
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                    <div class="nav">
                        <xsl:apply-templates select="//tei:ptr[starts-with(@type,'paging')]"/>
                    </div>
                </div>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="tei:entry">
        <xsl:variable name="checked">
            
        </xsl:variable>
        <div class="entry">
            <div class="lemma">
                <span class="alpheios-word" lang="{tei:form[@type='lemma']/@lang}"><xsl:value-of select="tei:form[@type='lemma']"/></span>
                <span dir="rtl" class="count">(<xsl:value-of select="tei:form[@type='lemma']/@count"/>)</span>
            </div>
            <div class="forms">
                <xsl:for-each select="tei:form[@type='inflection']">
                    <xsl:variable name="ptrs">
                        
                    </xsl:variable>
                    <div class="form">                        
                        <span class="alpheios-word" lang="{@lang}"><xsl:value-of select="text()"/></span><span dir="rtl" class="count">(<xsl:value-of select="@count"/>)</span>
                        <xsl:if test="tei:ptr[not(starts-with(@type,'paging'))]">
                          <div class="toggle collapsed alpheios-ignore"><span lang="en" class="toggle-text collapsed">Hide</span><span lang="en" class="toggle-text">Show...</span>
                                <xsl:apply-templates select="tei:ptr"/>
                            </div>
                        </xsl:if>
                    </div>          
                </xsl:for-each>
            </div>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:ptr[not(starts-with(@type,'paging'))]">
        <div class="urn"><a href="{@target}" target="_blank"><xsl:value-of select="."/></a></div>
    </xsl:template>
    
    <xsl:template match="tei:ptr[starts-with(@type,'paging')]">
        <xsl:variable name="type_text" select="substring-after(@type,':')"/>
        <a href="{@target}" class="{@type}" title="{$type_text}"><xsl:value-of select="$type_text"/></a>
    </xsl:template>
</xsl:stylesheet>
