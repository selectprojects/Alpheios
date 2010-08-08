<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:include href="arabic-uni-util.xsl"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="text()">
        <xsl:call-template name="ara-uni-to-buckwalter">
            <xsl:with-param name="a_in" select="."/>
        </xsl:call-template>
    </xsl:template>
        
</xsl:stylesheet>
