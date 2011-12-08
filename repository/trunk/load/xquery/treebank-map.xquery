(:
  Copyright The Alpheios Project, Ltd.
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
 
 (: for a text file which has been mapped to 2 different treebank files, this
    file creates a mapping between the 2 sets of treebank references 
 :)
 
 declare variable $e_refs1 external;
 declare variable $e_refs2 external;
 declare variable $e_tb1a external;
 declare variable $e_tb1u external;
 declare variable $e_tb2 external;
 declare variable $e_includeUnmapped external;
 
 (: iterate through the words in first doc, find the tbrefs for the corresponding words in the second doc, and 
    producing a mapping based on word @id 
 :)
 let $refs1 := doc($e_refs1)
 let $refs2 := doc($e_refs2)
 let $index :=
    for $word in $refs1//wd[@tbrefs] 
        let $id := $word/@id
        let $tbrefs := $word/@tbrefs
        let $maprefs := $refs2//wd[@id=$id]/@tbrefs
        return
            <mapping id="{$id}" old="{$tbrefs}" new="{$maprefs}"/>

(: iterate through a new empty treebank file (e_tb2) which has tb ids corresponding to those used in e_refs2
   and apply annotations from a file which has tb ids corresponding to those used in e_refs1
   in the output, include only those sentences for which we were able to map annotations
:)
let $tb1a := doc($e_tb1a)
let $tb1u := doc($e_tb1u)
let $tb2 := doc($e_tb2)

let $mapped_annotations :=
    for $sentence in $tb2//sentence
        let $sid := $sentence/@id
            let $words :=
                for $word in $sentence/word
                    let $wid := concat($sid,'-',$word/@id)
                    (: find the mapping for the new word :)
                    let $mapping := $index[@new=$wid]
                    let $old_sid := substring-before($mapping/@old,'-')
                    let $old_wid := substring-after($mapping/@old,'-')
                    let $old_archived := $tb1a//sentence[@id=$old_sid]/word[@id=$old_wid]
                    let $old_unarchived := $tb1u//sentence[@id=$old_sid]/word[@id=$old_wid]
                    let $old_annotation := if ($old_archived) then $old_archived else $old_unarchived
                    return
                        if ($old_annotation)
                        then
                            let $old_head := $old_annotation/@head
                            (: find the mapping for the old head :)
                            let $mapped_head := $index[@old=concat($old_sid,'-',$old_head)]/@new
                            (: make sure the old and the new head are the same word :)
                            let $new_head_form := $tb2//sentence[@id=substring-before($mapped_head,'-')]/word[@id=substring-after($mapped_head,'-')]/@form
                            let $old_head_form := $old_annotation/parent::sentence/word[@id=$old_head]/@form
                            let $new_head := if ($new_head_form = $old_head_form) then substring-after($mapped_head,'-') else 0
                            (: create a new word element using the new @id, @cid, and @form and 
                               old (annotated) @lemma, @postag, @relation and (mapped) @head
                            :)
                            return
                                <word id="{$word/@id}" 
                                    cid="{$word/@cid}" 
                                    form="{$word/@form}" 
                                    lemma="{$old_annotation/@lemma}" 
                                    postag="{$old_annotation/@postag}" 
                                    head="{$new_head}" relation="{$old_annotation/@relation}" 
                                    mapped_from="{$mapping/@old}"/>
                        else 
                            <word>
                                { $word/@* }
                            </word>
            return 
                (: include the sentence if we mapped at least one word, or have been asked to include unmapped sentences :)
                if ($words[@mapped_from])
                then 
                    <sentence>
                        {
                        	$sentence/@*,
                            $tb2/annotator/short,
                            $words
                         }
                    </sentence>
                else if ($e_includeUnmapped = 'true')
                    then
                        <sentence> {
                        $sentence/@*,
                        $tb2/annotator/short, 
                        for $w in $sentence/word return 
                        <word>
                            {$w/@*}
                        </word>
                        }
                    </sentence>
                else
                    ()
let $missed :=                    
    for $sentence in ($tb1a//sentence,$tb1u//sentence) 
        let $id := $sentence/@id
        return 
            if ($mapped_annotations//word[starts-with(@mapped_from,concat($id,'-'))])
            then ()
            else $sentence
return 
    <treebank> {
        $tb2/treebank/@*,
        $tb2/treebank/date,
        $mapped_annotations,
        if ($missed) then <missed>{$missed}</missed> else ()
    }
    </treebank>
                                
    		