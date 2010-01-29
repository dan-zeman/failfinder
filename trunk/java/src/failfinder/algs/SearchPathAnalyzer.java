package failfinder.algs;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import failfinder.data.PartialHypothesis;
import failfinder.data.SearchPath;

public class SearchPathAnalyzer {

	public void printAnalysis(int i, SearchPath forced, SearchPath vanilla) {
		SearchPathAnalysis analysis = analyze(forced, vanilla);
		System.out.println("Sentence: " + i);
		
		System.out.println("Forced Search Vertices: " + forced.searchVertices.size());
		System.out.println("Vanilla Search Vertices: " + vanilla.searchVertices.size());
		System.out.println("Aligned Search Vertices: " + analysis.f2vAlignment.size());
		System.out.println("All Error Vertices: " + analysis.errorSet.size());
		System.out.println("Frontier Error Vertices: " + analysis.errorFrontier.size());
		
		System.out.println("Error Frontier:");
		for (Integer id : analysis.errorFrontier) {
			PartialHypothesis hyp = forced.getVertex(id);
			System.out.println("\t" + hyp.toString());
		}
		System.out.println("Non-frontier Errors:");
		for (Integer id : analysis.errorSet) {
			if (!analysis.errorFrontier.contains(id)) {
				PartialHypothesis hyp = forced.getVertex(id);
				System.out.println("\t" + hyp.toString());
			}
		}
	}

	// forced should be the smaller space for efficiency
	public SearchPathAnalysis analyze(SearchPath forced, SearchPath vanilla) {

		makeForwardPointers(forced);
		makeForwardPointers(vanilla);

		SearchPathAnalysis spa = new SearchPathAnalysis();
		spa.f2vAlignment = match(forced, vanilla);
		spa.errorSet = findErrorSet(forced, vanilla, spa.f2vAlignment);
		spa.errorFrontier = findErrorFrontier(forced, vanilla, spa.f2vAlignment, spa.errorSet);
		return spa;
	}

	private Map<PartialHypothesis, PartialHypothesis> match(SearchPath forced, SearchPath vanilla) {

		// TODO: Don't use string
		// hash forced hyps by search state
		Map<String, PartialHypothesis> forcedHash = new HashMap<String, PartialHypothesis>();
		for (PartialHypothesis hyp : forced.searchVertices) {
			String key = makeKey(hyp);
			forcedHash.put(key, hyp);
		}

		// match vanilla hyps to them by search state
		Map<PartialHypothesis, PartialHypothesis> f2v =
				new HashMap<PartialHypothesis, PartialHypothesis>();
		for (PartialHypothesis vanillaHyp : vanilla.searchVertices) {
			String key = makeKey(vanillaHyp);
			PartialHypothesis forcedMatch = forcedHash.get(key);
			if (forcedMatch != null) {
				f2v.put(forcedMatch, vanillaHyp);
			}
		}
		return f2v;
	}

	private String makeKey(PartialHypothesis hyp) {
		return hyp.coverageVector + " ||| " + hyp.nontermLabel + " ||| " + hyp.yield;
	}

	private void makeForwardPointers(SearchPath forced) {
		for (PartialHypothesis hyp : forced.searchVertices) {
			int hypId = hyp.searchVertexId;
			for (int antId : hyp.antecedents) {
				PartialHypothesis ant = forced.getVertex(antId);
				ant.possibleContinuations.add(hypId);
			}
		}
	}

	// subtract vanilla from
	private Set<Integer> findErrorSet(SearchPath forced, SearchPath vanilla,
			Map<PartialHypothesis, PartialHypothesis> f2v) {

		Set<Integer> errorSet = new HashSet<Integer>();

		for (PartialHypothesis forcedHyp : forced.searchVertices) {
			PartialHypothesis vanillaHyp = f2v.get(forcedHyp);
			if (vanillaHyp == null) {
				errorSet.add(forcedHyp.searchVertexId);
			}
		}

		return errorSet;
	}

	// WARNING: We rely on the partial hypotheses being in search order
	private List<Integer> findErrorFrontier(SearchPath forced, SearchPath vanilla,
			Map<PartialHypothesis, PartialHypothesis> f2v, Set<Integer> errorSet) {

		List<Integer> errorFrontier = new ArrayList<Integer>();

		for (PartialHypothesis forcedHyp : forced.searchVertices) {
			PartialHypothesis vanillaHyp = f2v.get(forcedHyp);
			if (vanillaHyp == null) {
				boolean isFronteir = true;
				// TODO: traverse the graph properly instead of redoing work
				// here
				for (int ant : forcedHyp.antecedents) {
					if (errorFrontier.contains(ant)) {
						isFronteir = false;
					}
				}
				if (isFronteir) {
					errorFrontier.add(forcedHyp.searchVertexId);
				}
			}
		}

		return errorFrontier;
	}

	public static void main(String[] args) throws Exception {
		if (args.length != 2) {
			System.err.println("Usage: program forcedSearchPath vanillaSearchPath");
			System.exit(1);
		}

		System.err.println("Reading vanilla search paths...");
		List<SearchPath> vanilla = SearchPath.read(new File(args[0]));
		System.err.println("Reading forced search paths...");
		List<SearchPath> forced = SearchPath.read(new File(args[1]));
		// TODO: Populate lists iteratively

		SearchPathAnalyzer aFunk = new SearchPathAnalyzer();
		for (int i = 0; i < vanilla.size(); i++) {
			aFunk.printAnalysis(i, forced.get(i), vanilla.get(i));
		}
	}
}
