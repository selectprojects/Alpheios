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
    Transforms an TEI XML to  XHTML (Alpheios Enhanced Text Display)     
-->


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns="http://www.w3.org/1999/xhtml">
    <xsl:output method="html" indent="yes"/>

    <xsl:param name="doclang"/>
    <xsl:param name="alpheiosPedagogicalText" select="'false'"/>
     <xsl:param name="alpheiosSiteBaseUrl" select="'http://alpheios.net/alpheios-texts'"/>
     <xsl:param name="alpheiosTreebankDiagramUrl"/>
     <xsl:param name="alpheiosTreebankUrl"/>
      <xsl:param name="htmlTitlePrefix" select="'Alpheios:'"/>
     <xsl:param name="cssFile" select="'http://alpheios.net/alpheios-texts/css/alpheios-text.css'"/>
     <xsl:param name="highlightWord"/>
    
    <xsl:template match="/">
        <html xml:lang="{$doclang}">
            
            <head>
                <xsl:call-template name="cssHook"/>
                <xsl:call-template name="javascriptHook"/>
                <xsl:call-template name="alpheios-metadata"/>
                <title><xsl:call-template name="generateAlpheiosTitle"></xsl:call-template></title>
            </head>
            <body>
                <xsl:call-template name="bodyHook"/>
                <xsl:apply-templates select="TEI.2/text/body/*"/>
                <xsl:call-template name="perseus_footer"/>
                <xsl:call-template name="copyrightStatement"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template name="perseus_footer">
        <div class="alpheios-ignore">
        <xsl:call-template name="funder"></xsl:call-template>
        <xsl:call-template name="publicationStatement"/>
        <!-- need to add correction level, method, source, etc ? -->
        </div>
    </xsl:template>
        
    <xsl:template name="funder">
        <xsl:if test="//titleStmt/funder">
            <div class="perseus-funder">
                <xsl:value-of select="//titleStmt/funder"/><xsl:text> provided support for entering this text.</xsl:text>
            </div>
        </xsl:if>
    </xsl:template>
        
    <xsl:template name="publicationStatement">
        <xsl:if test="//publicationStmt/publisher/text() or //publicationStmt/pubPlace/text() or //publicationStmt/authority/text()">
    	<div class="perseus-publication">XML for this text provided by
    		<span class="publisher"><xsl:value-of select="//publicationStmt/publisher"/></span>
    		<span class="pubPlace"><xsl:value-of select="//publicationStmt/pubPlace"/></span>
    		<span class="authority"><xsl:value-of select="//publicationStmt/authority"/></span>
    	</div>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="copyrightStatement">
        <xsl:call-template name="source-desc"/>
        <div class="rights_info">
    	    <xsl:call-template name="rights_cc"/>
        </div>
    </xsl:template>
    
    <xsl:template name="rights_cc">
              <p class="cc_rights">
              <!--Creative Commons License-->
                This work is licensed under a
                <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/us/">Creative Commons Attribution-Noncommercial-Share Alike 3.0 United States License</a>.
                <!--/Creative Commons License-->
            </p>
    </xsl:template>

    <xsl:template name="bodyHook">
        <xsl:comment>Start Alpheios Header</xsl:comment>
        <xsl:variable name="alpheios-header">
            <xsl:call-template name="alpheios-pedagogical-header"/>
        </xsl:variable>
        <xsl:copy-of select="$alpheios-header"/>
    </xsl:template>

<xsl:template match="milestone">
    <xsl:variable name="idstring">
        <xsl:if test="@n">
            <xsl:text>m</xsl:text>
            <xsl:value-of select="@n"/>
        </xsl:if>
    </xsl:variable>
    <div class="milestone {@unit}" id="{$idstring}"/>
</xsl:template>

<xsl:template match="div1|div2|div3|div4|div5">
    <div class="@type">
        <xsl:apply-templates/>
    </div>
</xsl:template>
    
<xsl:template match="l|p">    
        <div class="l">
            <xsl:if test="@n">
                <div class="linenum"><xsl:value-of select="@n"/></div>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
</xsl:template>
    
<xsl:template match="wd">
    <xsl:variable name="wordId">
        <xsl:call-template name="ref_to_id">
            <xsl:with-param name="list" select="@n"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="nrefList">
        <xsl:call-template name="ref_to_id">
            <xsl:with-param name="list" select="@nrefs"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:call-template name="separate_words">
        <xsl:with-param name="id_list" select="$wordId"/>
        <xsl:with-param name="nrefs" select="$nrefList"/>
        <xsl:with-param name="tbrefs" select="@tbrefs"/>
        <xsl:with-param name="tbref" select="@tbref"/>
    </xsl:call-template>
