<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
    xmlns:prdf="http://www.perseus.org/meta/perseus.rdfs#"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:dctype="http://purl.org/dc/dcmitype/"
    xmlns:perseus="http://www.perseus.org/meta/perseus.rdfs#"
    xmlns:persq="http://www.perseus.org/meta/persq.rdfs#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:tufts="http://www.tufts.edu/"
    xmlns="http://www.tei-c.org/ns/1.0"
    >
    <xsl:variable name="lang" select="rdf:RDF/prdf:metadata/dc:language"/>
    <xsl:variable name="docId" select="rdf:RDF/prdf:metadata/prdf:TextbookVocab/@id"/>
    <xsl:output indent="yes" media-type="text/xml"/>
    <xsl:include href="file:///c:/work/xml_ctl_files/xslt/trunk/arabic-uni-util.xsl"/>
    
    <xsl:template match="rdf:RDF">       
        <TEI xmlns="http://www.tei-c.org/ns/1.0"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.tei-c.org/ns/1.0 http://www.tei-c.org/release/xml/tei/custom/schema/xsd/tei_dictionaries.xsd">
            <teiHeader>
                <fileDesc>
                    <titleStmt><title><xsl:value-of select="prdf:metadata/dc:title"/></title></titleStmt>    
                    <publicationStmt><date><xsl:value-of select="prdf:metadata/dc:date"/></date></publicationStmt>
                    <sourceDesc><p><xsl:value-of select="prdf:metadata/dc:creator"/></p></sourceDesc>                                            
                </fileDesc>
            </teiHeader> 
            <text xml:lang="{$lang}">
                <body>
                    <xsl:apply-templates select="prdf:section"/>
                </body>
            </text>
        </TEI>
    </xsl:template>    
    
    <xsl:template match="prdf:entry">
        <xsl:variable name="id">
            <xsl:value-of select="$docId"/>_<xsl:value-of select="parent::*/@n"/>_<xsl:value-of select="position()"/>
        </xsl:variable>
        <entry xml:lang="{$lang}" n="{$id}">
            <xsl:apply-templates/>
        </entry>
    </xsl:template>                    
    
    <xsl:template match="prdf:lemma">
        
        <xsl:variable name="stripped">
            <xsl:call-template name="strip-trailing">
                <xsl:with-param name="a_in" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="sense" select="substring-after(.,$stripped)"/>
        <xsl:if test="$sense">
            <sense n="{$sense}"/>
        </xsl:if>
        <form type="lemma" xml:lang="{$lang}">
            <xsl:call-template name="ara-buckwalter-to-uni">
                <xsl:with-param name="a_in" select="$stripped"/>                
            </xsl:call-template></form>
    </xsl:template>    
    
    <xsl:template match="prdf:orth">
        <xsl:variable name="stripped">
            <xsl:call-template name="strip-trailing">
                <xsl:with-param name="a_in" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <form type="inflection" xml:lang="{$lang}">
            <xsl:call-template name="ara-buckwalter-to-uni">
                <xsl:with-param name="a_in" select="$stripped"/>                
            </xsl:call-template>                        
        </form>
    </xsl:template>    
    
    <xsl:template match="dc:*|dcterms:*"/>
    
    <!-- strip trailing characters from input -->
    <!-- default is to strip trailing digits -->
    <xsl:template name="strip-trailing">
        <xsl:param name="a_in"/>
        <xsl:param name="a_toStrip" select="'0123456789'"/>
        
        <xsl:variable name="lastChar"
            select="substring($a_in, string-length($a_in))"/>
        
        <xsl:choose>
            <!-- if empty input or last character is not in list -->
            <xsl:when test="translate($lastChar, $a_toStrip, '') = $lastChar">
                <!-- we're done - return input -->
                <xsl:value-of select="$a_in"/>
            </xsl:when>
            <!-- if last character is in list -->
            <xsl:otherwise>
                <!-- drop it and strip remaining (leading) part -->
                <xsl:call-template name="strip-trailing">
                    <xsl:with-param name="a_in"
                        select="substring($a_in, 1, string-length($a_in) - 1)"/>
                    <xsl:with-param name="a_toStrip" select="$a_toStrip"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
        
    
</xsl:stylesheet>
