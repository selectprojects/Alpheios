import module namespace request="http://exist-db.org/xquery/request";  
import module namespace transform="http://exist-db.org/xquery/transform";  

(: get lemmas from request :)
let $lemmas := request:get-parameter("l", ())

return
  if (count($lemmas) = 0)
  then
    element output { "No lemma specified" }
  else

  (: wrap output :)
  element output
  {

  for $lemma in $lemmas
    (: see if we can find it directly :)
    let $dict-entry := collection("/db/lsj")//entryFree[@key eq $lemma]
    let $dict-entry :=
      if (exists($dict-entry))
      then
        $dict-entry
      else
        (:
          transform lemma to unicode
          Note: In order to ensure precomposed unicode,
          we first convert to betacode (which will leave
          betacode input unchanged), then convert to unicode
         :)
        let $beta-lemma :=
          transform:transform(
            <dummy/>,
            doc("/db/xslt/alpheios-uni2betacode.xsl"),
            <parameters>
              <param name="input" value="{ $lemma }"/>
            </parameters>)
        let $uni-lemma :=
          transform:transform(
            <dummy/>,
            doc("/db/xslt/alpheios-beta2unicode.xsl"),
            <parameters>
              <param name="input" value="{ $beta-lemma }"/>
            </parameters>)
        (: see if unicode lemma can be found directly :)
        let $dict-entry :=
          if ($uni-lemma ne $lemma)
          then
            collection("/db/lsj")//entryFree[@key eq $uni-lemma]
          else ()
        return
          if (exists($dict-entry))
          then
            $dict-entry
          else
            (:
              find entry in index
              Note: Lemma attribute in index corresponds to
              entryFree/@key in LSJ.
              Key attribute in index is LSJ lemma with vowel length
              and diaeresis stripped.
             :)
            let $index-entry :=
              doc("/db/indexes/ulsj-index.xml")//entry[@key eq $uni-lemma]

            (: get dictionary entry :)
            return
              collection("/db/lsj")//entryFree[@id eq string($index-entry/@id)]

    return
      element entry
      {
        attribute lemma-key { $lemma },

        (: if no entry, give error msg :)
        if (not(exists($dict-entry)))
        then
          ("Lemma ", $lemma, " not found")
        else
          $dict-entry
      }
  }
