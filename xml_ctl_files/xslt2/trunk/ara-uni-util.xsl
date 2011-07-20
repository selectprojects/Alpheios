<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"                
                version="2.0">
  <!--
    Copyright 2009-2010 Cantus Foundation, The Alpheios Project, Ltd.
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

  <!-- Arabic utility routines -->

  <!--
   Arabic letters in Buckwalter transliteration and in Unicode
   Buckwalter's suggested XML-compatible alternatives for
     U+0623 (ALEF WITH HAMZA ABOVE) = O
     U+0624 (WAW WITH HAMZA ABOVE)  = W
     U+0625 (ALEF WITH HAMZA BELOW) = I
   are used for transliteration.
   Both alternatives (OWI or >&<) are recognized for Unicode production.
   U+06E1 (SMALL HIGH DOTLESS HEAD OF KHAH) is treated as sukun (U+0652).
  -->
  <xsl:variable name="s_araBuckwalter"
    >'|&gt;0&amp;W&lt;I}AbptvjHxd*rzs$SDTZEg_fqklmnhwYyFNKaui~oo`{PJVG</xsl:variable>
    <xsl:variable name="s_araUnicode"
    >&#x0621;&#x0622;&#x0623;&#x0623;&#x0624;&#x0624;&#x0625;&#x0625;&#x0626;&#x0627;&#x0628;&#x0629;&#x062A;&#x062B;&#x062C;&#x062D;&#x062E;&#x062F;&#x0630;&#x0631;&#x0632;&#x0633;&#x0634;&#x0635;&#x0636;&#x0637;&#x0638;&#x0639;&#x063A;&#x0640;&#x0641;&#x0642;&#x0643;&#x0644;&#x0645;&#x0646;&#x0647;&#x0648;&#x0649;&#x064A;&#x064B;&#x064C;&#x064D;&#x064E;&#x064F;&#x0650;&#x0651;&#x0652;&#x06E1;&#x0670;&#x0671;&#x067E;&#x0686;&#x06A4;&#x06AF;</xsl:variable>

  <!--
    Definitions of sets of diacritics
    <drop> = possible set to strip
      @name = name of operation
      @in = input pattern to translate
      @out = output pattern to translate
  -->
  <xsl:variable name="s_rawAraDiacritics">
    <drop-table>
      <drop name="tanwin" in="&#x064B;&#x064C;&#x064D;&#x0640;" out=""
        >Drop nunation/tanwin &amp; tatweel
        (FATHATAN, DAMMATAN, KASRATAN, TATWEEL)</drop>
      <drop name="hamza" in="&#x0622;&#x0623;&#x0625;"
        out="&#x0627;&#x0627;&#x0627;"
        >Drop hamzas (replace ALEF WITH MADDA ABOVE,
        ALEF WITH HAMZA ABOVE/BELOW with ALEF)</drop>
      <drop name="harakat" in="&#x064E;&#x064F;&#x0650;&#x0670;&#x0671;" out=""
        >Drop harakat (FATHA, DAMMA, KASRA, SUPERSCRIPT ALEF, ALEF WASLA)</drop>
      <drop name="shadda" in="&#x0651;" out="">Drop SHADDA</drop>
      <drop name="sukun" in="&#x0652;" out="">Drop SUKUN</drop>
      <drop name="alef" in="&#x0627;" out="">Drop ALEF</drop>
    </drop-table>
  </xsl:variable>
  <xsl:variable name="s_araDiacritics"
    select="$s_rawAraDiacritics/drop-table"/>

  <xsl:variable name="s_araDropAll">tanwin,hamza,harakat,shadda,sukun,alef</xsl:variable>
  
  <!--
    Translate Buckwalter transliteration to Unicode
    Parameters:
      $a_in         string to translate
      $a_depersify  remove Perseus variants

    Output:
      translated string
  -->
  <xsl:template name="ara-buckwalter-to-uni">
    <xsl:param name="a_in"/>
    <xsl:param name="a_depersify" select="false()"/>

    <xsl:choose>
      <!--
        If depersify, apply regular expressions to remove Perseus variants
        in Buckwalter transliteration.
        Regexes taken from Gabe Weaver's depersify.pl Perl script.
      -->
      <xsl:when test="$a_depersify">
        <!-- XSLT 1.0 
        <xsl:variable name="temp">
          <xsl:call-template name="replace-1.0">
            <xsl:with-param name="a_in" >
              <xsl:call-template name="replace-1.0">
                <xsl:with-param name="a_in">
                  <xsl:call-template name="replace-1.0">
                    <xsl:with-param name="a_in">
                      <xsl:call-template name="replace-1.0">
                        <xsl:with-param name="a_in">
                          <xsl:call-template name="replace-1.0">
                            <xsl:with-param name="a_in" select="$a_in"/>
                            <xsl:with-param name="a_pattern" select="'A='"/>
                            <xsl:with-param name="a_replace" select="'|'"/>
                          </xsl:call-template>
                        </xsl:with-param>
                        <xsl:with-param name="a_pattern" select="'A^'"/>
                        <xsl:with-param name="a_replace" select="'&gt;'"/>
                      </xsl:call-template>
                    </xsl:with-param>
                    <xsl:with-param name="a_pattern" select="'A_'"/>
                    <xsl:with-param name="a_replace" select="'&lt;'"/>
                  </xsl:call-template>
                </xsl:with-param>
                <xsl:with-param name="a_pattern" select="'w^'"/>
                <xsl:with-param name="a_replace" select="'&amp;'"/>
              </xsl:call-template>
            </xsl:with-param>
            <xsl:with-param name="a_pattern" select="'y^'"/>
            <xsl:with-param name="a_replace" select="'}'"/>
          </xsl:call-template>
        </xsl:variable>
        -->
        <!-- XSLT 2.0 -->
        <xsl:variable
          name="temp"
          select="replace(
                    replace(
                      replace(
                        replace(
                          replace($a_in, 'A=', '|'),
                          'A\^', '&gt;'),
                        'A_', '&lt;'),
                      'w\^', '&amp;'),
                    'y\^', '}')"/> 
        <xsl:value-of
          select="translate($temp, $s_araBuckwalter, $s_araUnicode)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of
          select="translate($a_in, $s_araBuckwalter, $s_araUnicode)"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

  <!--
    Translate Unicode to Buckwalter transliteration
    Parameters:
      $a_in         string to translate

    Output:
      translated string
  -->
  <xsl:template name="ara-uni-to-buckwalter">
    <xsl:param name="a_in"/>
    <xsl:value-of select="translate($a_in, $s_araUnicode, $s_araBuckwalter)"/>
  </xsl:template>

  <!--
    Strip diacritics
    Parameters:
      $a_in	              string to strip
      $a_toDrop           comma-separated list of what to drop

    Output:
      string with operations performed

    Options to drop are defined by $s_araDiacritics/drop/@name
  -->
  <xsl:template name="ara-uni-strip">
    <xsl:param name="a_in"/>
    <xsl:param name="a_toDrop"/>

    <!-- find out what to do first and what's left to do after -->
    <xsl:variable name="toDo">
      <xsl:choose>
        <xsl:when test="contains($a_toDrop, ',')">
          <xsl:value-of select="substring-before($a_toDrop, ',')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$a_toDrop"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="leftToDo">
      <xsl:value-of select="substring-after($a_toDrop, ',')"/>
    </xsl:variable>

    <!-- apply first operation -->
    <xsl:variable name="drop"
                  select="$s_araDiacritics/drop[@name = $toDo]"/>
    <xsl:variable name="temp">
      <xsl:choose>
        <xsl:when test="$drop">
          <xsl:value-of select="translate($a_in, $drop/@in, $drop/@out)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$a_in"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- if anything left to do, call recursively -->
    <xsl:choose>
      <xsl:when test="string-length($leftToDo) > 0">
        <xsl:call-template name="ara-uni-strip">
          <xsl:with-param name="a_in" select="$temp"/>
          <xsl:with-param name="a_toDrop" select="$leftToDo"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$temp"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    String replace (XSLT 1.0 compatible version of XSLT 2.0 function)
    Parameters:
      $a_in	              string to replace strings in
      $a_pattern          pattern to look for
      $a_replace          what to replace pattern with

    Output:
      string with instances of pattern replaced
  -->
  <xsl:template name="replace-1.0">
    <xsl:param name="a_in"/>
    <xsl:param name="a_pattern"/>
    <xsl:param name="a_replace"/>

    <xsl:choose>
      <!-- if pattern found -->
      <xsl:when test="contains($a_in, $a_pattern)">
        <!-- string before pattern -->
        <xsl:value-of select="substring-before($a_in, $a_pattern)"/>
        <!-- replacement for pattern -->
        <xsl:value-of select="$a_replace"/>
        <!-- recursively process rest of string -->
        <xsl:call-template name="replace-1.0">
          <xsl:with-param name="a_in"
                          select="substring-after($a_in, $a_pattern)"/>
          <xsl:with-param name="a_pattern" select="$a_pattern"/>
          <xsl:with-param name="a_replace" select="$a_replace"/>
        </xsl:call-template>
      </xsl:when>
      <!-- if pattern not found, just return input -->
      <xsl:otherwise>
        <xsl:value-of select="$a_in"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
