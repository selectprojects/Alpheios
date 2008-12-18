<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!--
  Copyright 2008 Cantus Foundation
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
      $input        Unicode input string to be converted
      $pending      betacode character waiting to be output
      $state        betacode diacritics associated with pending character
      $upper        Whether to output base characters in upper or lower case

    Output:
      $input transformed to equivalent betacode

    Betacode diacritics for a capital letter precede the base letter.
    Therefore, we must look ahead to find any trailing combining diacritics
    in the Unicode before we can properly output a capital letter.
  -->
  <xsl:template name="uni-to-beta">
    <xsl:param name="input"/>
    <xsl:param name="pending" select="''"/>
    <xsl:param name="state" select="''"/>
    <xsl:param name="upper" select="true()"/>

    <xsl:variable name="head" select="substring($input, 1, 1)"/>

    <xsl:choose>
      <!-- if no more input -->
      <xsl:when test="string-length($input) = 0">
        <!-- output last pending char -->
        <xsl:call-template name="output-beta-char">
          <xsl:with-param name="char" select="$pending"/>
          <xsl:with-param name="state" select="$state"/>
        </xsl:call-template>
      </xsl:when>

      <!-- if input starts with diacritic -->
      <xsl:when test="contains($uni-diacritics, $head) and ($head != ' ')">
        <!-- recurse with diacritic added to state -->
        <xsl:call-template name="uni-to-beta">
          <xsl:with-param name="input" select="substring($input, 2)"/>
          <xsl:with-param name="state">
            <xsl:call-template name="insert-diacritic">
              <xsl:with-param name="string" select="$state"/>
              <xsl:with-param name="char"
                select="translate($head, $uni-diacritics, $beta-diacritics)"/>
            </xsl:call-template>
          </xsl:with-param>
          <xsl:with-param name="pending" select="$pending"/>
          <xsl:with-param name="upper" select="$upper"/>
        </xsl:call-template>
      </xsl:when>

      <!-- if not a special char -->
      <xsl:otherwise>
        <!-- output pending char -->
        <xsl:call-template name="output-beta-char">
          <xsl:with-param name="char" select="$pending"/>
          <xsl:with-param name="state" select="$state"/>
        </xsl:call-template>

        <!-- look up unicode in table -->
        <xsl:variable name="beta">
          <xsl:apply-templates select="$beta-uni-table" mode="u2b">
            <xsl:with-param name="key" select="$head"/>
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
              <xsl:with-param name="input" select="substring($input, 2)"/>
              <xsl:with-param name="state" select="substring($beta, 2)"/>
              <xsl:with-param name="pending">
                <xsl:choose>
                  <xsl:when test="$upper">
                    <xsl:value-of
                      select="translate($base, $beta-lowers, $beta-uppers)"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$base"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:with-param>
              <xsl:with-param name="upper" select="$upper"/>
            </xsl:call-template>
          </xsl:when>

          <!-- otherwise, recurse with next character as pending -->
          <xsl:otherwise>
            <xsl:call-template name="uni-to-beta">
              <xsl:with-param name="input" select="substring($input, 2)"/>
              <xsl:with-param name="state" select="''"/>
              <xsl:with-param name="pending" select="$head"/>
              <xsl:with-param name="upper" select="$upper"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Output a single character with diacritics
    Parameters:
      $char         character to be output
      $state        diacritics associated with character
  -->
  <xsl:template name="output-beta-char">
    <xsl:param name="char"/>
    <xsl:param name="state"/>

    <xsl:choose>
      <!-- if capital letter -->
      <xsl:when test="substring($state, 1, 1) = '*'">
        <!-- output diacritics+base -->
        <xsl:value-of select="$state"/>
        <xsl:value-of select="$char"/>
      </xsl:when>

      <!-- if lower letter -->
      <xsl:otherwise>
        <!-- output base+diacritics -->
        <xsl:value-of select="$char"/>
        <xsl:value-of select="$state"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