</xsl:template>
    
 <xsl:template name="separate_words">
     <xsl:param name="id_list"/>
     <xsl:param name="nrefs"/>
     <xsl:param name="tbrefs"/>
     <xsl:param name="tbref"/>
     <xsl:param name="delimiter" select="' '"/>
     <xsl:variable name="newlist">
         <xsl:choose>
             <xsl:when test="contains($id_list, $delimiter)"><xsl:value-of select="normalize-space($id_list)" /></xsl:when>
             <xsl:otherwise><xsl:value-of select="concat(normalize-space($id_list), $delimiter)"/></xsl:otherwise>
         </xsl:choose>
     </xsl:variable>
     <xsl:variable name="first" select="substring-before($newlist, $delimiter)" />
     <xsl:variable name="remaining" select="substring-after($newlist, $delimiter)" />
     <xsl:variable name="highlightId">
         <xsl:call-template name="ref_to_id">
             <xsl:with-param name="list" select="$highlightWord"/>
         </xsl:call-template>
     </xsl:variable>
     <xsl:variable name="highlight">
         <xsl:if test="$first = $highlightId">
             alpheios-highlighted-word
         </xsl:if>
     </xsl:variable>
     <xsl:element name="span">
         <xsl:attribute name="class">alpheios-aligned-word <xsl:value-of select="$highlight"/></xsl:attribute>                
         <xsl:attribute name="id"><xsl:value-of select="$first"/></xsl:attribute>
         <xsl:attribute name="nrefs"><xsl:value-of select="$nrefs"/></xsl:attribute>
         <xsl:choose>
             <xsl:when test="@tbrefs">
                 <xsl:attribute name="tbrefs"><xsl:value-of select="@tbrefs"/></xsl:attribute>
             </xsl:when>
             <xsl:when test="@tbref">
                 <xsl:attribute name="tbref"><xsl:value-of select="@tbref"/></xsl:attribute>
             </xsl:when>
         </xsl:choose>
         <xsl:apply-templates/>
     </xsl:element>
     <xsl:if test="$remaining">
         <xsl:value-of select="$delimiter"/>
         <xsl:call-template name="separate_words">
             <xsl:with-param name="id_list" select="$remaining" />
             <xsl:with-param name="nrefs" select="$nrefs"/>
             <xsl:with-param name="tbrefs" select="$tbrefs"/>
             <xsl:with-param name="tbref" select="$tbref"/>
             <xsl:with-param name="delimiter"><xsl:value-of select="$delimiter"/></xsl:with-param>
         </xsl:call-template>
     </xsl:if>
