package failfinder.algs;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import failfinder.data.CDecReader;
import failfinder.data.NBestList;

public class ErrorCategorizer {

	public enum Tristate {
		TRUE, FALSE, UNKNOWN
	};

	public void printCategorization(int i, String desired, NBestList forced, NBestList vanilla) {
		ErrorCategory cat = categorize(i, desired, forced, vanilla);
		System.out.println("Sentence: " + i);
		System.out.println("Reachable: " + cat.reachable);
		System.out.println("Search Error: " + cat.searchError);
		System.out.println("Model Error: " + cat.modelError);
	}
	
	public ErrorCategory categorize(int i, String desired, NBestList forced, NBestList vanilla) {
		ErrorCategory cat = new ErrorCategory();
		cat.reachable = hasReachabilityError(desired, forced);
		cat.searchError = hasReachabilityError(desired, forced);
		cat.modelError = hasReachabilityError(desired, forced);
		return cat;
	}

	public Tristate hasReachabilityError(String desired, NBestList forced) {
		if (isReachable(desired, forced)) {
			return Tristate.TRUE;
		} else {
			return Tristate.FALSE;
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

	public Tristate hasModelError(String desired, NBestList forced, NBestList vanilla) {
		if (isReachable(desired, forced) == false) {
			return Tristate.UNKNOWN;
		} else {

			float forcedScore = forced.getBestScoreFor(desired);
			float vanillaScore = vanilla.getBestScoreFor(desired);
			float scoreOfDesired = Math.max(forcedScore, vanillaScore);
			float topbestScore = vanilla.getBestScore();

			// log probs, not costs
			// cannot be tied for top -- this actually constitutes a model
			// error, too
			// strictly greater than!
			boolean isTop = (scoreOfDesired > topbestScore);

			if (isTop) {
				return Tristate.FALSE;
			} else {
				return Tristate.TRUE;
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
		if (args.length != 1) {
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
	}
}
