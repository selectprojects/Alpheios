<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:import href="ascii-uni-util.xsl"/>

  <!--
      Convert Unicode to Transliterated Ascii
      Parameters:
        $input        Unicode input string to be converted
        $pending      ascii character waiting to be output

      Output:
        $input transformed to equivalent transliterated ascii  
  -->
  <xsl:template name="uni-to-ascii">
    <xsl:param name="input"/>
    <xsl:param name="pending" select="''"/>

    <xsl:variable name="head" select="substring($input, 1, 1)"/>

    <!-- output any pending chars -->
    <xsl:if test="string-length($pending) > 0">
      <xsl:value-of select="$pending"/>
    </xsl:if>
    
    <!-- if more input -->
    <xsl:if test="string-length($input) > 0">
    
	  <!-- look up unicode in table -->
	  <xsl:variable name="ascii">
	    <xsl:apply-templates select="$uni-ascii-table" mode="u2a">
	      <xsl:with-param name="key" select="$head"/>
	    </xsl:apply-templates>
	  </xsl:variable>
	
	  <xsl:variable name="new-pending">
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
        <xsl:with-param name="input" select="substring($input, 2)"/>
        <xsl:with-param name="pending" select="$new-pending"/>
      </xsl:call-template>
      
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
