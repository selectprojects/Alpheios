(:
  Copyright 2012 The Alpheios Project, Ltd.
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
  CITE Reference Index Service to retrieve entries from an index of lexical entities to their uris

  Form of request is:
    .../lexi-get-ri.xq?IndexId=<grc|lat|ara>&ref=<uri>
    or
    .../lexi-get-ri.xq?IndexId=<grc|lat|ara>&val=<lemma>
  where
    IndexId is the id of the index (grc|lat|ara)
    ref is the uri
    or 
    val is the lemma

  Output is returned as plain text
:)

import module namespace request="http://exist-db.org/xquery/request";
import module namespace transform="http://exist-db.org/xquery/transform";  
import module namespace util="http://exist-db.org/xquery/util";
import module namespace lxget="http://alpheios.net/namespaces/lexi-get"
              at "lexi-get.xquery";

declare option exist:serialize "method=xml media-type=text/xml";

declare variable $f_lexiconOrder :=
(
  <lx lg="grc">
    <entry order="1" code="l">lsj</entry>
    <entry order="2" code="m">ml</entry>
    <entry order="3" code="a">aut</entry>
  </lx>,    
  <lx lg="lat">
    <entry order="1" code="l">ls</entry>
  </lx>,     
  <lx lg="ara">
    <entry order="1" code="s">sal</entry>
    <entry order="2" code="l">lan</entry>
  </lx>
);


(: get lexicon files :)
let $request := request:get-parameter('request','')
let $langCode := request:get-parameter('IndexId','grc')
let $ref := request:get-parameter('ref','')
let $val := request:get-parameter('val','')
return
    if ($request = 'GetCapabilities') then 
         <GetCapabilities xmlns="http://chs.harvard.edu/xmlns/refindex/1.0">
            <request/>
            <reply>{
                for $lexiCode in $f_lexiconOrder return
                element idx {
                    attribute id {$lexiCode/@lg},
                    element description { concat($lexiCode/@lg, " lexical entities") },
                    element referenceType { 'uri' },
                    element valueType { 'string' }
                }
            }</reply>
         </GetCapabilities>
    else if ($request = 'QueryIndex') then 
    let $all_entries := 
    for $lexiCode in $f_lexiconOrder[@lg=$langCode]/entry order by $lexiCode/@order
        return
            let $lexicon := collection(concat("/db/lexica/",
                                  $langCode,
                                  "/",
                                  $lexiCode))
            let $index := doc(concat("/db/indexes/",
                         $langCode,
                         "-",
                         $lexiCode,
                         "-index.xml"))
            (: find lexicon entries :)
            let $entry :=
                if ($ref) then
                    let $parsed_ref := substring(tokenize($ref,'/')[last()],2)
                    return
                        lxget:get-entry-by-id($lexicon,$parsed_ref)[1]
                (: if specified by lemma :)
               else
                   lxget:get-entry-by-lemma($lexicon, $index, $val, $langCode)[1]
            return
                if ($entry) then
                    let $lemmaVal := $entry/@key
                    let $uri := concat('http://data.perseus.org/lexical/', $langCode, '/',$lexiCode/@code, $entry/@id)
                    return <record xmlns="http://chs.harvard.edu/xmlns/refindex/1.0" ref="{$uri}" val="{$lemmaVal}"/>
                else ()    
        return 
            if (count($all_entries) = 0)
            then
                <Error>
                    <request>
                        <indexId>{$langCode}</indexId>
                        {   if ($ref) then 
                                <ref>{$ref}</ref> 
                            else <val>{$val}</val>
                        }
                    </request>
                    <reply>
                        <code></code>
                        <msg>Not Found</msg>
                    </reply>
                </Error>
            else 
                <QueryIndex xmlns="http://chs.harvard.edu/xmlns/refindex/1.0">
                    <request>
                        <indexId>{$langCode}</indexId>
                        {   if ($ref) then 
                                <ref>{$ref}</ref> 
                            else <val>{$val}</val>
                        }
                    </request>
                    <reply>
                        {$all_entries[1]}
                    </reply>
                </QueryIndex>
    else 
        <Error>
            <request>
                <indexId>{$langCode}</indexId>
                {   if ($ref) then 
                    <ref>{$ref}</ref> 
                    else <val>{$val}</val>
                 }
                 </request>
            <reply>
                 <code>2</code>
                 <msg>{concat('Unrecognized request parameter ',$request)}</msg>
            </reply>
        </Error>