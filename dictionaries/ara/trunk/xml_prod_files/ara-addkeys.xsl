<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

  <!--
  Copyright 2008-2010 Cantus Foundation
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
    Stylesheet to add keys to short definitions file for Arabic lexicon
  -->

  <xsl:include href="ara-uni-util.xsl"/>

  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- handle nodes -->
  <xsl:template match="node()">
    <xsl:choose>
      <!-- if it has a name, it's an element -->
      <xsl:when test="local-name()">
        <!-- copy node -->
        <xsl:copy>
          <!-- if lemma, add keys -->
          <xsl:if test="local-name() = 'lemma'">
            <!-- key1 = original lemma -->
            <xsl:variable name="key1" select="."/>
            <xsl:attribute name="key1" select="$key1"/>

            <!-- key2 = key1 with tanwin removed -->
            <xsl:variable name="key2">
              <xsl:call-template name="ara-uni-strip">
                <xsl:with-param name="a_in" select="$key1"/>
                <xsl:with-param name="a_toDrop" select="'tanwin'"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$key2 != $key1">
              <xsl:attribute name="key2" select="$key2"/>
            </xsl:if>

            <!-- key3 = key2 with hamzas removed -->
            <xsl:variable name="key3">
              <xsl:call-template name="ara-uni-strip">
                <xsl:with-param name="a_in" select="$key2"/>
                <xsl:with-param name="a_toDrop" select="'hamza'"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$key3 != $key2">
              <xsl:attribute name="key3" select="$key3"/>
            </xsl:if>

            <!-- key4 = key3 with harakat removed -->
            <xsl:variable name="key4">
              <xsl:call-template name="ara-uni-strip">
                <xsl:with-param name="a_in" select="$key3"/>
                <xsl:with-param name="a_toDrop" select="'harakat'"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$key4 != $key3">
              <xsl:attribute name="key4" select="$key4"/>
            </xsl:if>

            <!-- key5 = key4 with shadda removed -->
            <xsl:variable name="key5">
              <xsl:call-template name="ara-uni-strip">
                <xsl:with-param name="a_in" select="$key4"/>
                <xsl:with-param name="a_toDrop" select="'shadda'"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:if test="$key5 != $key4">
              <xsl:attribute name="key5" select="$key5"/>
            </xsl:if>
          </xsl:if>
          <!-- call recursively -->
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:when>

      <!-- if no name, it's text -->
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- handle attributes -->
  <xsl:template match="@*">
    <xsl:copy/>
  </xsl:template>

</xsl:stylesheet>
