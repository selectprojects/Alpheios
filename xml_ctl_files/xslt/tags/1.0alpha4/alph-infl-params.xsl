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
    Parameters for inflection table transformation and matching
  -->
  <!-- all parameters may be supplied in transformation -->

  <!-- row groupings -->
  <!-- default order is Number, Case -->
  <xsl:param name="e_group1" select="'num'"/>
  <xsl:param name="e_group2" select="'case'"/>
  <xsl:param name="e_group3" />

  <!-- column groupings -->
  <!-- default order is Declension, Gender, Type-->
  <xsl:param name="e_group4" select="'decl'"/>
  <xsl:param name="e_group5" select="'gend'"/>
  <xsl:param name="e_group6" select="'type'"/>

  <!-- selected form (optional) -->
  <xsl:param name="e_form" />

  <!-- select specific inflection ending(s) (optional) -->
  <xsl:param name="e_selectedEndings" select="/.." />


  <!-- optional parameter to indicate matching should be done on full form rather than
     term suffix (default false)
  -->
  <xsl:param name="e_matchForm" select="false()"/>

  <!-- normalize greek text ? (default false -->
  <!-- if true, strips vowel lengths and acute and grave accents, and
     normalizes to precombined unicode -->
  <xsl:param name="e_normalizeGreek" select="false()"/>

  <!-- transliterate unicode in the ending tables before matching? (default false) -->
  <xsl:param name="e_translitEndingTableMatch" select="false()"/>

  <!-- part of speech used for matching (default noun) -->
  <xsl:param name="e_matchPofs" select="'noun'"/>

  <!-- Flag to request that endings be deduped according to a specific
    set of attributes. The only supported value currently is 'case-num-gend'
  -->
  <xsl:param name="e_dedupeBy" select="''"/>

  <!-- Flag to request that only the endings which match the form exactly be
    included in the table
  -->
  <xsl:param name="e_showOnlyMatches" select="false()"/>

  <!-- skip the enclosing html and body tags -->
  <xsl:param name="e_fragment" />

  <!-- instead of displaying inflections, display a link to another location -->
  <xsl:param name="e_linkContent"/>
</xsl:stylesheet>
