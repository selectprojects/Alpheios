<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:output method="text"/>
  <xsl:include href="uni2betacode.xsl"/>
 <xsl:param name="e_uni2beta" />  
   <xsl:template match="/">
    <xsl:variable name="urn_base" select="concat('urn:cts:alpheios:forms.',/TEI.2/@id)"/>
    <xsl:for-each select="//wd">    
            <xsl:variable name="word" select="position()"/>
             <xsl:variable name="urn" select="concat($urn_base,':',$word)"/>
            <xsl:value-of select="$urn"/>,<xsl:value-of select="."/>,
            <xsl:choose>
             <xsl:when test="$e_uni2beta">
               <xsl:call-template name="uni-to-beta"><xsl:with-param name="a_in" select="."/></xsl:call-template>
             </xsl:when>
             <xsl:otherwise>
               <xsl:value-of select="."/>
             </xsl:otherwise>
            </xsl:choose>
            <xsl:text>
            </xsl:text>
    </xsl:for-each>
   </xsl:template>
</xsl:stylesheet>