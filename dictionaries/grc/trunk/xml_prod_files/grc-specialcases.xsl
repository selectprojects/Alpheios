<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

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

  <!--
    Special cases

    These are sets (typically 2, but possibly more) of lemmas that cannot be
    distinguished from each other after application of the uni-strip template
    (removal of vowel length diacritics, diaereses, and capitalization).
    We remove these when looking up lemmas in the lexica because their usage
    among lexica and text is inconsistent.

    The sets are derived by running every lemma in the respective lexicons
    through the stripping operation and finding any lemmas that appear more than
    once.

    The id attribute on each table can be used at run-time to select the
    appropriate set of lemmas.

    Note: The lemmas in the table are stripped, so that only one entry is
    required for each set.

    Note: If a special case ends in 1, it should also be listed without the 1,
    since some transforms repeat lemmas ending in 1 with the 1 removed.
    If several lemmas ending in 1 conflict, they will also conflict with the 1
    removed.
  -->
  <xsl:variable name="special-cases">
    <!-- Autenrieth Homeric Dictionary -->
    <table id="grc-aut">
      <case lemma="αἰγίλιψ"/>
      <case lemma="αἰγιαλός"/>
      <case lemma="αἰνόθεν"/>
      <case lemma="αἴθρη"/>
      <case lemma="αἴθων"/>
      <case lemma="αἵμων"/>
      <case lemma="βῆσσα"/>
      <case lemma="γραῖα"/>
      <case lemma="δα"/>
      <case lemma="δαίς"/>
      <case lemma="δόλιος"/>
      <case lemma="δῆλος"/>
      <case lemma="δῖος"/>
      <case lemma="εὔμηλος"/>
      <case lemma="εὖρος"/>
      <case lemma="θάλεια"/>
      <case lemma="θρύον"/>
      <case lemma="κάρ"/>
      <case lemma="καλήτωρ"/>
      <case lemma="κελάδων"/>
      <case lemma="κοίρανος"/>
      <case lemma="κρείων"/>
      <case lemma="κῆρ"/>
      <case lemma="μάκαρ"/>
      <case lemma="μέδων"/>
      <case lemma="μέλας"/>
      <case lemma="μέρμερος"/>
      <case lemma="μέροψ"/>
      <case lemma="μήστωρ"/>
      <case lemma="νήριτος"/>
      <case lemma="νημερτής"/>
      <case lemma="νοήμων"/>
      <case lemma="νύμφη"/>
      <case lemma="οἶνοψ"/>
      <case lemma="παιήων"/>
      <case lemma="παρθένιος"/>
      <case lemma="ποδάρκης"/>
      <case lemma="πολίτης"/>
      <case lemma="πολύδωρος"/>
      <case lemma="πολύμηλος"/>
      <case lemma="πολύφημος"/>
      <case lemma="πρόμαχος"/>
      <case lemma="πυλάρτης"/>
      <case lemma="πύλος"/>
      <case lemma="σκῶλος"/>
      <case lemma="σχοῖνος"/>
      <case lemma="σῶκος"/>
      <case lemma="τάφος"/>
      <case lemma="τέκτων"/>
      <case lemma="τελαμών"/>
      <case lemma="φαέθων"/>
      <case lemma="φαίδιμος"/>
      <case lemma="φοῖνιξ"/>
      <case lemma="φύλακος"/>
      <case lemma="χάρις"/>
      <case lemma="χίμαιρα"/>
      <case lemma="χαλκίς"/>
      <case lemma="χείρων"/>
      <case lemma="ἀγήνωρ"/>
      <case lemma="ἀγαπήνωρ"/>
      <case lemma="ἀγλαίη"/>
      <case lemma="ἀγχίαλος"/>
      <case lemma="ἀκάμας"/>
      <case lemma="ἀμφίαλος"/>
      <case lemma="ἀμφότερος"/>
      <case lemma="ἀρείων"/>
      <case lemma="ἀρηίθοος"/>
      <case lemma="ἄγριος"/>
      <case lemma="ἄδμητος"/>
      <case lemma="ἄλκιμος"/>
      <case lemma="ἄξυλος"/>
      <case lemma="ἄρητος"/>
      <case lemma="ἅλιος"/>
      <case lemma="ἐπίστροφος"/>
      <case lemma="ἐχέφρων"/>
      <case lemma="ἥβη"/>
      <case lemma="ἦνοψ"/>
      <case lemma="ἱππόδαμος"/>
      <case lemma="ἱππόμαχος"/>
      <case lemma="ἶσος"/>
      <case lemma="ὄρμενος"/>
      <case lemma="ὄσσα"/>
      <case lemma="ὕλη"/>
      <case lemma="ὠκύαλος"/>
      <case lemma="ὦψ"/>
      <case lemma="ῥέα"/>
      <case lemma="ῥηξήνωρ"/>
    </table>

    <!-- LSJ -->
    <table id="grc-lsj">
      <case lemma="βύνη"/>
      <case lemma="βώμιος"/>
      <case lemma="γευστός"/>
      <case lemma="δάν"/>
      <case lemma="δαμία"/>
      <case lemma="δήν"/>
      <case lemma="δῆλος"/>
      <case lemma="δίς"/>
      <case lemma="δῖος"/>
      <case lemma="δῖος1"/>
      <case lemma="εὖρος"/>
      <case lemma="εὐσέβεια"/>
      <case lemma="θήρα"/>
      <case lemma="θρᾷττα"/>
      <case lemma="κάδμος"/>
      <case lemma="κάρνειος"/>
      <case lemma="κάστωρ"/>
      <case lemma="καρπάσιον"/>
      <case lemma="καρύινος"/>
      <case lemma="κίρκη"/>
      <case lemma="κόλχος"/>
      <case lemma="κρήτη"/>
      <case lemma="κρόνος"/>
      <case lemma="κύπριος"/>
      <case lemma="κύπρος"/>
      <case lemma="κῦρος"/>
      <case lemma="κυβέλη"/>
      <case lemma="κώρυκος"/>
      <case lemma="κωρυκίς"/>
      <case lemma="λ"/>
      <case lemma="λάμια"/>
      <case lemma="λάρτιος"/>
      <case lemma="λίνδος"/>
      <case lemma="λίνος"/>
      <case lemma="λύκιος"/>
      <case lemma="μαῖα"/>
      <case lemma="μίτρα"/>
      <case lemma="μόριος"/>
      <case lemma="νάιος"/>
      <case lemma="νέαιρα"/>
      <case lemma="νεμέσιον"/>
      <case lemma="πάν"/>
      <case lemma="πάνορμος"/>
      <case lemma="παρθένος"/>
      <case lemma="περσέπολις"/>
      <case lemma="πλάτων"/>
      <case lemma="πολιάς"/>
      <case lemma="πύλος"/>
      <case lemma="σάραπις"/>
      <case lemma="σαβάζω"/>
      <case lemma="σήρ"/>
      <case lemma="σηστός"/>
      <case lemma="σκῦρος"/>
      <case lemma="σμύρνα"/>
      <case lemma="σπάρτη"/>
      <case lemma="σπανός"/>
      <case lemma="συβαρίζω"/>
      <case lemma="συρίζω"/>
      <case lemma="τ"/>
      <case lemma="χείμερος"/>
      <case lemma="χείρων"/>
      <case lemma="χειμάζω"/>
      <case lemma="χωρισμός"/>
      <case lemma="ψ"/>
    </table>
    
    <!-- Middle Liddell -->
    <table id="grc-ml">
      <case lemma="αἴγειος"/>
      <case lemma="βρόμιος"/>
      <case lemma="δίς"/>
      <case lemma="δῆλος"/>
      <case lemma="εὖρος"/>
      <case lemma="κάστωρ"/>
      <case lemma="κώρυκος"/>
      <case lemma="κῦρος"/>
      <case lemma="μίτρα"/>
      <case lemma="μαῖα"/>
      <case lemma="μηλίς"/>
      <case lemma="μῆδος"/>
      <case lemma="πάνορμος"/>
      <case lemma="πάρος"/>
      <case lemma="προμήθεια"/>
      <case lemma="πύλος"/>
      <case lemma="σμυρναῖος"/>
      <case lemma="σμύρνα"/>
      <case lemma="σπάρτη"/>
      <case lemma="στησίχορος"/>
      <case lemma="συρίζω"/>
      <case lemma="τυφώς"/>
      <case lemma="φοῖνιξ"/>
      <case lemma="χαλκίς"/>
      <case lemma="χείρων"/>
      <case lemma="χῶρος"/>
      <case lemma="ἀλήιος"/>
      <case lemma="ἑστία"/>
      <case lemma="ἔπειμι"/>
      <case lemma="ἔργω"/>
      <case lemma="ἰταλός"/>
      <case lemma="ἰώ"/>
      <case lemma="ἴδη"/>
      <case lemma="ὅμηρος"/>
      <case lemma="ὑάκινθος"/>
      <case lemma="ῥέα"/>
    </table>
  </xsl:variable>
</xsl:stylesheet>