</xsl:template>
    
   <xsl:template name="ref_to_id">
        <xsl:param name="list" />
        <xsl:param name="delimiter" select="' '"/>
       <xsl:if test="$list">
        <xsl:variable name="newlist">
            <xsl:choose>
                <xsl:when test="contains($list, $delimiter)"><xsl:value-of select="normalize-space($list)" /></xsl:when>
                <xsl:otherwise><xsl:value-of select="concat(normalize-space($list), $delimiter)"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="first" select="substring-before($newlist, $delimiter)" />
        <xsl:variable name="remaining" select="substring-after($newlist, $delimiter)" />
        <xsl:variable name="sentence" select="substring-before($first,'-')"/>
        <xsl:variable name="word" select="substring-after($first,'-')"/>
        <xsl:text>s</xsl:text><xsl:value-of select="$sentence"/><xsl:text>_w</xsl:text><xsl:value-of select="$word"/>
        <xsl:if test="$remaining">
            <xsl:value-of select="$delimiter"/>
            <xsl:call-template name="ref_to_id">
                <xsl:with-param name="list" select="$remaining" />
                <xsl:with-param name="delimiter"><xsl:value-of select="$delimiter"/></xsl:with-param>
            </xsl:call-template>
        </xsl:if>
       </xsl:if>
   </xsl:template>
    
    <xsl:template name="alpheios-metadata">
        <xsl:if test="$alpheiosPedagogicalText = 'true'">
            <meta name="alpheios-pedagogical-text" content="true"/>
            <xsl:if test="$alpheiosTreebankUrl != ''">
                <meta name="alpheios-treebank-url" content="{$alpheiosTreebankUrl}"/>
            </xsl:if>
            <xsl:if test="$alpheiosTreebankDiagramUrl != ''">
                <meta name="alpheios-treebank-diagram-url"  
                            content="{$alpheiosTreebankDiagramUrl}"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="alpheios-pedagogical-header">
        <xsl:if test="$alpheiosPedagogicalText = 'true'">
        <div class="alpheios-ignore">
            <div id="alph-page-header">
                <div class="alpheios-version-text"><a href="http://alpheios.net/content/release-notes" title="View Release Notes" target="_blank">Alpha Version</a></div>
                <a class="alpheios-logo" href="http://alpheios.net" alt="Alpheios">
                    <img src="{$alpheiosSiteBaseUrl}/img/alpheios.png"/></a>
            </div>
            <div id="alph-toolbar" class="alpheios-toolbar">
                <div id="alph-toolbar-main">
                    <ul class="sf-menu">
                        <li class="current alpheios-toolbar-level-label"><a href="#">Mode</a></li>
                        <li class="current alpheios-toolbar-level learner" alpheios-value="learner"><a href="#"><img src="{$alpheiosSiteBaseUrl}/img/readinglearning_centerline.gif"/></a></li>
                        <li class="current alpheios-toolbar-level reader"  alpheios-value="reader"><a href="#">&#160;</a></li>
                        <li class="current alpheios-toolbar-translation"><a href="#">Translation</a></li>
                        <li class="current alpheios-toolbar-inflect"><a href="#">Inflection<br/>Tables</a></li>
                        <li class="current alpheios-toolbar-grammar"><a href="#">Grammar</a></li>
                        <li class="current alpheios-toolbar-usertools"><a href="#">User Tools</a><ul>
                            <li class="current alpheios-toolbar-user-diagram"><a  href="#">My Diagrams</a></li>
                            <li class="current alpheios-toolbar-vocab"><a  href="#">My Vocabulary</a></li>                            
                        </ul>
                        </li>                        
                        <li class="current alpheios-toolbar-options"><a href="#">Options</a></li>                                               
                        <li class="current alpheios-toolbar-help-menu"><a href="#">Help</a>
                            <ul>
                                <li class="current alpheios-toolbar-help"><a href="#">User Guide</a></li>
                                <li class="current alpheios-toolbar-feedback"><a href="#">Send Feedback</a></li>
                                <li class="current alpheios-toolbar-about"><a href="#">About</a></li>
                            </ul>
                        </li>
                    </ul>
                </div>
            </div>
            <div class="alpheios-trigger-hint alpheios-hint"></div>
            <div id="alpheios-current-level"><span alpheios-value="reader">Reading Mode</span><span alpheios-value="learner">Quiz Mode</span></div>
            <ul id="alpheios-install-links">
                <caption>Please install the following Firefox Extensions required for optimal use of this site:</caption>
            </ul>
            <xsl:element name="br">
                <xsl:attribute name="clear">all</xsl:attribute>
            </xsl:element>
            <div id="header">
                <div id="header_text">
                    <h1>
                        <xsl:if test="/TEI.2/teiHeader/fileDesc/titleStmt/author/text()">
                            <span class="author"><xsl:value-of select="/TEI.2/teiHeader/fileDesc/titleStmt/author"/>, </span>
                        </xsl:if>
                        <xsl:variable name="myName">
                            <xsl:value-of select="local-name(.)"/>
                        </xsl:variable>
                         <span class="title">
                             <xsl:variable name="title" select="/TEI.2/teiHeader/fileDesc/titleStmt/title"></xsl:variable>
                             <xsl:choose>
                                 <xsl:when test="contains($title,'.')">
                                     <xsl:value-of select="substring-before($title,'.')"/>
                                 </xsl:when>
                                 <xsl:otherwise> 
                                     <xsl:value-of select="$title"/>
                                     <xsl:if test="$myName='div2' and @n"><span class="sectionid"> (<xsl:value-of select="@n"/>)</span></xsl:if>
                                     <xsl:if test="$myName='div2' and @alpheios-subtitle"><span class="subtitle"> - <xsl:value-of select="@alpheios-subtitle"/></span></xsl:if>
                                     <xsl:if test="$myName='div2' and head"><span class="subtitle"> - <xsl:value-of select="head"/></span></xsl:if>
                                 </xsl:otherwise>
                             </xsl:choose>
                         </span>
                        <xsl:if test="/TEI.2/teiHeader/fileDesc/titleStmt/author/text()">
                             <a id="alph-citation-links" href="#citation" title="Citation"><img id="alph-citation-icon" src="{$alpheiosSiteBaseUrl}/img/citation_static.gif" alt="Citation"/></a>
                         </xsl:if>
                    </h1>
                </div>
            </div>
            <br/>
            <div id="alpheios-interlinear-parent">
                <input class="alpheios-interlinear-toggle" id="alpheios-interlinear-toggle" type="checkbox"/>
                <label for="alpheios-interlinear-toggle">Show Interlinear Translation</label>
            </div>
            </div>
        <xsl:comment>End Alpheios Header</xsl:comment>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="generateAlpheiosTitle">
        <xsl:variable name="myName">
            <xsl:value-of select="local-name(.)"/>
        </xsl:variable>
        <xsl:value-of select="$htmlTitlePrefix"/>
        <xsl:if test="/TEI.2/teiHeader/fileDesc/titleStmt/author/text()">
            <xsl:value-of select="/TEI.2/teiHeader/fileDesc/titleStmt/author"/>
            <xsl:text>, </xsl:text>
        </xsl:if>
            <xsl:variable name="title" select="/TEI.2/teiHeader/fileDesc/titleStmt/title"></xsl:variable>
            <xsl:choose>
                <xsl:when test="contains($title,'.')">
                    <xsl:value-of select="substring-before($title,'.')"/>
                </xsl:when>
                <xsl:otherwise> 
                    <xsl:value-of select="$title"/>
                    <xsl:if test="$myName='div2' and @n">
                        (<xsl:value-of select="@n"/>)
                    </xsl:if>
                    <xsl:if test="$myName='div2' and @alpheios-subtitle">
                        - <xsl:value-of select="@alpheios-subtitle"/>
                    </xsl:if>
                    <xsl:text> </xsl:text>
                </xsl:otherwise>
            </xsl:choose>
    </xsl:template>
    
    <xsl:template name="cssHook">
        <xsl:if test="$cssFile">
            <link rel="stylesheet" type="text/css" href="{$cssFile}"/>
        </xsl:if>
        <xsl:if test="$alpheiosPedagogicalText='true'">
            <link rel="stylesheet" type="text/css" href="{concat($alpheiosSiteBaseUrl,'/site_menus/css/superfish.css')}"/>
            <link rel="shortcut icon" type="image/x-icon" href="{concat($alpheiosSiteBaseUrl,'/img/alpheios_16.png')}" />
            <style type="text/css">
                .alpheios-highlighted-word { font-weight:bold; text-decoration: underline; }
            </style>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="javascriptHook">
        <xsl:if test="$alpheiosPedagogicalText='true'">
            <script type="text/javascript" src="{concat($alpheiosSiteBaseUrl, '/site_menus/js/jquery-1.2.6.min.js')}"></script>
            <script type="text/javascript" src="{concat($alpheiosSiteBaseUrl,'/site_menus/js/hoverIntent.js')}"></script>
            <script type="text/javascript" src="{concat($alpheiosSiteBaseUrl,'/site_menus/js/superfish.js')}"></script>
            <script type="text/javascript" src="{concat($alpheiosSiteBaseUrl,'/js/alpheios-text.js')}"></script>
            <script type="text/javascript">
                // document ready function
                $(function(){
                    alpheios_ready()
                });
            </script>
         </xsl:if>   
    </xsl:template>
    
    <!-- taken from perseus'  tei2p4.xsl -->
    <xsl:template name="source-desc">
        <xsl:variable name="sourceText">
            <xsl:for-each select="//sourceDesc/descendant::*[name(.) != 'author']/text()">
                <xsl:variable name="normalized" select="normalize-space(.)" />
                <xsl:value-of select="$normalized" />
                <!-- Print a period after each text node, unless the current node
                    ends in a period -->
                <xsl:if test="$normalized != '' and not(contains(substring($normalized, string-length($normalized)), '.'))">
                    <xsl:text>.</xsl:text>
                </xsl:if>
                <xsl:if test="position() != last()">
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
        <xsl:if test="string-length(normalize-space($sourceText)) &gt; 0">
            <span class="source-desc"><xsl:value-of select="$sourceText" /></span>
        </xsl:if>        
    </xsl:template>
    
    <xsl:template match="*"/>
</xsl:stylesheet>