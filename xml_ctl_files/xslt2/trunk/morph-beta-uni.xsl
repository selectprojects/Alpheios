<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    <xsl:include href="beta2unicode.xsl"/>
    <xsl:strip-space elements="*"/>
    <xsl:template match="@*[not((local-name(.) = 'lang') and ((.) = 'grc-x-beta'))]|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*[not((local-name(.) = 'lang') and ((.) = 'grc-x-beta'))]|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()[ancestor-or-self::*[@xml:lang='grc-x-beta']]">
        <xsl:call-template name="beta-to-uni">
            <xsl:with-param name="a_in" select="."/>
        </xsl:call-template>
    </xsl:template>
    <xsl:template match="xml:lang"/>
</xsl:stylesheet>