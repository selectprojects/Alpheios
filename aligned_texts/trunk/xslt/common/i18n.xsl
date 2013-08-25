<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet exclude-result-prefixes="xd tei fotex fo" version="1.0"
  xmlns:fo="http://www.w3.org/1999/XSL/Format"
  xmlns:fotex="http://www.tug.org/fotex" xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xd="http://www.pnp-software.com/XSLTdoc"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xd:doc type="stylesheet">
    <xd:short> TEI stylesheet definitions common for all of HTML, FO and LaTeX
      outputs </xd:short>
    <xd:detail> This library is free software; you can redistribute it and/or
      modify it under the terms of the GNU Lesser General Public License as
      published by the Free Software Foundation; either version 2.1 of the
      License, or (at your option) any later version. This library is
      distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
      without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
      PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
      details. You should have received a copy of the GNU Lesser General Public
      License along with this library; if not, write to the Free Software
      Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA </xd:detail>
    <xd:author>See AUTHORS</xd:author>
    <xd:cvsId>$Id: i18n.xsl,v 1.7 2007/10/31 10:25:20 sorin Exp $</xd:cvsId>
    <xd:copyright>2007, TEI Consortium</xd:copyright>
  </xd:doc>
  <xsl:key match="entry" name="KEYS" use="key"/>
  <xsl:param name="documentationLanguage">en</xsl:param>
  <xd:doc>
    <xd:short>[common] give language-specific version of a word or phrase</xd:short>
    <xd:param name="word">the word(s) to translate</xd:param>
    <xd:detail> </xd:detail>
  </xd:doc>
  <xsl:template name="i18n">
    <xsl:param name="word"/>
    <xsl:variable name="local">
      <xsl:call-template name="myi18n">
	<xsl:with-param name="word">
	  <xsl:value-of select="$word"/>
	</xsl:with-param>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
     <xsl:when test="string-length($local)&gt;0">
       <xsl:value-of select="$local"/>
     </xsl:when>
     <xsl:otherwise>
       <xsl:for-each select="document('../i18n.xml',document(''))">
	 <xsl:choose>
	   <xsl:when
	       test="key('KEYS',normalize-space($word))/text[@xml:lang=$documentationLanguage]">
	     <xsl:value-of
		 select="key('KEYS',normalize-space($word))/text[@xml:lang=$documentationLanguage]"/>
	   </xsl:when>
	   <xsl:otherwise>
	     <xsl:value-of select="$word"/>
	   </xsl:otherwise>
	 </xsl:choose>
       </xsl:for-each>
     </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xd:doc>
    <xd:short>[localisation] dummy template for overriding in a local system</xd:short>
    <xd:param name="word">the word(s) to translate</xd:param>
    <xd:detail> </xd:detail>
  </xd:doc>
  <xsl:template name="myi18n">
	<xsl:param name="word"/>
  </xsl:template>

  <xd:doc class="localisation" type="string"> The language to use when
    generating text (use ISO 2-letter codes)</xd:doc>
  <xsl:param name="lang">en</xsl:param>
  <xd:doc class="localisation">
    <xd:short>[common] Prefix text before an auto-generated table of contents </xd:short>
    <xd:detail> </xd:detail>
  </xd:doc>
  <xd:doc class="localisation" type="string"> The language the text is in
    (use ISO 2-letter codes)</xd:doc>
  <xsl:param name="doclang">en</xsl:param>
  <xd:doc class="localisation">
    <xd:short>[common] Prefix text before an auto-generated table of contents </xd:short>
    <xd:detail> </xd:detail>
  </xd:doc>
  <xsl:template name="contentsHeading">
    <xsl:call-template name="i18n">
      <xsl:with-param name="word">contentsHeading</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xd:doc class="localisation">
    <xd:short>[common] Title for "Contents"; by default uses language-specific
      lookup table.</xd:short>
    <xd:detail> </xd:detail>
  </xd:doc>
  <xsl:template name="contentsWord">
    <xsl:call-template name="i18n">
      <xsl:with-param name="word">contentsWord</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xd:doc class="localisation">
    <xd:short>[common] Title for "Feedback"</xd:short>
    <xd:detail> </xd:detail>
  </xd:doc>
  <xsl:template name="feedbackWords">
    <xsl:call-template name="i18n">
      <xsl:with-param name="word">feedbackWords</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  <xd:doc class="localisation">
    <xd:short>[common] Title for "Search"; by default uses language-specific
      lookup table. </xd:short>
    <xd:detail> </xd:detail>
  </xd:doc>
  <xsl:template name="searchWords">
    <xsl:call-template name="i18n">
      <xsl:with-param name="word">searchWords</xsl:with-param>
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>
