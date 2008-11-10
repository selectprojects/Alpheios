(:
  XQuery to extract short definitions from LSJ Greek lexicon

  Output is in form
  <entrylist>
    <entry>
      <lemma>lemma</lemma>
      <meaning>definition</meaning>
    </entry>
    ...
  </entrylist.
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

(: invalid entries :)
let $invalids :=
(
  "ibo", "Fr.anon.", "PLond.ined.", "Cat.Cod. Astr.", "Acut.(Sp."
)

(: corrections :)
let $corrections :=
  <corrections>
    <entry>
      <lemma>o(1</lemma>
      <meaning>the, that</meaning>
    </entry>
    <entry>
      <lemma>ei)mi/1</lemma>
      <meaning>to be, to exist</meaning>
    </entry>
    <entry>
      <lemma>ou)1</lemma>
      <meaning>not</meaning>
    </entry>
    <entry>
      <lemma>o(/s1</lemma>
      <meaning>this, that</meaning>
    </entry>
    <entry>
      <lemma>a)lla/</lemma>
      <meaning>otherwise</meaning>
    </entry>
    <entry>
      <lemma>mh/1</lemma>
      <meaning>not</meaning>
    </entry>
    <entry>
      <lemma>a)/llos1</lemma>
      <meaning>another</meaning>
    </entry>
    <entry>
      <lemma>fhmi/</lemma>
      <meaning>to declare, make known</meaning>
    </entry>
    <entry>
      <lemma>e(autou=</lemma>
      <meaning>of himself, herself, itself</meaning>
    </entry>
    <entry>
      <lemma>i(/hmi</lemma>
      <meaning>to set a going, put in motion</meaning>
    </entry>
    <entry>
      <lemma>a(mo/s2</lemma>
      <meaning>as, when</meaning>
    </entry>
    <entry>
      <lemma>*zeu/s</lemma>
      <meaning>Zeus</meaning>
    </entry>
    <entry>
      <lemma>e)/rxomai</lemma>
      <meaning>to come</meaning>
    </entry>
    <entry>
      <lemma>a(/pa_s</lemma>
      <meaning>quite all, the whole</meaning>
    </entry>
   <entry>
      <lemma>a)nh/r</lemma>
      <meaning>a man</meaning>
   </entry>
  </corrections>
let $correctedLemmas := $corrections/entry/lemma/text()

let $docPrefix := "/sgml/lsj2/lsj-"
let $docPostfix := ".xml"

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

(: only put out entry if meaning was found :)
where $meaning
return
  element entry
  {
    element lemma { $lemma },
    element meaning { $meaning }
  },

(: additions :)
<entry>
  <lemma>e(/</lemma>
  <meaning>him, her</meaning>
</entry>,
<entry>
  <lemma>pe/r</lemma>
  <meaning>however</meaning>
</entry>,
<entry>
  <lemma>*(/hlios</lemma>
  <meaning>sun</meaning>
</entry>,
<entry>
  <lemma>ti/s</lemma>
  <meaning>who? which?</meaning>
</entry>,
<entry>
  <lemma>qe/a_</lemma>
  <meaning>seeing, looking at</meaning>
</entry>,
<entry>
  <lemma>no/sfi</lemma>
  <meaning>aloof, apart, afar, away</meaning>
</entry>,
<entry>
  <lemma>*poseidew/n</lemma>
  <meaning>Poseidon</meaning>
</entry>
}