pref("extensions.alpheios.arabic.usemhttpd", false);
pref("extensions.alpheios.arabic.chromepkg","alpheios-arabic");
pref("extensions.alpheios.arabic.languagecode","ara,ar");
pref("extensions.alpheios.arabic.base_unit","word");
pref("extensions.alpheios.arabic.methods.startup",'loadLexIds,loadStripper');
pref("extensions.alpheios.arabic.methods.convert", 'unicodeToBuckwalter');
pref("extensions.alpheios.arabic.methods.lexicon",'webservice');
pref("extensions.alpheios.arabic.url.lexicon", 'http://alpheios.net/perl/aramorph2?');
pref("extensions.alpheios.arabic.url.lexicon.request", "word=<WORD>");
pref("extensions.alpheios.arabic.url.lexicon.timeout",10000);
pref("extensions.alpheios.arabic.grammar.hotlinks","");
pref("extensions.alpheios.arabic.popuptrigger",'dblclick');
pref("extensions.alpheios.arabic.features.alpheios-inflect",false);
pref("extensions.alpheios.arabic.features.alpheios-grammar",false);
pref("extensions.alpheios.arabic.panels.use.defaults",true);
pref("extensions.alpheios.arabic.dictionaries.full","sal,lan");
pref("extensions.alpheios.arabic.dictionary.full.search.url",
     "http://repos1.alpheios.net/exist/rest/db/xq/lexi-get.xq?lx=<LEXICON>&lg=ara&out=html");
pref("extensions.alpheios.arabic.dictionary.full.lan.browse.url",
	 "http://www.perseus.tufts.edu/hopper/text?doc=Perseus%3atext%3a2002.02.0015");
pref("extensions.alpheios.arabic.dictionary.full.lan.browse.convert_method", 'unicodeToBuckwalter');
pref("extensions.alpheios.arabic.dictionary.full.lan.browse.root_param",":root=<ROOT>");
pref("extensions.alpheios.arabic.dictionary.full.sal.browse.url",
"http://www.perseus.tufts.edu/hopper/text?doc=Perseus%3atext%3a2002.02.0005");
pref("extensions.alpheios.arabic.dictionary.full.sal.browse.convert_method", 'unicodeToBuckwalter');
pref("extensions.alpheios.arabic.dictionary.full.sal.browse.root_param",":root=<ROOT>");
pref("extensions.alpheios.arabic.dictionary.full.search.lemma_param","l");
pref("extensions.alpheios.arabic.dictionary.full.search.id_param","n");
pref("extensions.alpheios.arabic.dictionary.full.search.multiple",true);
pref("extensions.alpheios.arabic.stripper.list","tanwin,hamza,harakat,shadda,sukun,alef");
