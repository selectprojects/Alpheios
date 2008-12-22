(:
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
 :)

(:
  XQuery to extract short definitions from LSJ Greek lexicon

  Output is in form
  <entrylist>
    <entry id="lsj-id">
      <lemma>lemma</lemma>
      <meaning>definition</meaning>
    </entry>
    ...
  </entrylist.

  The list of invalid strings is derived mostly from the abbreviations
  found in the prefatory sections of LSJ.  These should not be considered
  definitions, even when they appear in a position that would otherwise
  seem to indicate they are.

  The list of corrections is mostly for common Greek words that have
  defective definitions according to the current algorithm.  This is a
  place for catch-all ad hoc corrections to be listed.

  The list of additions includes common lemmas returned by morpheus that
  do not appear in LSJ.  Therefore, these entries do not have id attributes.
 :)

(: wrap everything in <entrylist> :)
element entrylist
{

(: full list :)
let $letters :=
(
  "alpha", "beta", "chi", "delta", "epsilon", "eta", "gamma", "iota",
  "kappa", "koppa", "lambda", "mu", "nu", "omega", "omicron", "phi",
  "pi", "psi", "rho", "san", "sigma", "tau", "theta", "upsilon", "vau",
  "xi", "zeta"
)
(: test list :)
(: let $letters := ( "alpha" ) :)

let $docPrefix := "/sgml/lsj2/ulsj-"
let $docPostfix := ".xml"

(: invalid entries :)
let $invalids :=
(
  "*Alm.", "*Anal.", "*Antiop.", "*Archel.",
  "*Cret.", "*Deff.", "*Fr.", "*Geep.",
  "*Geom.", "*Hyp.", "*Inscr.Can.", "*Melanipp.Capt.",
  "*Melanipp.Sap.", "*Mens.", "*Oen.", "*Phaëth.",
  "*Phas.", "*Pirith.", "*Planisph.", "*Pseph.",
  "*Stereom.", "*Sthen.", "1 Ep.Cor.", "1 Ep.Jo.",
  "1 Ep.Pet.", "1 Ep.Thess.", "1Enoch", "2 Ep.Cor.",
  "2 Ep.Jo.", "2 Ep.Pet.", "2 Ep.Thess.", "Aër.",
  "Aët.", "A.", "A.D.", "A.R.",
  "AB", "AEM", "AJ", "AJA",
  "AJP", "AP", "APl.", "APo.",
  "APr.", "Abd.", "Abh.Berl.Akad.", "Abst.",
  "Abyd.", "Acad.", "Acad.Ind.", "Acerat.",
  "Acesand.", "Ach.", "Ach.Tat.", "Achae.",
  "Act.Ap.", "Acus.", "Acut.", "Acut.(Sp.",
  "Acut.(Sp.)", "Adam.", "Adv.", "Aed.",
  "Ael.", "Ael.Dion.", "Aem.", "Aemil.",
  "Aen.Gaz.", "Aen.Tact.", "Aequil.", "Aesar.",
  "Aesch.Alex.", "Aeschin.", "Aeschin.Socr.", "Aesop.",
  "Aet.", "Aevum", "Aff.", "Afric.",
  "Africa Italiana", "Africa Italiana Riv.", "Ag.", "Agaclyt.",
  "Agath.", "Agatharch.", "Agathem.", "Agathin.",
  "Agathocl.", "Ages.", "Ages..", "Aj.", "Al.",
  "Alan.", "Alb.", "Albania", "Alc.",
  "Alc.Com.", "Alc.Mess.", "Alcid.", "Alcin.",
  "Alciphr.", "Alcm.", "Alex.", "Alex.Aet.",
  "Alex.Aphr.", "Alex.Eph.", "Alex.Polyh.", "Alex.Trall.",
  "Alexand.Com.", "Alim.", "All.", "Alph.",
  "Alyp.", "Am.", "Amat.", "Amips.",
  "Amm.Marc.", "Ammian.", "Ammon.", "An.",
  "An.Bachm.", "An.Ox.", "An.Ox.,Par.", "An.Par.",
  "Anach.", "Anacr.", "Anacreont.", "Anan.",
  "Anat.", "Anatolian Studies", "Anaxag.", "Anaxandr.",
  "Anaxandr.Hist.", "Anaxarch.", "Anaxil.", "Anaximand.",
  "Anaximand.Hist.", "Anaximen.", "Anaxipp.", "And.",
  "Andr.", "Androm.", "Andronic.", "Andronic.Rhod.",
  "Androt.", "Anecd.Stud.", "Anim.Pass.", "Ann.Épigr.",
  "Annales du Service", "Annuario", "Anon.", "Anon.Lond.",
  "Anon.Rhythm.", "Anon.Vat.", "Ant.", "Ant.Diog.",
  "Ant.Lib.", "Antag.", "Anthem.", "Anticl.",
  "Antid.", "Antig.", "Antig.Nic.", "Antim.",
  "Antim.Col.", "Antioch.", "Antioch.Astr.", "Antioch.Hist.",
  "Antip.Sid.", "Antip.Stoic.", "Antip.Thess.", "Antiph.",
  "Antiphan.", "Antiphil.", "Antist.", "Antisth.",
  "Anton.Arg.", "Antr.", "Antyll.", "Anub.",
  "Anyt.", "Ap.", "Ap.Ty.", "Aph.",
  "Aphth.", "Apoc.", "Apol.", "Apollinar.",
  "Apollod.", "Apollod.Car.", "Apollod.Com.", "Apollod.Gel.",
  "Apollod.Lyr.", "Apollod.Stoic.", "Apollon.", "Apollon.Cit.",
  "Apollon.Perg.", "Apollonid.", "Apollonid.Trag.", "Apolloph.",
  "Apolloph.Stoic.", "Apostol.", "App.", "App.Anth.",
  "Aps.", "Apul.", "Aq.", "Ar.",
  "Ar.Byz.", "Ar.Did.", "Ara", "Arab.",
  "Arar.", "Arat.", "Arc.", "Arcesil.",
  "Arch.", "Arch.Anz.", "Arch.Jun.", "Arch.Pap.",
  "Arch.f.Religionswiss.", "Arched.", "Arched.Stoic.", "Archemach.",
  "Archestr.", "Archig.", "Archil.", "Archim.",
  "Archimel.", "Archipp.", "Archyt.", "Archyt.Amph.",
  "Aren.", "Aret.", "Arg.D.", "Arist.",
  "Aristaenet.", "Aristag.", "Aristag.Hist.", "Aristarch.",
  "Aristarch.Sam.", "Aristarch.Trag.", "Aristid.", "Aristid.Mil.",
  "Aristid.Quint.", "Aristipp.", "AristoStoic.", "Aristobul.",
  "Aristocl.", "Aristocl.Hist.", "Aristodem.", "Aristodic.",
  "Aristomen.", "Aristonym.", "Aristoph.Boeot.", "Aristox.",
  "Arr.", "Ars", "Art.", "Artem.",
  "Artemid.", "Arus.Mess.", "Ascens.Is.", "Ascl.",
  "Asclep.", "Asclep.Jun.", "Asclep.Myrl.", "Asclep.Tragil.",
  "Asin.", "Asp.", "Astr.", "Astramps.",
  "Astyd.", "Ath.", "Ath.Mech.", "Ath.Med.",
  "Ath.Mitt.", "Athenodor.Tars.", "Atil.Fort.", "Att.",
  "Attal.", "Atti Acc. Napoli", "Attic.", "Aud.",
  "Aus.", "Ausonia", "Aut.", "Autocr.",
  "Autol.", "Autom.", "Av.", "Ax.",
  "Axionic.", "Axiop.", "B.", "BC",
  "BCH", "BGU", "BJ", "BKT",
  "BMus.Inscr.", "BSA", "Ba.", "Babr.",
  "Bacch.", "Balbill.", "Bankakten", "Barb.",
  "Bass.", "Bato Sinop.", "Batr.", "Beibl.",
  "Bel.", "Beren.", "Berichtigungsl.", "Berl.Sitzb.",
  "Beros.", "Besant.", "Bis Acc.", "Blaes.",
  "Boeth.", "Boeth.Stoic.", "Bov.", "BpW",
  "Brum.", "Brut.", "Buckler Anat. Studies", "Bull.Comm.Arch.Com.",
  "Bull.Inst.Ég.", "Bull.Inst.Arch.Bulg.", "Bull.Inst.Franç.", "Bull.Soc.Alex.",
  "Buther.", "C.", "CA", "CD",
  "CG", "CIJud.", "CIL", "CMG",
  "CP", "CPHerm.", "CPR", "CQ",
  "CR", "CRAcad.Inscr.", "Ca.", "Cael.",
  "Cael.Aur.", "Caes.", "Cal.", "Calend.",
  "Call.", "Call.Com.", "Call.Hist.", "Callicrat.",
  "Callin.", "Callinic.Rh.", "Callistr.", "Callistr.Hist.",
  "Callix.", "Cam.", "Can.", "Canthar.",
  "Carc.", "Carm.", "Carm.Aur.", "Carm.Pop.",
  "Carn.", "Carneisc.", "Carph.", "Caryst.",
  "Cass.", "Cass.Fel.", "Cat.", "Cat. Ma., Mi.",
  "Cat.Cod. Astr.", "Cat.Cod.Astr.", "Ceb.", "Cels.",
  "Cephisod.", "Cer.", "Cerc.", "Cercop.",
  "Cereal.", "Certamen", "Cest.", "Ch.",
  "Chaerem.", "Chaerem.Hist.", "Chamael.", "Char.",
  "Chariclid.", "Charid.", "Charis.", "Charixen.",
  "Charond.", "Chionid.", "Choeril.", "Choeril.Trag.",
  "Choerob.", "Chor.", "Chr.", "Chrm.",
  "Chron.Lind.", "Chrysipp. Tyan.", "Chrysipp.Stoic.", "Cic.",
  "Cim.", "Circ.", "Cited by vol. and p.", "Clara Rhodos",
  "Class.Phil.", "Claud.Iol.", "Claudian.", "Cleaenet.",
  "Cleanth.Stoic.", "Clearch.", "Clearch.Com.", "Clem.Al.",
  "Cleobul.", "Cleom.", "Cleonid.", "Cleostrat.",
  "Clin.", "Clit.", "Clitarch.", "Clitom.",
  "Clyst.", "Coac.", "Cod.", "Cod.Just.",
  "Cod.Theod.", "Col.", "Col. or Fr.", "Collection Froehner",
  "Colot.", "Coluth.", "Com.Adesp.", "Comm.Math.",
  "Comm.in Arist.Graeca", "Comp.", "Con.", "Con.Sph.",
  "Conf.", "Conj.", "Const.omnem", "Consuet.",
  "Cont.", "Conv.", "Cor.", "Cord.",
  "Corinn.", "Corinth", "Corn.", "Corn.Long.",
  "Corp.Herm.", "Cra.", "Crass.", "Crater.",
  "Crates Com.", "Crates Theb.", "Cratin.", "Cratin.Jun.",
  "Cratipp.", "Cri.", "Crin.", "Criti.",
  "Critias", "Crito Com.", "Crito Hist.", "Crobyl.",
  "Ctes.", "Cyc.", "Cyllen.", "Cyn.",
  "Cypr.", "Cyr.", "Cyran.", "Cyrill.",
  "D.", "D.C.", "D.Chr.", "D.H.",
  "D.L.", "D.P.", "D.S.", "D.T.",
  "DDeor.", "DE", "DMar.", "DMeretr.",
  "DMort.", "Da.", "Dacia", "Daed.",
  "Dam.", "Damag.", "Damian.", "Damoch.",
  "Damocr.", "Damocrit.", "Damostr.", "Damox.",
  "Dat.", "De.", "Decent.", "Decl.",
  "Def.", "Def.Leg.", "Deioch.", "Del.",
  "Dem.", "Dem.Bith.", "Dem.Enc.", "Dem.Ophth.",
  "Dem.Phal.", "Demad.", "Demetr.", "Demetr.Apam.",
  "Demetr.Com.Nov.", "Demetr.Com.Vet.", "Demetr.Lac.", "Demetr.Troez.",
  "Democh.", "Democr.", "Democr.Eph.", "Demod.",
  "Demon.", "Demonic.", "Demoph.", "Dent.",
  "Deor.Conc.", "Dercyl.", "Descr.", "Dexipp.",
  "Diagor.", "Dial.", "Dialex.", "Dian.",
  "Dicaearch.", "Dicaearch.Hist.", "Dicaeog.", "Did.",
  "Dieb.Judic.", "Dieuch.", "Dieuchid.", "Diff.",
  "Diff. Com.", "Diff. Poet.", "Dig.", "Din.",
  "Dinol.", "Diocl.", "Diocl.Com.", "Diocl.Fr.",
  "Diod.", "Diod.Ath.", "Diod.Com.", "Diod.Rh.",
  "Diod.Tars.", "Diog.", "Diog.Apoll.", "Diog.Ath.",
  "Diog.Bab.Stoic.", "Diog.Oen.", "Diog.Sinop.", "Diogenian.",
  "Diogenian.Epicur.", "Diom.", "Dion.Byz.", "Dion.Calliph.",
  "Dionys.", "Dionys.Com.", "Dionys.Eleg.", "Dionys.Minor",
  "Dionys.Sam.", "Dionys.Stoic.", "Dionys.Trag.", "Dioph.",
  "Diophan.", "Dioptr.", "Diosc.", "Diosc.Gloss.",
  "Diosc.Hist.", "Diotim.", "Diotog.", "Diox.",
  "Diph.", "Diph.Siph.", "Dips.", "Dith.Oxy.",
  "Div.Somn.", "Diyll.", "Dom.", "Donat.",
  "Doroth.", "Dosiad.", "Dosiad.Hist.", "Dosith.",
  "Dsc.", "Dura6", "E.", "EE",
  "EM", "EN", "Ec.", "Ecl.",
  "Ecphant.", "Ecphantid.", "Ecphr.", "Edict.",
  "Edict.Diocl.", "El.", "Electr.", "Eleg.",
  "Eleg.Alex.Adesp.", "Eloc.", "Emp.", "Enc.",
  "Ench.", "Ep.", "Ep..", "Ep.Col.", "Ep.Eph.",
  "Ep.Gal.", "Ep.Hebr.", "Ep.Jac.", "Ep.Je.",
  "Ep.Jud.", "Ep.Phil.", "Ep.Philem.", "Ep.Rom.",
  "Ep.Sat.", "Ep.Tit.", "Eph.Epigr.", "Ephipp.",
  "Ephor.", "Epic.Alex.Adesp.", "Epich.", "Epicr.",
  "Epict.", "Epicur.", "Epid.", "Epig.",
  "Epigr.", "Epil.", "Epim.", "Epimenid.",
  "Epin.", "Epist. Charact.", "Epist.Charact.", "Epit.",
  "Eq.", "Eq.Mag.", "Eranos", "Erasistr.",
  "Eratosth.", "Erinn.", "Eriph.", "Erot.",
  "Erx.", "Eryc.", "Es.", "Et.Gen.",
  "Et.Gud.", "Eth.", "Etrusc.", "Etym.",
  "Eu.", "Euang.", "Eub.", "Eubulid.",
  "Euc.", "Eucrat.", "Eudem.", "Eudox.",
  "Eudox.Com.", "Eum.", "Eumel.", "Eun.",
  "Eunic.", "Euod.", "Eup.", "Euph.",
  "Euphron.", "Euryph.", "Eus.", "Eus.Hist.",
  "Eus.Mynd.", "Eust.", "Eust.Epiph.", "Eustr.",
  "Euthd.", "Euthphr.", "Euthycl.", "Eutoc.",
  "Eutolm.", "Eutych.", "Eux.", "Ev.Jo.",
  "Ev.Luc.", "Ev.Marc.", "Ev.Matt.", "Even.",
  "Ex.", "Exag.", "Exc.", "Ez.",
  "Ezek.", "Fab.", "Facet.", "Fam.",
  "Fasc.", "Favorin.", "Febr.", "Fest.",
  "Fig.", "Fin.", "Firm.", "Fist.",
  "Flam.", "Flat.", "Fluit.", "Fluv.",
  "Foed.Delph.Pell.", "Foet.Exsect.", "Fortunat.Rh.", "Fr.", "Fr..",
  "Fr. . . D.", "Fr. . . S.", "Fr.Hist.", "Fr.Lyr.",
  "Fr.anon.", "Fr.inc.", "Fract.", "Fug.",
  "Gött.Nachr.", "GA", "GC", "GDI",
  "Gabriel.", "Gaet.", "Gal.", "Galb.",
  "Gall.", "Gaud.Harm.", "Gaur.", "Ge.",
  "Gell.", "Gem.", "Genit.", "Geog.",
  "Geog.Comp.", "Georg.", "Gerasa", "Germ.",
  "Gland.", "Glauc.", "Gloss.", "Gnom.",
  "Gorg.", "Goth.", "Gp.", "Greg.Cor.",
  "Greg.Cypr.", "Grg.", "Gym.", "H.",
  "HA", "HF", "HG", "HN",
  "HP", "Hadr.", "Hadr.Rh.", "Haem.",
  "Haer.", "Halc.", "Hann.", "Harm.",
  "Harmod.", "Harp.", "Harp.Astr.", "Harv.Theol.Rev.",
  "Hb.", "Hdn.", "Hdt.", "Hebd.",
  "Hec.", "Hecat.", "Hecat.Abd.", "Hedyl.",
  "Hegem.", "Hegesand.", "Hegesian.", "Hegesipp.",
  "Hegesipp.Com.", "Hel.", "Heliod.", "Heliod.Hist.",
  "Hell.Oxy.", "Hellad.", "Hellanic.", "Hemerolog.Flor.",
  "Henioch.", "Heph.", "Heph.Astr.", "Her.",
  "Heracl.", "Heraclid.", "Heraclid.Com.", "Heraclid.Cum.",
  "Heraclid.Lemb.", "Heraclid.Pont.", "Heraclid.Sinop.", "Heraclit.",
  "Herb.", "Herc.", "Herill.Stoic.", "Herm.",
  "Herm.Hist.", "Herm.Iamb.", "Hermesian.", "Hermipp.",
  "Hermipp.Hist.", "Hermocl.", "Hermocr.", "Hermod.",
  "Hermog.", "Herod.", "Herod.Med.", "Herodor.",
  "Herophil.", "Hes.", "Hesperia", "Hg.",
  "Hices.", "Hier.", "Hierocl.", "Hierocl.Hist.",
  "Hieronym.Hist.", "Him.", "Hipp.", "Hipparch.",
  "Hipparch.Com.", "Hippias Erythr.", "Hippiatr.", "Hippod.",
  "Hippol.", "Hippon.", "Hisp.", "Hist.",
  "Hist.Aug.", "Hist.Conscr.", "Historia", "Hld.",
  "Ho.", "Hom.", "Honest.", "Horap.",
  "Hp.", "Hp.Ma., Mi.", "Hsch.", "Hsch.Mil.",
  "Hum.", "Hymn.", "Hymn.Curet.", "Hymn.Id.Dact.",
  "Hymn.Is.", "Hymn.Mag.", "Hyp.", "Hyps.",
  "Hypsicl.", "IA", "IG", "IGRom.",
  "IPE", "IT", "Iamb.", "Iamb.Bab.",
  "Iamblichus", "Iatr.", "Ibyc.", "Icar.",
  "Id.", "Idyll.", "Ign.", "Il.",
  "Il.Parv.", "Il.Parv..", "Il.Pers.", "Ill.", "Im.",
  "Incred.", "Ind.", "Inscr.Cos", "Inscr.Cret.",
  "Inscr.Magn.", "Inscr.Olymp.", "Inscr.Perg.", "Inscr.Prien.",
  "Insomn.", "Inst", "Inst.", "Inst.Log.",
  "Inst.Phys.", "Int.", "Intr.", "Intr.Arat.",
  "Inv.", "Ion Eleg.", "Ion Lyr.", "Ion Trag.",
  "Ir.", "Iren.", "Is.", "Isid.",
  "Isid.Aeg.", "Isid.Char.", "Isid.Trag.", "Isig.",
  "Isoc.", "Istros", "Isyll.", "Ital.",
  "Ix.", "J.", "JConf.", "JEA",
  "JHS", "JRS", "JTr.", "Jahrb.",
  "Jahresh.", "Jahresh..", "Jb.", "Jd.", "Je",
  "Jl.", "Jn.", "Jo.", "Jo.Alex.",
  "Jo.Alex. vel Jo.Gramm.", "Jo.Diac.", "Jo.Gaz.", "Jo.Gramm.Comp.",
  "Jov.", "Ju.", "Jud.Voc.", "Judic.",
  "Jul.", "Jul. vel Jul.Aegypt.", "Jul.Laod.", "Junc.",
  "Jusj.", "Just.", "Juv.", "Kith.",
  "Klio", "Kol.", "Kon.", "L' Ant.Cl.",
  "L.", "LI", "LL", "LXX",
  "La.", "Lac.", "Lamprocl.", "Lap.",
  "Laps.", "Lass.", "Lav.Pall.", "Le.",
  "Leg.Gort.", "Leg.Sacr.", "Leipz.Stud.", "Leo Phil.",
  "Leon.", "Leonid.", "Leont.", "Lesb.Gramm.",
  "Lesb.Rh.", "Leucipp.", "Lex", "Lex.",
  "Lex. de Spir.", "Lex.Mess.", "Lex.Rhet.", "Lex.Rhet.Cant.",
  "Lex.Sabb.", "Lex.Vind.", "Lg.", "Lib.",
  "Libr.Ord.", "Libr.Propr.", "Licymn.", "Limen.",
  "Liqu.", "Liv.Ann.", "Loc.", "Loc.Hom.",
  "Loll.", "Long.", "Longin.", "Luc.",
  "Lucill.", "Luct.", "Luct..", "Ly.", "Lyc.",
  "Lycophronid.", "Lycurg.", "Lyd.", "Lync.",
  "Lyr.", "Lyr.Adesp.", "Lyr.Alex.Adesp.", "Lys.",
  "Lysim.", "Lysimachid.", "Lysipp.", "Mél.Bidez",
  "Mél.Glotz", "M.", "M.Ant.", "MA",
  "MAMA", "MM", "Ma.", "Mac.",
  "Macar.", "Maced.", "Macr.", "Maec.",
  "Mag.", "Magn.", "Maiist.", "Malch.",
  "Mamerc.", "Man.", "Man.Hist.", "Mantiss.Prov.",
  "Mar.", "Mar.Vict.", "Marc.", "Marc.Arg.",
  "Marc.Sid.", "Marcellin.", "Marcian.", "Marian.",
  "Marin.", "Marm.Par.", "Mart.", "Mart.Cap.",
  "Max.", "Max.Tyr.", "Mech.", "Med.",
  "Med.Phil.", "Medic.", "Megasth.", "Mel.",
  "Melamp.", "Melanipp.", "Melanth.Hist.", "Melanth.Trag.",
  "Meliss.", "Mem.", "Memn.", "Men.",
  "Men.Eph.", "Men.Prot.", "Men.Rh.", "Menaechm.",
  "Menecl.", "Menecr.", "Menecr.Eph.", "Menecr.Xanth.",
  "Menemach.", "Menesth.", "Menipp.", "Menodot.",
  "Mens.", "Merc.Cond.", "Mesom.", "Metag.",
  "Metaph.", "Mete.", "Mete..", "Meth.", "Metr.",
  "Metrod.", "Metrod.Chius", "Metrod.Sceps.", "Mi.",
  "Mich.", "Milet.", "Milt.", "Mimn.",
  "Mimn.Trag.", "Min.", "Minuc.", "Mir.",
  "Mis.", "Mith.", "Mithr.", "Mixt.",
  "Mnasalc.", "Mnemos", "Mnesim.", "Mnesith.Ath.",
  "Mnesith.Cyz.", "Mochl.", "Moer.", "Mon.",
  "Mon.Anc.Gr.", "Mon.Ant.", "Mon.Piot", "Morb.",
  "Morb.Sacr.", "Mosch.", "MoschioTrag.", "Mu.",
  "Muc.Scaev.", "Mul.", "Mund.", "Mus.",
  "Mus.Belg.", "Musae.", "Musc.Enc.", "Music.",
  "Muson.", "Mx.", "Myrin.", "Myrsil.",
  "Myrtil.", "Myst.", "NA", "ND",
  "Na.", "Narr.", "Nat.", "Nat.Fac.",
  "Nat.Hom.", "Nat.Mul.", "Nat.Puer.", "Naukratis",
  "Naumach.", "Nausicr.", "Nausiph.", "Nav.",
  "Ne.", "Neanth.", "Nearch.", "Nec.",
  "Nech.", "Nem.", "Neophr.", "Neoptol.",
  "Ner.", "Nic.", "Nic.Dam.", "Nicaenet.",
  "Nicarch.", "Nicoch.", "Nicocl.", "Nicod.",
  "Nicol.", "Nicol.Com.", "Nicom.", "Nicom.Com.",
  "Nicom.Trag.", "Nicostr.", "Nicostr.Com.", "Nigr.",
  "Nob.", "Nonn.", "Noss.", "Not.Scav.",
  "Notiz.Arch.", "Nov.", "Nu.", "Num.",
  "Numen.", "Nymphod.", "O., P., N., I.", "OC",
  "OGI", "OT", "Ob.", "Ocell.",
  "Oct.", "Ocyp.", "Od.", "Oec.",
  "Oenom.", "Off.", "Olymp.", "Olymp.Alch.",
  "Olymp.Hist.", "Onat.", "Onir.", "Onom.",
  "Onos.", "Op.", "Ophel.", "Opp.",
  "Opt.", "Opt.Doctr.", "Or.", "Orac.Chald.",
  "Orat.Vett.", "Orib.", "Orph.", "Oss.",
  "Ost.", "Ostr.Strassb.", "Oth.", "Oxy.",
  "P.", "PA", "PAberd.", "PAlex.",
  "PAmh.", "PAntin.", "PAvrom.", "PBasel",
  "PBerl.Leihg.", "PBouriant", "PCornell", "PE",
  "PEleph.", "PEnteux.", "PFlor.", "PFreib.",
  "PGand}", "PGen.", "PGiss.", "PGnom.",
  "PGurob", "PHarris", "PHaw.", "PHeid.",
  "PHib.", "PHolm.", "PIand.", "PJena",
  "PKlein.Form.", "PLeid.U.", "PLille", "PLond.",
  "PLond.ined.", "PMag.", "PMag.Leid.V.", "PMag.Lond.",
  "PMagd.", "PMed.Lond.", "PMed.Strassb.", "PMich.",
  "PMich.Teb.", "PMich.Zen.", "PMilan.", "PMilan.R.Univ.",
  "POsl.", "POxy.", "PPetr.", "PPrincet.",
  "PRain. (NS)", "PRein.", "PRoss.-Georg.", "PRyl.",
  "PS", "PSI", "PTeb.", "PThead.",
  "PWürzb.", "PWarren", "PZen.Col.", "Pae.",
  "Pae.Delph.", "Pae.Erythr.", "Paed.", "Palaeph.",
  "Palch.", "Pall.", "Pamphil.", "Pan.",
  "Pancrat.", "Panyas.", "Papers of Amer. School at Athens", "Papp.",
  "Par.", "Par.Ptol.", "Parm.", "Parmen.",
  "Parod.Fr.", "Parrhas.", "Parth.", "Parv.Pil.",
  "Patr.Enc.", "Patrocl.", "Paul.Aeg.", "Paul.Al.",
  "Paul.Sil.", "Paus.", "Paus.Dam.", "Paus.Gr.",
  "Pediasim.", "Pel.", "Pelag.Alch.", "Pempel.",
  "Pepl.", "Per.", "Peregr.", "Perict.",
  "Peripl.", "Peripl.M.Rubr.", "Pers.", "Pers.Stoic.",
  "Petos.", "Petr.Patr.", "Petron.", "Ph.",
  "Ph.Bybl.", "Ph.Byz.", "Ph.Epic.", "Ph.Tars.",
  "Phaënn.", "Phaedim.", "Phaen.", "Phaest.",
  "Phal.", "Phalar.", "Phan.", "Phan.Hist.",
  "Phanocl.", "Phanod.", "Phasm.", "Phd.",
  "Phdr.", "Phdr..", "Pherecr.", "Pherecyd.", "Pherecyd.Syr.",
  "Phgn.", "Phil.", "Phil.Hist.", "Phil.Wochenschr.",
  "Philagr.", "Philem.", "Philem.Jun.", "Philet.",
  "Philetaer.", "Philipp.Com.", "Philippid.", "Philisc.Com.",
  "Philisc.Trag.", "Philist.", "Philoch.", "Philocl.",
  "Philod.Scarph.", "Philol.", "Philomnest.", "Philonid.",
  "Philopatr.", "Philops.", "Philosteph.Com.", "Philosteph.Hist.",
  "Philostr.", "Philostr.Jun.", "Philox.", "Philox.Gramm.",
  "Philum.", "Philyll.", "Phint.", "Phlb.",
  "Phld.", "Phleg.", "Phlp.", "Phoc.",
  "Phoeb.", "Phoen.", "Phoenicid.", "Phot.",
  "Phryn.", "Phryn.Com.", "Phryn.Lyr.", "Phryn.Trag.",
  "Phylarch.", "Phylotim.", "Pi.", "Piet.",
  "Pisand.", "Pisc.", "Pittac.", "Pk.",
  "Pl.", "Pl..", "Pl.Com.", "Pl.Jun.", "Placit.",
  "Platon.", "Plaut.", "Plb.", "Plb.Rh.",
  "Plin.", "Plot.", "Plt.", "Plu.",
  "Poëm.", "Po.", "Pol.", "Polem.",
  "Polem.Hist.", "Polem.Phgn.", "Polioch.", "Poliorc.",
  "Poll.", "Polyaen.", "Polycharm.", "Polyclit.",
  "Polycr.", "Polystr.", "Polyzel.", "Pomp.",
  "Pomp.Mac.", "Porph.", "Posidipp.", "Posidon.",
  "Pr.", "Pr.Im.", "Praec.", "Praef.",
  "Pratin.", "Praxag.", "Praxill.", "Prec.Man.",
  "Princeton Exp.Inscr.", "Prisc.", "Prisc.Lyd.", "Priscian.",
  "Prm.", "ProMerc.Cond.", "Proc.", "Procl.",
  "Procop.", "Procop.Gaz.", "Prodic.", "Prog.",
  "Proll.Heph.", "Prom.", "Prom.Es", "Promathid.",
  "Pron.", "Prooem.", "Prorrh.", "Protag.",
  "Protagorid.", "Protr.", "Prov.", "Proxen.",
  "Prt.", "Ps.", "Ps.-Callisth.", "Ps.-Democr.",
  "Ps.-Luc.", "Ps.-Phoc.", "Psalm.Solom.", "Pseudol.",
  "Ptol.", "Ptol.Ascal.", "Ptol.Chenn.", "Ptol.Euerg.",
  "Ptol.Megalop.", "Publ.", "Puls.", "Pun.",
  "Pyrrh.", "Pythaen.", "Pythag.", "Pythag. Ep.",
  "Pythocl.", "Q.S.", "QDAP", "QF",
  "QN", "Quadr.", "Quint.", "Röm.Mitt.",
  "R.", "RR", "Ra.", "Raccolta Lumbroso",
  "Recueil de Travaux", "Ref.", "Reg.", "Ren.Ves.",
  "Rend. Pont. Accad. Arch.", "Resp.", "Rev.Épigr.", "Rev.Ét.Gr.",
  "Rev.Arch.", "Rev.Bibl.", "Rev.Hist.Rel.", "Rev.Phil.",
  "Rh.", "Rh.Al.", "Rh.Mus.", "Rh.Pr.",
  "Rhetor.", "Rhian.", "Rhinth.", "Rhyth.",
  "Riv.1st.Arch.", "Riv.Fil.", "Rom.", "Ru.",
  "Ruf.", "Ruf.Rh.", "Rufin.", "Rutil.",
  "S.", "S.E.", "SA", "SD",
  "SE", "SIG", "Sacerd.", "Sacr.",
  "Sallust.", "Salt.", "Salubr.", "Sam.",
  "Sammelb.", "Sannyr.", "Sapph.", "Sat.",
  "Sat.Gon.", "Sat.Men.", "Satyr.", "Sc.",
  "Scol.", "Scol.Oxy.", "Scyl.", "Scymn.",
  "Scyth.", "Scythin.", "Sect.Can.", "Sect.Con.",
  "Sect.Cyl.", "Sect.Intr.", "Secund.", "Seleuc.",
  "Seleuc.Lyr.", "Semon.", "Sens.", "Sent.",
  "Sent.Vat.", "Septim.", "Septim. (Sp.)", "Seren.",
  "Sert.", "Serv.", "Sever.", "Sext.",
  "Si.", "Sic.", "Sign.", "Silen.",
  "Sim.", "Simm.", "Simon.", "Simp.",
  "Simyl.", "Sir", "Sis.", "Sitzb.Heidelb.Akad.",
  "Sm.", "Smp.", "Socr.", "Socr.Arg.",
  "Socr.Cous", "Socr.Rhod.", "Sokrates", "Sol.",
  "Somn.", "Somn.Vig.", "Sopat.", "Sopat.Rh.",
  "Soph.", "Sophil.", "Sophon", "Sophr.",
  "Sor.", "Sos.", "Sosib.", "Sosicr.",
  "Sosicr.Hist.", "Sosicr.Rhod.", "Sosip.", "Sosiph.",
  "Sosith.", "Sostrat.", "Sosyl.", "Sotad.",
  "Sotad.Com.", "Speus.", "Sph.", "Sph.Cyl.",
  "Sphaer.Hist.", "Sphaer.Stoic.", "Spir.", "St.Byz.",
  "Stad.", "Staphyl.", "Stat.", "Stat.Flacc.",
  "Steph.", "Steph.Com.", "Steril.", "Stesich.",
  "Stesimbr.", "Sthenid.", "Sto.", "Stob.",
  "Stoic.", "Stom.", "Str.", "Strat.",
  "Strato Com.", "Stratt.", "Strom.", "Stud.Ital.",
  "Stud.Pont.", "Su.", "Subf.Emp.", "Sud.",
  "Suet.", "Suid.", "Sull.", "Sulp.Max.",
  "Superf.", "Supp.", "Supp.Epigr.", "Sus.",
  "Symp.", "Syn.", "Syn.Alch.", "Syn.Puls.",
  "Synt.", "Syr.", "Syr.D.", "Syrian.",
  "TAM", "TG", "TP", "Tab.Defix.",
  "Tab.Defix.Aud.", "Tab.Heracl.", "Tact.", "Telecl.",
  "Telesill.", "Telest.", "Ter.Maur.", "Ter.Scaur.",
  "Terp.", "Test.Epict.", "Tetr.", "Th.",
  "Thal.", "Thd.", "Theaet.", "Theag.",
  "Theagen.", "Theb.Ostr.", "Them.", "Themist.",
  "Theo Sm.", "Theoc.", "Theocl.", "Theod.",
  "Theodect.", "Theodorid.", "Theodos.", "Theodos.Gr.",
  "Theognet.", "Theognost.", "Theol.Ar.", "Theolyt.",
  "Theon Gymn.", "Theoph.", "Theophil.", "Theopomp.Coloph.",
  "Theopomp.Com.", "Theopomp.Hist.", "Thes.", "Thg.",
  "Thgn.", "Thgn.Hist.", "Thgn.Trag.", "Thom.",
  "Thom.Mag.", "Thphr.", "Thras.", "Thrasym.",
  "Tht.", "Thugen.", "Thyill.", "Thymocl.",
  "Ti.", "Ti.Locr.", "Tib.", "Tib.Ill.",
  "Tim.", "Tim.Com.", "Tim.Gaz.", "Timae.",
  "Timag.", "Timocl.", "Timocr.", "Timostr.",
  "Titanomach.", "To.", "Top.", "Tox.",
  "Tr.", "Trag.", "Trag.Adesp.", "Trag.Poes.",
  "Trans.Am.Phil.Ass.", "Trop.", "Trophil.", "Tryph.",
  "Tull.Flacc.", "Tull.Gem.", "Tull.Laur.", "Tull.Sab.",
  "Tusc.", "Tymn.", "Tyr.", "Tyrt.",
  "Tz.", "UP", "Ulc.", "Ulp.",
  "Uran.", "V.", "VA", "VC",
  "VH", "VM", "VP", "VS",
  "VV", "Vand.", "Vect.", "Vel.Long.",
  "Ven.", "Vent.", "Verm.", "Vers.",
  "Vert.", "Vett.Cens.", "Vett.Val.", "Vict.",
  "Vict.Att.", "Vid.Ac.", "Virg.", "Virt.",
  "Vit.", "Vit.Aeschin.", "Vit.Auct.", "Vit.Caes.",
  "Vit.Eur.", "Vit.Hom.", "Vit.Philonid.", "Vit.Pl.",
  "Vitr.", "Wi.", "Wiegand Mnemos.", "Wien.Sitzb.",
  "Wien.Stud.", "Wiener Denkschr.", "WkP", "X.",
  "X.Eph.", "Xanth.", "Xen.", "Xenag.",
  "Xenarch.", "Xenocl.", "Xenocr.", "Xenoph.",
  "Yale Class. Studies", "Za.", "Zach.", "Zaleuc.",
  "Ze.", "Zeitschr.d.Savigny-Stiftung", "Zelot.", "Zen.",
  "Zeno Eleat.", "ZenoStoic.", "Zenod.", "Zeux.",
  "Zon.", "Zonae.", "Zonar.", "Zopyr.",
  "Zopyr.Hist.", "Zos.", "Zos.Alch.", "ad Ath.",
  "ad Them.", "de An.", "de Arte", "ed.",
  "editi", "h.Ap.", "h.Bacch.", "h.Cer.",
  "h.Hom.", "h.Mart.", "h.Merc.", "h.Pan.",
  "h.Ven.", "ibo", "in APo.", "in APr.",
  "in Alc.", "in CA", "in Cael.", "in Cat.",
  "in Cra.", "in D.", "in EN", "in Epict.",
  "in Euc.", "in Euthd., in Ly.", "in GA", "in Gal., in Hp.",
  "in Grg.", "in Harm.", "in Heph.", "in Hermog.",
  "in Hes.", "in Hp.", "in Int.", "in Metaph.",
  "in Mete.", "in Nic.", "in Ph.", "in Phdr.",
  "in Phlb.", "in Porph.", "in Prm.", "in Ptol.",
  "in R.", "in Rh.", "in SE", "in Theod.",
  "in Ti.", "in Top.", "in de An.", "inc."
)

(: corrections :)
let $corrections :=
  <corrections>
    <entry>
      <lemma>ὁ1</lemma>
      <meaning>the, that</meaning>
    </entry>
    <entry>
      <lemma>εἰμί1</lemma>
      <meaning>to be, to exist</meaning>
    </entry>
    <entry>
      <lemma>οὐ1</lemma>
      <meaning>not</meaning>
    </entry>
    <entry>
      <lemma>ὅς1</lemma>
      <meaning>this, that</meaning>
    </entry>
    <entry>
      <lemma>ἀλλά</lemma>
      <meaning>otherwise</meaning>
    </entry>
    <entry>
      <lemma>μή1</lemma>
      <meaning>not</meaning>
    </entry>
    <entry>
      <lemma>ἄλλος1</lemma>
      <meaning>another</meaning>
    </entry>
    <entry>
      <lemma>φημί</lemma>
      <meaning>to declare, make known</meaning>
    </entry>
    <entry>
      <lemma>ἑαυτοῦ</lemma>
      <meaning>of himself, herself, itself</meaning>
    </entry>
    <entry>
      <lemma>ἵημι</lemma>
      <meaning>to set a going, put in motion</meaning>
    </entry>
    <entry>
      <lemma>ἁμός2</lemma>
      <meaning>as, when</meaning>
    </entry>
    <entry>
      <lemma>Ζεύς</lemma>
      <meaning>Zeus</meaning>
    </entry>
    <entry>
      <lemma>ἔρχομαι</lemma>
      <meaning>to come</meaning>
    </entry>
    <entry>
      <lemma>ἅπᾱς</lemma>
      <meaning>quite all, the whole</meaning>
    </entry>
    <entry>
      <lemma>ἀνήρ</lemma>
      <meaning>a man</meaning>
    </entry>
    <entry>
      <lemma>ἄμι</lemma>
      <meaning>ajowan, Carum copticum</meaning>
    </entry>
    <entry>
      <lemma>βᾶρις</lemma>
      <meaning>flat-bottomed boat</meaning>
    </entry>
    <entry>
      <lemma>χοῦς1</lemma>
      <meaning>the Pitcher-feast</meaning>
    </entry>
    <entry>
      <lemma>ἴε2</lemma>
      <meaning>eagerly</meaning>
    </entry>
    <entry>
      <lemma>ἰτᾰμός</lemma>
      <meaning>headlong, hasty, eager</meaning>
    </entry>
    <entry>
      <lemma>ὡροσκοπεῖον</lemma>
      <meaning>clocks</meaning>
    </entry>
    <entry>
      <lemma>τρούβλιον</lemma>
      <meaning>cup. bowl</meaning>
    </entry>
    <entry>
      <lemma>τρῦπα</lemma>
      <meaning>hole</meaning>
    </entry>
  </corrections>
let $correctedLemmas := $corrections/entry/lemma/text()

(: for each letter in alphabet, process that letter's entries :)
for $letter in $letters
let $entries := doc(concat($docPrefix, $letter, $docPostfix))//entryFree

(: for each entry in file :)
for $entry in $entries
let $lemma := data($entry/@key)
let $sense := $entry/sense[exists(./tr)][1]
let $meaning :=
  if ($lemma = $correctedLemmas)
  then
    (: if correction exists, use it :)
    $corrections/entry[./lemma = $lemma]/meaning/text()
  else
    (: get first two <tr> elements :)
    let $parts :=
      for $tr in $sense/tr
      return
        normalize-space($tr)
    let $first :=
      if ($parts[1] = $invalids) then 2 else 1
    let $meaning :=
      (: if separated by "or", use concatenation else use first :)
      if ($parts[$first + 1])
      then
        let $both := concat($parts[$first], " or ", $parts[$first + 1])
        return
          if (contains(normalize-space(data($sense)), $both))
          then
            $both
          else
            $parts[$first]
      else
        $parts[$first]
    return
      (: remove trailing comma, semicolon :)
      if (ends-with($meaning, ",") or ends-with($meaning, ";"))
      then
        substring($meaning, 1, string-length($meaning) - 1)
      else
        $meaning

(: put out entry :)
return
  element entry
  {
    $entry/@id,
    element lemma { $lemma },
    if ($meaning)
    then
      element meaning { $meaning }
    else ()
  },

(: additions :)
<entry>
  <lemma>ἕ</lemma>
  <meaning>him, her</meaning>
</entry>,
<entry>
  <lemma>πέρ</lemma>
  <meaning>however</meaning>
</entry>,
<entry>
  <lemma>Ἥλιος</lemma>
  <meaning>sun</meaning>
</entry>,
<entry>
  <lemma>τίς</lemma>
  <meaning>who? which?</meaning>
</entry>,
<entry>
  <lemma>θέᾱ</lemma>
  <meaning>seeing, looking at</meaning>
</entry>,
<entry>
  <lemma>νόσφι</lemma>
  <meaning>aloof, apart, afar, away</meaning>
</entry>,
<entry>
  <lemma>Ποσειδεών</lemma>
  <meaning>Poseidon</meaning>
</entry>
}
