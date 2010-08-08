<?xml version="1.0" encoding="UTF-8"?>
<!-- driver for tokenize.xsl wraptokens function, passing in text split on spaces -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:include href="tokenize.xsl"/>
    
    <xsl:param name="e_lang"/>
    <xsl:template match="/">     
        <xsl:for-each select="tokenize(.,'\s+')">            
            <xsl:variable name="startPos" select="position()"/>
            <xsl:call-template name="wraptokens">
                <xsl:with-param name="a_parentId" select="'1'"/>
                <xsl:with-param name="a_startPos" select="$startPos"/>
                <xsl:with-param name="a_text" select="current()"/>
                <xsl:with-param name="a_lang" select="$e_lang"/>
            </xsl:call-template>            
        </xsl:for-each>                
    </xsl:template>
    
</xsl:stylesheet>
