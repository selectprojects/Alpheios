<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="ascii-uni-util.xsl"/>

  <!--
      Convert Unicode to Transliterated Ascii
      Parameters:
        $a_in           Unicode input string to be converted
        $a_pending      ascii character waiting to be output

      Output:
        $a_in transformed to equivalent transliterated ascii
  -->
  <xsl:template name="uni-to-ascii">
    <xsl:param name="a_in"/>
    <xsl:param name="a_pending" select="''"/>

    <xsl:variable name="head" select="substring($a_in, 1, 1)"/>

    <!-- output any pending chars -->
    <xsl:if test="string-length($a_pending) > 0">
      <xsl:value-of select="$a_pending"/>
    </xsl:if>

    <!-- if more input -->
    <xsl:if test="string-length($a_in) > 0">

	  <!-- look up unicode in table -->
	  <xsl:variable name="ascii">
	    <xsl:apply-templates select="$s_uniAsciiTable" mode="u2a">
	      <xsl:with-param name="a_key" select="$head"/>
	    </xsl:apply-templates>
	  </xsl:variable>
	
	  <xsl:variable name="newPending">
	  	  <xsl:choose>
	  	  	  <!-- if we found anything in lookup, use it
	  	  	       otherwise just return as as -->
	  	  	<xsl:when test="string-length($ascii) > 0">
	  	  	  <xsl:value-of select="$ascii"/>
	  	  	</xsl:when>
	  	    <xsl:otherwise>
	  	  	    <xsl:value-of select="$head"/>
	  	    </xsl:otherwise>
	  	  </xsl:choose>
	  </xsl:variable>

      <xsl:call-template name="uni-to-ascii">
        <xsl:with-param name="a_in" select="substring($a_in, 2)"/>
        <xsl:with-param name="a_pending" select="$newPending"/>
      </xsl:call-template>

    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
