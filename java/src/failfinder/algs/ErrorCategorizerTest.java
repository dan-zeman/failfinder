package failfinder.algs;

import java.util.ArrayList;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import failfinder.algs.ErrorCategorizer.Tristate;
import failfinder.data.Hypothesis;
import failfinder.data.NBestList;

public class ErrorCategorizerTest {

	private ErrorCategorizer cat;
	private String desired;
	private NBestList empty;
	private NBestList fuzzyWuzznt1;
	private NBestList fuzzyWuz1;
	private NBestList fuzzyWuzBest1;
	private NBestList fuzzyWuzWorst1;
	private NBestList fuzzyWuzWorst5;
	private NBestList fuzzyWuzznt5;

	@Before
	public void setup() {
		cat = new ErrorCategorizer();
		desired = "fuzzy wuzzy was a bear";
		empty = new NBestList(new ArrayList<Hypothesis>(0));
		fuzzyWuz1 = makeNbest("fuzzy wuzzy was a bear", -1.0f);
		fuzzyWuzznt1 = makeNbest("fuzzy wuzznt was a bear", -1.0f);
		fuzzyWuzznt5 = makeNbest("fuzzy wuzznt was a bear", -5.0f);

		fuzzyWuzBest1 = makeNbest("fuzzy wuzzy was a bear", -1.0f);
		fuzzyWuzBest1.nbest.add(makeHyp("fuzzy wuzzy was not a bear", -2.0f));

		fuzzyWuzWorst1 = makeNbest("fuzzy wuzzy was not a bear", -1.0f);
		fuzzyWuzWorst1.nbest.add(makeHyp("fuzzy wuzzy was a bear", -2.0f));

		fuzzyWuzWorst5 = makeNbest("fuzzy wuzzy was not a bear", -5.0f);
		fuzzyWuzWorst5.nbest.add(makeHyp("fuzzy wuzzy was a bear", -6.0f));
	}

	@Test
	public void testHasReachabilityError() {
		Tristate emptyResult = cat.hasReachabilityError(desired, empty);
		Assert.assertSame(Tristate.TRUE, emptyResult);

		Tristate errorResult = cat.hasReachabilityError(desired, fuzzyWuzznt1);
		Assert.assertSame(Tristate.TRUE, errorResult);

		Tristate winResult = cat.hasReachabilityError(desired, fuzzyWuz1);
		Assert.assertSame(Tristate.FALSE, winResult);
	}

	@Test
	public void testHasSearchError() {
		Tristate emptyResult = cat.hasSearchError(desired, empty, fuzzyWuz1);
		Assert.assertSame(Tristate.UNKNOWN, emptyResult);

		Tristate errorResult = cat.hasSearchError(desired, fuzzyWuz1, fuzzyWuzznt1);
		Assert.assertSame(Tristate.TRUE, errorResult);

		Tristate winResult = cat.hasSearchError(desired, fuzzyWuz1, fuzzyWuz1);
		Assert.assertSame(Tristate.FALSE, winResult);
	}

	@Test
	public void testHasModelError() {

		// reachability error
		Tristate emptyResult = cat.hasModelError(desired, empty, fuzzyWuz1);
		Assert.assertSame(Tristate.UNKNOWN, emptyResult);
		
		// fuzzy in forced
		// but ties with wuzznt in vanilla
		Tristate tieWithOther = cat.hasModelError(desired, fuzzyWuzBest1, fuzzyWuzznt1);
		Assert.assertSame(Tristate.TRUE, tieWithOther);
		
		// fuzzy ties with itself in forced and vanilla
		Tristate bestInVanilla = cat.hasModelError(desired, fuzzyWuzBest1, fuzzyWuzBest1);
		Assert.assertSame(Tristate.FALSE, bestInVanilla);

		// fuzzy best in forced but worst in vanilla
		Tristate bestInForced = cat.hasModelError(desired, fuzzyWuzBest1, fuzzyWuzWorst5);
		Assert.assertSame(Tristate.FALSE, bestInForced);
		
		// fuzzy was the best in forced, but was not found in vanilla
		// because we diagnose with regard to the limited set of hypotheses
		// we will call this no model error conditioned on ranking the nbest + forced
		Tristate bestInForcedOnly = cat.hasModelError(desired, fuzzyWuzBest1, fuzzyWuzznt5);
		Assert.assertSame(Tristate.FALSE, bestInForcedOnly);
	}

	private NBestList makeNbest(String str, float d) {
		ArrayList<Hypothesis> winList = new ArrayList<Hypothesis>(1);
		winList.add(makeHyp(str, d));
		NBestList winForced = new NBestList(winList);
		return winForced;
	}

	private Hypothesis makeHyp(String str, float d) {
		Hypothesis hyp = new Hypothesis();
		hyp.yield = str;
		hyp.total = d;
		return hyp;
	}
}
