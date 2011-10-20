<?xml version="1.0" encoding="UTF-8"?>
<!-- groups results of tan:getWords by form, lemma and sense -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:forms = "http://alpheios.net/namespaces/forms">
    <xsl:output media-type="text/xml" indent="yes"/>
    <xsl:template match="//words">        
        <lemmas>
            <xsl:for-each-group select="lemma" group-by="@form">                
                    <xsl:variable name="form" select="current-grouping-key()"/>                                        
                    <xsl:for-each-group select="current-group()" group-by="@lemma">
                        <xsl:variable name="lemma" select="current-grouping-key()"/>
                        <xsl:for-each-group select="current-group()" group-by="@sense">
                            <lemma>
                                <xsl:attribute name="count" select="count(current-group()//forms:urn)"/>
                                <xsl:attribute name="lemma" select="$lemma"/>
                                <xsl:attribute name="form" select="$form"/>
                                <xsl:attribute name="sense" select="current-grouping-key()"/>
                                <xsl:copy-of select="current-group()[1]/@lang"/>
                                <xsl:copy-of select="current-group()/forms:urn"/>                             
                            </lemma>                                        
                        </xsl:for-each-group>                                
                    </xsl:for-each-group>        
                </xsl:for-each-group>
        </lemmas>
    </xsl:template>
</xsl:stylesheet>