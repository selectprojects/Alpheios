<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!--
  Copyright 2008-2009 Cantus Foundation
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

  <xsl:import href="beta-uni-util.xsl"/>

  <!--
    Convert Unicode to Greek betacode
    Parameters:
      $a_in           Unicode input string to be converted
      $a_pending      betacode character waiting to be output
      $a_state        betacode diacritics associated with pending character
      $a_upper        Whether to output base characters in upper or lower case

    Output:
      $a_in transformed to equivalent betacode

    Betacode diacritics for a capital letter precede the base letter.
    Therefore, we must look ahead to find any trailing combining diacritics
    in the Unicode before we can properly output a capital letter.
  -->
  <xsl:template name="uni-to-beta">
    <xsl:param name="a_in"/>
    <xsl:param name="a_pending" select="''"/>
    <xsl:param name="a_state" select="''"/>
    <xsl:param name="a_upper" select="true()"/>

    <xsl:variable name="head" select="substring($a_in, 1, 1)"/>

    <xsl:choose>
      <!-- if no more input -->
      <xsl:when test="string-length($a_in) = 0">
        <!-- output last pending char -->
        <xsl:call-template name="output-beta-char">
          <xsl:with-param name="a_char" select="$a_pending"/>
          <xsl:with-param name="a_state" select="$a_state"/>
        </xsl:call-template>
      </xsl:when>

      <!-- if input starts with diacritic -->
      <xsl:when test="contains($s_uniDiacritics, $head) and ($head != ' ')">
        <!-- recurse with diacritic added to state -->
        <xsl:call-template name="uni-to-beta">
          <xsl:with-param name="a_in" select="substring($a_in, 2)"/>
          <xsl:with-param name="a_state">
            <xsl:call-template name="insert-diacritic">
              <xsl:with-param name="a_string" select="$a_state"/>
              <xsl:with-param name="a_char"
                select="translate($head, $s_uniDiacritics, $s_betaDiacritics)"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="a_pending" select="$a_pending"/>
          <xsl:with-param name="a_upper" select="$a_upper"/>
        </xsl:call-template>
      </xsl:when>

      <!-- if not a special char -->
      <xsl:otherwise>
        <!-- output pending char -->
        <xsl:call-template name="output-beta-char">
          <xsl:with-param name="a_char" select="$a_pending"/>
          <xsl:with-param name="a_state" select="$a_state"/>
        </xsl:call-template>

        <!-- look up unicode in table -->
        <xsl:variable name="beta">
          <xsl:apply-templates select="$s_betaUniTable" mode="u2b">
            <xsl:with-param name="a_key" select="$head"/>
          </xsl:apply-templates>
        </xsl:variable>

        <xsl:choose>
          <!-- if we found anything in lookup, use it -->
          <!-- Strings in lookup table are lowercase base character -->
          <!-- plus optional asterisk plus optional diacritics -->
          <xsl:when test="string-length($beta) > 0">
            <xsl:variable name="base" select="substring($beta, 1, 1)"/>

            <!-- recurse with base, in requested case, as pending character -->
            <xsl:call-template name="uni-to-beta">
              <xsl:with-param name="a_in" select="substring($a_in, 2)"/>
              <xsl:with-param name="a_state" select="substring($beta, 2)"/>
              <xsl:with-param name="a_pending">
                <xsl:choose>
                  <xsl:when test="$a_upper">
                    <xsl:value-of
                      select="translate($base, $s_betaLowers, $s_betaUppers)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$base"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
              <xsl:with-param name="a_upper" select="$a_upper"/>
            </xsl:call-template>
          </xsl:when>

          <!-- otherwise, recurse with next character as pending -->
          <xsl:otherwise>
            <xsl:call-template name="uni-to-beta">
              <xsl:with-param name="a_in" select="substring($a_in, 2)"/>
              <xsl:with-param name="a_state" select="''"/>
              <xsl:with-param name="a_pending" select="$head"/>
              <xsl:with-param name="a_upper" select="$a_upper"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Output a single character with diacritics
    Parameters:
      $a_char         character to be output
      $a_state        diacritics associated with character
  -->
  <xsl:template name="output-beta-char">
    <xsl:param name="a_char"/>
    <xsl:param name="a_state"/>

    <xsl:choose>
      <!-- if capital letter -->
      <xsl:when test="substring($a_state, 1, 1) = '*'">
        <!-- output diacritics+base -->
        <xsl:value-of select="$a_state"/>
        <xsl:value-of select="$a_char"/>
      </xsl:when>

      <!-- if lower letter -->
      <xsl:otherwise>
        <!-- output base+diacritics -->
        <xsl:value-of select="$a_char"/>
        <xsl:value-of select="$a_state"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
