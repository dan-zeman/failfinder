package failfinder.algs;

import static org.junit.Assert.fail;

import java.util.ArrayList;

import org.junit.Assert;
import org.junit.Test;

import failfinder.algs.ErrorCategorizer.Tristate;
import failfinder.data.Hypothesis;
import failfinder.data.NBestList;

public class ErrorCategorizerTest {

	@Test
	public void testHasReachabilityError() {
		
		ErrorCategorizer cat = new ErrorCategorizer();
		
		// inputs
		String desired = "fuzzy wuzzy was a bear";
		NBestList emptyForced = new NBestList(new ArrayList<Hypothesis>(0));
		NBestList errorForced = makeNbest("fuzzy wuzznt was a bear");
		
		NBestList winForced = makeNbest("fuzzy wuzzy was a bear");

		Tristate emptyResult = cat.hasReachabilityError(desired, emptyForced);
		Assert.assertSame(Tristate.TRUE, emptyResult);
		
		Tristate errorResult = cat.hasReachabilityError(desired, errorForced);
		Assert.assertSame(Tristate.TRUE, errorResult);
		
		Tristate winResult = cat.hasReachabilityError(desired, winForced);
		Assert.assertSame(Tristate.FALSE, winResult);
	}

	private NBestList makeNbest(String str) {
		ArrayList<Hypothesis> winList = new ArrayList<Hypothesis>(1);
		Hypothesis hyp = new Hypothesis();
		hyp.yield = str;
		winList.add(hyp);
		NBestList winForced = new NBestList(winList);
		return winForced;
	}

	@Test
	public void testHasSearchError() {
		fail("Not yet implemented");
	}

	@Test
	public void testHasModelError() {
		fail("Not yet implemented");
	}

}
