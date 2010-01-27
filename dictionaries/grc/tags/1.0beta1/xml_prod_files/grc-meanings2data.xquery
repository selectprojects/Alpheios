declare variable $docname external;
declare variable $output external;

let $doc := doc($docname)

(: get entries sorted by key :)
let $entries :=
  for $entry in $doc//entry
  order by $entry/lemma/@key1
  return $entry

(: get keys with trailing digits stripped off :)
let $keys :=
  for $entry in $entries
  return
    replace($entry/lemma/@key1, "\d+$", "")

return
  (: if putting out ids :)
  if ($output eq "ids")
  then
    (: for each entry with an id :)
    for $entry at $i in $entries
    let $key := $keys[$i]
    where $entry/@id
    return
    (
      (: if this is a unique key :)
      if (not($key = ($keys[$i - 1], $keys[$i + 1])))
      then
      (
        (: put it out :)
        concat($key, '|', $entry/@id, '&#x000A;'),

        (: if original had trailing digits, put it out also :)
        if ($key ne $entry/lemma/@key1)
        then
          concat($entry/lemma/@key1, '|', $entry/@id, '&#x000A;')
        else ()
      )
      (: if not a unique key :)
      else
      (
        (: if this is first occurrence :)
        if ($key ne $keys[$i - 1])
        then
        (
          (: flag it as special :)
          concat($key, "|@&#x000A;"),

          (: if original had trailing digits :)
          if ($key ne $entry/lemma/@key1)
          then
            (: put out second key with digits stripped :)
            concat(replace($entry/lemma/@key2, "\d+$", ""),
                   '|',
                   $entry/@id,
                   '&#x000A;')
          else ()
        )
        else (),

        (: if original had trailing digits :)
        if ($key ne $entry/lemma/@key1)
        then
          (: flag original as special :)
          concat($entry/lemma/@key1, "|@&#x000A;")
        else (),

        (: put out second key :)
        concat($entry/lemma/@key2, '|', $entry/@id, '&#x000A;')
      )
    )

  (: if putting out definitions :)
  else if ($output eq "defs")
  then
    (: for each entry with a meaning :)
    for $entry at $i in $entries
    let $key := $keys[$i]
    where $entry/meaning
    return
    (
      (: if this is a unique key :)
      if (not($key = ($keys[$i - 1], $keys[$i + 1])))
      then
      (
        (: put it out :)
        concat($key, '|', $entry/meaning, '&#x000A;'),

        (: if original had trailing digits, put it out also :)
        if ($key ne $entry/lemma/@key1)
        then
          concat($entry/lemma/@key1, '|', $entry/meaning, '&#x000A;')
        else ()
      )
      (: if not a unique key :)
      else
      (
        (: if this is first occurrence :)
        if ($key ne $keys[$i - 1])
        then
        (
          (: flag it as special :)
          concat($key, "|@&#x000A;"),

          (: if original had trailing digits :)
          if ($key ne $entry/lemma/@key1)
          then
            (: put out second key with digits stripped :)
            concat(replace($entry/lemma/@key2, "\d+$", ""),
                   '|',
                   $entry/meaning,
                   '&#x000A;')
          else ()
        )
        else (),

        (: if original had trailing digits :)
        if ($key ne $entry/lemma/@key1)
        then
          (: flag original as special :)
          concat($entry/lemma/@key1, "|@&#x000A;")
        else (),

        (: put out second key :)
        concat($entry/lemma/@key2, '|', $entry/meaning, '&#x000A;')
      )
    )

  (: if putting out server-side index :)
  else if ($output eq "index")
  then
    element entrylist
    {
      let $outEntries :=
        (: for each entry with an id :)
        for $entry at $i in $entries
        let $key := $keys[$i]
        where $entry/@id
        return
        (
          (: if this is a unique key :)
          if (not($key = ($keys[$i - 1], $keys[$i + 1])))
          then
          (
            (: put it out :)
            element entry
            {
              attribute lemma { $entry/lemma },
              attribute key { $key },
              attribute id { $entry/@id }
            },

            (: if original had trailing digits, put it out also :)
            if ($key ne $entry/lemma/@key1)
            then
              element entry
              {
                attribute lemma { $entry/lemma },
                attribute key { $entry/lemma/@key1 },
                attribute id { $entry/@id }
              }
            else ()
          )
          (: if not a unique key :)
          else
          (
            (: if this is first occurrence :)
            if ($key ne $keys[$i - 1])
            then
            (
              (: if original had trailing digits :)
              if ($key ne $entry/lemma/@key1)
              then
                let $key2 := replace($entry/lemma/@key2, "\d+$", "")
                return
                (
                  (: put out second key with digits stripped :)
                  element entry
                  {
                    attribute lemma { $entry/lemma },
                    attribute key { $key2 },
                    attribute id { $entry/@id }
                  },
                  (: and with leading '@' removed :)
                  element entry
                  {
                    attribute lemma { $entry/lemma },
                    attribute key { substring($key2, 2) },
                    attribute id { $entry/@id }
                  }
                )
              else ()
            )
            else (),

            (: put out second key :)
            element entry
            {
              attribute lemma { $entry/lemma },
              attribute key { $entry/lemma/@key2 },
              attribute id { $entry/@id }
            },
            (: and with leading '@' removed :)
            element entry
            {
              attribute lemma { $entry/lemma },
              attribute key { substring($entry/lemma/@key2, 2) },
              attribute id { $entry/@id }
            }
          )
        )

      for $entry in $outEntries
      order by number(substring($entry/@id, 2))
      return
        $entry
    }

  else
    ("Unrecognized output option ", $output) 