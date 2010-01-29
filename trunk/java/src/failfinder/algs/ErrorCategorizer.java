package failfinder.algs;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import failfinder.data.CDecReader;
import failfinder.data.Hypothesis;
import failfinder.data.NBestList;

public class ErrorCategorizer {

	public enum Tristate {
		TRUE, FALSE, UNKNOWN
	};
	
	int reachErrors = 0;
	int searchErrors = 0;
	int modelErrors = 0;
	
	private void printStats() {
		System.out.println();
		System.out.println("OVERALL");
		System.out.println("Reach  Errors: " + reachErrors);
		System.out.println("Search Errors: " + searchErrors);
		System.out.println("Model  Errors: " + modelErrors);
	}

	public void printCategorization(int i, String desired, NBestList forced, NBestList vanilla) {
		ErrorCategory cat = categorize(i, desired, forced, vanilla);
		System.out.println("Sentence: " + i);
		System.out.println("Reach  Error: " + cat.reachableError);
		System.out.println("Search Error: " + cat.searchError);
		System.out.println("Model  Error: " + cat.modelError);
		
		if(cat.reachableError == Tristate.TRUE) {
			reachErrors++;
		}
		if(cat.searchError == Tristate.TRUE) {
			searchErrors++;
		}
		if(cat.modelError == Tristate.TRUE) {
			modelErrors++;
		}
	}

	public ErrorCategory categorize(int i, String desired, NBestList forced, NBestList vanilla) {
		ErrorCategory cat = new ErrorCategory();
		cat.reachableError = hasReachabilityError(desired, forced);
		cat.searchError = hasSearchError(desired, forced, vanilla);
		cat.modelError = hasModelError(desired, forced, vanilla);
		return cat;
	}

	public Tristate hasReachabilityError(String desired, NBestList forced) {
		if (isReachable(desired, forced)) {
			return Tristate.FALSE;
		} else {
			return Tristate.TRUE;
		}
	}

	public Tristate hasSearchError(String desired, NBestList forced, NBestList vanilla) {
		if (isReachable(desired, forced) == false) {
			return Tristate.UNKNOWN;
		} else {
			if (vanilla.contains(desired)) {
				return Tristate.FALSE;
			} else {
				return Tristate.TRUE;
			}
		}
	}

	// was there model error WITH REGARD TO THE DESIRED HYPOTHESIS AND THE
	// BIASED PORTION
	// OF THE SEARCH SPACE REPRESENTED BY THE N-BEST LIST
	public Tristate hasModelError(String desired, NBestList forced, NBestList vanilla) {
		if (isReachable(desired, forced) == false) {
			return Tristate.UNKNOWN;
		} else {

			Hypothesis best = vanilla.getBest();
			if (best != null && best.yield.equals(desired)) {
				// desired was the best in the n-best list means instant success
				// TODO: was it the same as the 2nd best?
				return Tristate.FALSE;
			} else {

				// was not in the n-best list, was it in the force decode?
				float forcedScore = forced.getBestScoreFor(desired);
				float vanillaScore = vanilla.getBestScoreFor(desired);

				// calculate with regard to n-best list, so we don't have to
				// check this
				// if (vanillaScore == Float.NEGATIVE_INFINITY) {
				// // hypothesis was not in vanilla
				// // if we're
				// return Tristate.UNKNOWN;
				// }

				float desiredScore = Math.max(forcedScore, vanillaScore);
				float topbestScore = vanilla.getBestScore();

				// log probs, not costs
				// cannot be tied for top -- this actually constitutes a
				// model
				// error, too
				// strictly greater than!
				boolean isTop = (desiredScore > topbestScore);

				if (isTop) {
					return Tristate.FALSE;
				} else {
					return Tristate.TRUE;
				}
			}
		}
	}

	public boolean isReachable(String desired, NBestList forced) {
		return forced.contains(desired);
	}

	public static List<String> readDesired(File f) throws IOException {
		List<String> list = new ArrayList<String>();
		BufferedReader in = new BufferedReader(new FileReader(f));
		String line;
		while ((line = in.readLine()) != null) {
			list.add(line);
		}
		in.close();
		return list;
	}

	public static void main(String[] args) throws Exception {
		if (args.length != 3) {
			System.err.println("Usage: program vanillaNbest forcedNbest desiredList");
			System.exit(1);
		}

		List<NBestList> vanilla = CDecReader.readNbest(new File(args[0]));
		List<NBestList> forced = CDecReader.readNbest(new File(args[1]));
		List<String> desired = readDesired(new File(args[2]));
		// TODO: Populate lists iteratively

		ErrorCategorizer cat = new ErrorCategorizer();
		for (int i = 0; i < vanilla.size(); i++) {
			cat.printCategorization(i, desired.get(i), forced.get(i), vanilla.get(i));
		}
		cat.printStats();
	}
}