package perseus.morph;

import java.util.HashMap;
import java.util.Map;

import static perseus.morph.MelampusMorphCode.*;

/**
 * Converts morph codes found in the database into a Map
*/
public class MelampusMorphCodeGenerator implements MorphCodeGenerator
{
    /**
     * Return the morphological breakdown based upon the morph
     * codes in the database
     *
     * @param features a Map of features of a given Greek morphological entry
     * @return a String containing the morphological breakdown
    */
    public String getCode(Map<String, String> features)
    {
        return null;
    }

    /**
     * Given a morphological code, retrieve a map of features about the morph entry
     *
     * @param code
     * @return a map of features indexed by constants for part of speech, tense, voice, etc
     * in the MorphCode class
    */
    public Map<String, String> getFeatures(String code)
    {
        char[] chars = code.toCharArray();
        Map<String,String> features = new HashMap<String,String>();

        char pos = chars[0];
        if (pos == 'n')
            features.put(PART_OF_SPEECH, NOUN);
        else if (pos == 'v')
            features.put(PART_OF_SPEECH, VERB);
        else if (pos == 't')
            features.put(PART_OF_SPEECH, VERB_PARTICIPLE);
        else if (pos == 'a')
            features.put(PART_OF_SPEECH, ADJECTIVE);
        else if (pos == 'd')
            features.put(PART_OF_SPEECH, ADVERB);
        else if (pos == 'c')
            features.put(PART_OF_SPEECH, CONJUNCTION);
        else if (pos == 'l')
            features.put(PART_OF_SPEECH, ARTICLE);
        else if (pos == 'g')
            features.put(PART_OF_SPEECH, PARTICLE);
        else if (pos == 'r')
            features.put(PART_OF_SPEECH, PREPOSITION);
        else if (pos == 'p')
            features.put(PART_OF_SPEECH, PRONOUN);
        else if (pos == 'm')
            features.put(PART_OF_SPEECH, NUMERAL);
        else if (pos == 'i')
            features.put(PART_OF_SPEECH, INTERJECTION);
        else if (pos == 'e')
            features.put(PART_OF_SPEECH, EXCLAMATION);
        else if (pos == 'x')
            features.put(PART_OF_SPEECH, IRREGULAR);

        char person = chars[1];
        if (person == '1')
            features.put(PERSON, FIRST_PERSON);
        else if (person == '2')
            features.put(PERSON, SECOND_PERSON);
        else if (person == '3')
            features.put(PERSON, THIRD_PERSON);

        char number = chars[2];
        if (number == 's')
            features.put(NUMBER, SINGULAR);
        else if (number == 'p')
            features.put(NUMBER, PLURAL);
        else if (number == 'd')
            features.put(NUMBER, DUAL);

        char tense = chars[3];
        if (tense == 'p')
            features.put(TENSE, PRESENT);
        else if (tense == 'i')
            features.put(TENSE, IMPERFECT);
        else if (tense == 'r')
            features.put(TENSE, PERFECT);
        else if (tense == 'l')
            features.put(TENSE, PLUPERFECT);
        else if (tense == 't')
            features.put(TENSE, FUTURE_PERFECT);
        else if (tense == 'f')
            features.put(TENSE, FUTURE);
        else if (tense == 'a')
            features.put(TENSE, AORIST);

        char mood = chars[4];
        if (mood == 'i')
            features.put(MOOD, INDICATIVE);
        else if (mood == 's')
            features.put(MOOD, SUBJUNCTIVE);
        else if (mood == 'o')
            features.put(MOOD, OPTATIVE);
        else if (mood == 'n')
            features.put(MOOD, INFINITIVE);
        else if (mood == 'm')
            features.put(MOOD, IMPERATIVE);
        else if (mood == 'g')
            features.put(MOOD, GERUNDIVE);
        else if (mood == 'p')
            features.put(MOOD, PARTICIPLE);

        char voice = chars[5];
        if (voice == 'a')
            features.put(VOICE, ACTIVE);
        else if (voice == 'p')
            features.put(VOICE, PASSIVE);
        else if (voice == 'd')
            features.put(VOICE, DEPONENT);
        else if (voice == 'e')
            features.put(VOICE, MEDIO_PASSIVE);

        char gender = chars[6];
        if (gender == 'm')
            features.put(GENDER, MASCULINE);
        else if (gender == 'f')
            features.put(GENDER, FEMININE);
        else if (gender == 'n')
            features.put(GENDER, NEUTER);

        // "case" is a reserved word
        char caseLetter = chars[7];
        if (caseLetter == 'n')
            features.put(CASE, NOMINATIVE);
        else if (caseLetter == 'g')
            features.put(CASE, GENITIVE);
        else if (caseLetter == 'd')
            features.put(CASE, DATIVE);
        else if (caseLetter == 'a')
            features.put(CASE, ACCUSATIVE);
        else if (caseLetter == 'b')
            features.put(CASE, ABLATIVE);
        else if (caseLetter == 'v')
            features.put(CASE, VOCATIVE);
        else if (caseLetter == 'i')
            features.put(CASE, INSTRUMENTAL);
        else if (caseLetter == 'l')
            features.put(CASE, LOCATIVE);

        char degree = chars[8];
        if (degree == 'p')
            features.put(DEGREE, POSITIVE);
        else if (degree == 'c')
            features.put(DEGREE, COMPARATIVE);
        else if (degree == 's')
            features.put(DEGREE, SUPERLATIVE);

        return features;
    }
}
