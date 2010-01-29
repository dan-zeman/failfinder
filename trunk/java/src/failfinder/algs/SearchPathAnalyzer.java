package failfinder.algs;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import failfinder.data.PartialHypothesis;
import failfinder.data.SearchPath;

public class SearchPathAnalyzer {

	// forced should be the smaller space for efficiency
	public SearchPathAnalysis align(SearchPath forced, SearchPath vanilla) {

		makeForwardPointers(forced);
		makeForwardPointers(vanilla);
		Map<PartialHypothesis, PartialHypothesis> f2v = match(forced, vanilla);
		
		SearchPathAnalysis spa = new SearchPathAnalysis();
		spa.errorSet = findErrorSet(forced, vanilla, f2v);
		spa.errorFronteir = findErrorFronteir(forced, vanilla, f2v, spa.errorSet);
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
	private List<Integer> findErrorFronteir(SearchPath forced, SearchPath vanilla,
			Map<PartialHypothesis, PartialHypothesis> f2v, Set<Integer> errorSet) {

		List<Integer> errorFronteir = new ArrayList<Integer>();

		for (PartialHypothesis forcedHyp : forced.searchVertices) {
			PartialHypothesis vanillaHyp = f2v.get(forcedHyp);
			if (vanillaHyp == null && errorFronteir.contains(forcedHyp.searchVertexId)) {
				errorFronteir.add(forcedHyp.searchVertexId);
			}
		}

		return errorFronteir;
	}
}
