<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:template name="check-att">
    <xsl:param name="a_attName"/>
    <xsl:param name="a_data"/>
    <xsl:if test="$a_attName = 'role'">1</xsl:if>
  </xsl:template>

  <xsl:template name="check-infl-constraint">
    <xsl:param name="a_infl"/>
    <xsl:param name="a_constraintData"/>
    <xsl:variable name="inflId" select="generate-id($a_infl)"/>
    <xsl:if test="count($a_constraintData[@infl_id=$inflId])=0">1</xsl:if>
  </xsl:template>

</xsl:stylesheet>
