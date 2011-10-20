<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
    xmlns:forms = "http://alpheios.net/namespaces/forms">
    <xsl:output media-type="text/xml" indent="yes"/>
    <xsl:template match="/">        
        <lemmas>
                <xsl:for-each-group select="lemmas/lemma" group-by="concat(@lemma,@form,@sense)">
                    <xsl:variable name="urns" select="distinct-values(current-group()/forms:urn)"/>
                    <lemma lemma="{current-group()[1]/@lemma}" 
                        form="{current-group()[1]/@form}" 
                        sense="{current-group()[1]/@sense}"
                        lang="{current-group()[1]/@lang}"
                        count="{count($urns)}">
                        <xsl:for-each select="distinct-values(current-group()/forms:urn)">
                            <forms:urn><xsl:value-of select="."/></forms:urn>
                        </xsl:for-each>
                    </lemma>    
                </xsl:for-each-group>       
        </lemmas>
    </xsl:template>
</xsl:stylesheet>
