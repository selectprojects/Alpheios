package perseus.morph;

/**
 * AlpheiosMorphCode provides a mapping between the morphological
 * codes in the database and the representation of those codes
 * within the Java classes using the Alpheios enumerated
 * values for the representations and category names.
 */
public class AlpheiosMorphCode
{
    public static final String PART_OF_SPEECH = "pofs";
    public static final String NOUN = "noun";
    public static final String VERB = "verb";
    public static final String VERB_PARTICIPLE = "verb participle";
    public static final String ADJECTIVE = "adjective";
    public static final String ADVERB = "adverb";
    public static final String ADVERBIAL = "adverbial";
    public static final String ARTICLE = "article";
    public static final String PARTICLE = "particle";
    public static final String CONJUNCTION = "conjunction";
    public static final String PREPOSITION = "preposition";
    public static final String PRONOUN = "pronoun";
    public static final String NUMERAL = "numeral";
    public static final String INTERJECTION = "interjection";
    public static final String EXCLAMATION = "exclamation";
    public static final String IRREGULAR = "irregular";

    public static final String PERSON = "pers";
    public static final String FIRST_PERSON = "1st";
    public static final String SECOND_PERSON = "2nd";
    public static final String THIRD_PERSON = "3rd";

    public static final String NUMBER = "num";
    public static final String SINGULAR = "singular";
    public static final String PLURAL = "plural";
    public static final String DUAL = "dual";

    public static final String TENSE = "tense";
    public static final String PRESENT = "present";
    public static final String IMPERFECT = "imperfect";
    public static final String PERFECT = "perfect";
    public static final String PLUPERFECT = "pluperfect";
    public static final String FUTURE_PERFECT = "futperfect";
    public static final String FUTURE = "future";
    public static final String AORIST = "aorist";
    public static final String PAST_ABSOLUTE = "past absolute";

    public static final String MOOD = "mood";
    public static final String INDICATIVE = "indicative";
    public static final String SUBJUNCTIVE = "subjunctive";
    public static final String OPTATIVE = "optative";
    public static final String INFINITIVE = "infinitive";
    public static final String IMPERATIVE = "imperative";
    public static final String GERUNDIVE = "gerundive";
    public static final String SUPINE = "supine";
    public static final String PARTICIPLE = "participle";

    public static final String VOICE = "voice";
    public static final String ACTIVE = "active";
    public static final String PASSIVE = "passive";
    public static final String DEPONENT = "deponent";
    public static final String MIDDLE = "middle";
    public static final String MEDIO_PASSIVE = "medio passive";

    public static final String GENDER = "gend";
    public static final String MASCULINE = "masculine";
    public static final String FEMININE = "feminine";
    public static final String NEUTER = "neuter";

    public static final String CASE = "case";
    public static final String NOMINATIVE = "nominative";
    public static final String GENITIVE = "genitive";
    public static final String DATIVE = "dative";
    public static final String ACCUSATIVE = "accusative";
    public static final String ABLATIVE = "ablative";
    public static final String VOCATIVE = "vocative";
    public static final String LOCATIVE = "locative";
    public static final String INSTRUMENTAL = "instrumental";

    public static final String DEGREE = "comp";
    public static final String POSITIVE = "positive";
    public static final String COMPARATIVE = "comparative";
    public static final String SUPERLATIVE = "superlative";

    public static final String DIALECT = "dialect";
    // uhh...I have no idea what should go here. What does Cruncher output?
    public static final String ATTIC = "attic";
    public static final String IONIC = "ionic";
    public static final String AEOLIC = "aeolic";
    public static final String EPIC = "epic";

    public static final String UNSPECIFIED = "UNSPECIFIED";

    // Catch-all for morphological quirks that don't fit in another category
    public static final String OTHER = "__other__";
}
