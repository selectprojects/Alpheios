<?xml version="1.0" encoding="UTF-8"?>
<!-- transforms the results of morphology analysis from alph-aramorph to unicode, including stripping the lemma sense 
       TODO - we should put the sense in a separate attribute so that it can be used for matching  and other analyses -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:include href="arabic-uni-util.xsl"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="@*[not((local-name(.) = 'lang') and ((.) = 'ara'))]|node()">        
        <xsl:copy>
            <xsl:apply-templates select="@*[not((local-name(.) = 'lang') and ((.) = 'ar' or (.)='ara'))]|node()"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="text()[ancestor-or-self::*[@*[local-name(.)='lang' and((.) = 'ar' or (.)='ara')]]]">
        <!-- strip sense indication if requested -->
        <xsl:variable name="text">
            <xsl:call-template name="strip-trailing">
                <xsl:with-param name="a_in" select="."/>
                <xsl:with-param name="a_toStrip" select="'0123456789_'"/>
            </xsl:call-template>        
        </xsl:variable>
        <xsl:call-template name="ara-buckwalter-to-uni">
            <xsl:with-param name="a_in" select="$text"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template match="xml:lang"/>
    
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
