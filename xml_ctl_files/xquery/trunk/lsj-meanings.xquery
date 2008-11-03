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
(: let $letters := ( "beta" ) :)

let $docPrefix := "/sgml/lsj2/lsj-"
let $docPostfix := ".xml"

(: for each letter in alphabet, process that letter's entries :)
for $letter in $letters
let $entries := doc(concat($docPrefix, $letter, $docPostfix))//entryFree

(: for each entry in file :)
for $entry in $entries
let $sense := $entry/sense[exists(./tr)][1]
let $meaning :=
(
  (: get first two <tr> elements :)
  let $part1 := normalize-space($sense/tr[1])
  let $part2 := normalize-space($sense/tr[2])
  let $meaning :=
    (: if separated by "or", use concatenation else use first :)
    if ($part2)
    then
      let $both := concat($part1, " or ", $part2)
      return
        if (contains(normalize-space(data($sense)), $both))
        then
          $both
        else
          $part1
    else
      $part1
  return
    (: remove trailing comma :)
    if (ends-with($meaning, ","))
    then
      substring($meaning, 1, string-length($meaning) - 1)
    else
      $meaning
)
(: only put out entry if meaning was found :)
where $meaning
return
  element entry
  {
    element lemma { data($entry/@key) },
    element meaning { $meaning }
  }
}