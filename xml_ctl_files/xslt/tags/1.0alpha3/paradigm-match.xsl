<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <xsl:template name="check_att">
        <xsl:param name="att_name"/>
        <xsl:param name="data"/>
        <xsl:if test="$att_name = 'role'">1</xsl:if>
    </xsl:template>
    
    <xsl:template name="check_infl_constraint">
        <xsl:param name="infl"/>
        <xsl:param name="constraint_data"/>
        <xsl:variable name="infl_id" select="generate-id($infl)"/>
        <xsl:if test="count($constraint_data[@infl_id=$infl_id])=0">1</xsl:if>
    </xsl:template>


</xsl:stylesheet>