pref("extensions.alpheios.greek.usemhttpd", true);
pref("extensions.alpheios.greek.chromepkg","alpheios-greek");
pref("extensions.alpheios.greek.languagecode","grc");
pref("extensions.alpheios.greek.base_unit","word");
pref("extensions.alpheios.greek.methods.startup",'loadShortDefs,loadLexIds,loadStripper');
pref("extensions.alpheios.greek.methods.convert",'greekToAscii');
pref("extensions.alpheios.greek.methods.lexicon",'webservice');
pref("extensions.alpheios.greek.url.lexicon", 'http://localhost:8200');
pref("extensions.alpheios.greek.url.lexicon.request", "/greek?word=<WORD>");
pref("extensions.alpheios.greek.url.lexicon.timeout",5000);
pref("extensions.alpheios.greek.popuptrigger",'dblclick');
pref("extensions.alpheios.greek.url.grammar",
     "chrome://alpheios-greek/content/alph-greek-grammar.xul");
pref("extensions.alpheios.greek.grammar.hotlinks",
     "alph-decl,alph-pofs,alph-mood,alph-case,alph-voice,alph-pers,alph-tense,alph-pofs-extra");
pref("extensions.alpheios.greek.features.alpheios-grammar",true);
pref("extensions.alpheios.greek.features.alpheios-inflect",true);
pref("extensions.alpheios.greek.context_handler","grammarContext");
pref("extensions.alpheios.greek.panels.use.defaults",true);
pref("extensions.alpheios.greek.dictionaries.short","dod,as,ml,aut,lsj");
pref("extensions.alpheios.greek.dictionaries.full","as,lsj,aut,ml");
pref("extensions.alpheios.greek.dictionaries.full.default","as");
pref("extensions.alpheios.greek.dictionary.full.search.url",
     "http://repos1.alpheios.net/exist/rest/db/xq/lexi-get.xq?lx=<LEXICON>&lg=grc&out=html");
pref("extensions.alpheios.greek.dictionary.full.search.lemma_param","l");
pref("extensions.alpheios.greek.dictionary.full.search.id_param","n");
pref("extensions.alpheios.greek.dictionary.full.search.multiple",true);
pref("extensions.alpheios.greek.sites.autoenable","http://www.hs-augsburg.de/~harsch/graeca/,http://www.classicpersuasion.org/pw/heraclitus/herpatu.htm");
pref("extensions.alpheios.greek.url.speech", 'http://localhost:8200/speech?voice=grc+f1?word=<WORD>');
