<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:forms = "http://alpheios.net/namespaces/forms">
    <xsl:output media-type="text/xml" indent="yes"/>
    <xsl:template match="//words">        
        <words>
            <xsl:for-each-group select="lemma" group-adjacent="@lemma">
                <lemma>
                        <xsl:attribute name="lemma" select="current-grouping-key()"/>
                    <xsl:attribute name="count" select="count(current-group()//forms:urn)"/>
                    <xsl:copy-of select="current-group()/@lang"/>
                    <xsl:for-each-group select="current-group()" group-adjacent="@form">
                        <form>
                            <xsl:attribute name="count" select="count(current-group()//forms:urn)"/>
                            <xsl:attribute name="form" select="current-grouping-key()"/>
                            <xsl:copy-of select="current-group()/@lang"/>
                            <xsl:for-each select="current-group()">                                    
                                <xsl:copy-of select="forms:urn"/>                            
                            </xsl:for-each>
                        </form>                                        
                    </xsl:for-each-group>                
                </lemma>
            </xsl:for-each-group>        
        </words>
    </xsl:template>
</xsl:stylesheet>
