<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
 <xsl:output method="text"/>
  <xsl:include href="/work/xml_ctl_files/xslt/trunk/uni2betacode.xsl"/>
 <xsl:param name="e_uni2beta" />
 <xsl:param name="e_docId" select="''"/>
   <xsl:template match="/">
    <xsl:variable name="urn_base" select="concat('urn:cts:',$e_docId,':')"/>
    <xsl:for-each select="//div1">
     <xsl:variable name="part" select="@n"/>
     <xsl:for-each select="//wd">             
       <xsl:variable name="word" select="text()"/>
       <xsl:variable name="subpart" select="parent::node()/@n"/>
       <xsl:variable name="position" select="count(preceding-sibling::wd[text() = $word]) + 1"/>
       <xsl:variable name="urn" select="concat($urn_base,$part,'.', $subpart,':',$word,'[',$position, ']')"/>
      <xsl:variable name="transformed">
       <xsl:choose>
        <xsl:when test="$e_uni2beta">
         <xsl:call-template name="uni-to-beta"><xsl:with-param name="a_in" select="."/></xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
         <xsl:value-of select="."/>
        </xsl:otherwise>
       </xsl:choose>
      </xsl:variable>
      <xsl:value-of select="$urn"/>,<xsl:value-of select="."/>,<xsl:value-of select="$transformed"/><xsl:text>       
</xsl:text>       
     </xsl:for-each> 
    </xsl:for-each>    
   </xsl:template>
</xsl:stylesheet>