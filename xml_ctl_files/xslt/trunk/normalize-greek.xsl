<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <!--
        Copyright 2009 Cantus Foundation
        http://alpheios.net
        
        This file is part of Alpheios.
        
        Alpheios is free software: you can redistribute it and/or modify
        it under the terms of the GNU General Public License as published by
        the Free Software Foundation, either version 3 of the License, or
        (at your option) any later version.
        
        Alpheios is distributed in the hope that it will be useful,
        but WITHOUT ANY WARRANTY; without even the implied warranty of
        MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
        GNU General Public License for more details.
        
        You should have received a copy of the GNU General Public License
        along with this program.  If not, see <http://www.gnu.org/licenses/>.
    -->
    
    <!--
        Normalize Greek Unicode to precomposed/decomposed characters
        
        Parameters:
        $input        text to normalize
        $precomposed  whether to produce precomposed output (default=true)
        $partial      whether this is a partial word (default=false)
        (If true, do not use final sigma for last letter)
    -->
    <xsl:include href="uni2betacode.xsl"/>
    <xsl:include href="beta2unicode.xsl"/>
    
    <xsl:output method="text"/>
    
    
    <xsl:template name="normalize-greek">
        <xsl:param name="input"/>
        <xsl:param name="precomposed" select="true()"/>
        <xsl:param name="partial" select="false()"/>
        
        <xsl:call-template name="beta-to-uni">
            <xsl:with-param name="input">
                <xsl:call-template name="uni-to-beta">
                    <xsl:with-param name="input" select="$input"/>
                    <xsl:with-param name="upper" select="false()"/>
                </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="precomposed" select="$precomposed"/>
            <xsl:with-param name="partial" select="$partial"/>
        </xsl:call-template>
    </xsl:template>
    
</xsl:stylesheet>