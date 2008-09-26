pref("extensions.alpheios.greek.usemhttpd", false);
pref("extensions.alpheios.greek.chromepkg","alpheios-greek");
pref("extensions.alpheios.greek.languagecode","grc");
pref("extensions.alpheios.greek.base_unit","word");
pref("extensions.alpheios.greek.methods.lexicon",'webservice');
pref("extensions.alpheios.greek.url.lexicon", 'http://dev.alpheios.net:8020');
pref("extensions.alpheios.greek.url.lexicon.request", "/hopper/alpheios/xmlmorph-alph.jsp?word=<WORD>&input=Unicode");
pref("extensions.alpheios.greek.url.lexicon.timeout",10000);
pref("extensions.alpheios.greek.popuptrigger",'mousemove');
pref("extensions.alpheios.greek.url.grammar",
     "chrome://alpheios-greek/content/alph-greek-grammar.xul");
pref("extensions.alpheios.greek.grammar.hotlinks",
     "alph-decl,alph-pofs,alph-mood,alph-case,alph-voice,alph-pers,alph-tense");
pref("extensions.alpheios.greek.features.alpheios-grammar",true);
pref("extensions.alpheios.greek.features.alpheios-inflect",true);
pref("extensions.alpheios.greek.context_handler","grammarContext");
pref("extensions.alpheios.greek.shift_handler","handleInflections");


            