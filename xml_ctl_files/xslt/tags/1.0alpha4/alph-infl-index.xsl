<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="tei"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0">

  <xsl:output
    method="xml"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    indent="yes"/>

  <xsl:template match="/">
    <html>
      <head>
        <title><xsl:value-of select="normalize-space(tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt)"/></title>
        <link type="text/css" rel="stylesheet" href="chrome://alpheios/skin/alph-infl-index.css"/>
      </head>
      <body>
        <div id="alph-infl-index">
          <xsl:call-template name="toc">
            <xsl:with-param name="a_tocBody" select="tei:TEI/tei:text/tei:front/tei:div[@type='contents']"></xsl:with-param>
          </xsl:call-template>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="toc">
    <xsl:param name="a_tocBody"/>
    <h1><xsl:value-of select="$a_tocBody/tei:head"/></h1>
     <xsl:call-template name="toc-section">
       <xsl:with-param name="a_list" select="$a_tocBody/tei:list"/>
     </xsl:call-template>
  </xsl:template>

  <xsl:template name="toc-section">
    <xsl:param name="a_list"/>
    <ul><xsl:apply-templates select="$a_list/tei:item"/></ul>
  </xsl:template>

  <xsl:template match="tei:item">
    <xsl:element name="li">
      <xsl:choose>
        <xsl:when test="count(tei:ptr) > 0">
          <xsl:attribute name="class">tocitem</xsl:attribute>
          <xsl:variable name="url">
            <xsl:value-of select="tei:ptr/@target"/>
          </xsl:variable>
          <a class="alph-infl-index-link" href="{$url}">
            <xsl:value-of select="normalize-space(text())"/></a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">tochead</xsl:attribute>
          <xsl:value-of select="normalize-space(text())"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="tei:list">
        <xsl:call-template name="toc-section">
          <xsl:with-param name="a_list" select="tei:list"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>
