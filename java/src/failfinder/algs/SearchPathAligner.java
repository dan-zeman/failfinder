package failfinder.algs;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Queue;

import failfinder.data.PartialHypothesis;
import failfinder.data.SearchPath;

public class SearchPathAligner {
	
	public Map<PartialHypothesis, PartialHypothesis> align(SearchPath forced, SearchPath vanilla) {
		
		List<PartialHypothesis> errorFronteir = new ArrayList<PartialHypothesis>();
		Map<PartialHypothesis, PartialHypothesis> f2v = new HashMap<PartialHypothesis, PartialHypothesis>();
		
		// initialize by zipping at bottom and then maintain fronteir as a queue
		Queue<PartialHypothesis> matchFronteirForced = seed(f2v, errorFronteir, forced, vanilla);
		
		// list of nodes where the forced search path continues
		// but the vanilla search path ends
		match(f2v, matchFronteirForced, errorFronteir, forced, vanilla);
		
		// TODO: Return error fronteir, too
		return f2v;
	}
	
	private Queue<PartialHypothesis> seed(Map<PartialHypothesis, PartialHypothesis> f2v,
			List<PartialHypothesis> errorFronteir, SearchPath forced, SearchPath vanilla) {
		
		// the next vertices waiting to be matched -- for match method
		Queue<PartialHypothesis> matchFronteir = new LinkedList<PartialHypothesis>();
		
		Map<String, PartialHypothesis> forcedLeaves = new HashMap<String, PartialHypothesis>(); 
		for(PartialHypothesis hyp : forced.searchVertices) {
			if(hyp.antecedents.length == 0) {
				forcedLeaves.put(hyp.yield, hyp);
				matchFronteir.add(hyp);
			}
		}
		
		for(PartialHypothesis vanillaHyp : vanilla.searchVertices) {
			if(vanillaHyp.antecedents.length == 0) {
				PartialHypothesis forcedMatch = forcedLeaves.get(vanillaHyp.yield);
				if(forcedMatch != null) {
					f2v.put(forcedMatch, vanillaHyp);
				} else {
					// NOTE: The antecedents tell us the parents
					errorFronteir.add(forcedMatch);
				}
			}
		}
		
		return matchFronteir;
	}

	// WARNING: We rely on the partial hypotheses being in search order
	private void match(Map<PartialHypothesis, PartialHypothesis> f2v, Queue<PartialHypothesis> matchFronteirForced,
			List<PartialHypothesis> errorFronteir, SearchPath forced, SearchPath vanilla) {
	
		// NOTE: We are not matching based on feature states here!
		while(!matchFronteirForced.isEmpty()) {
			PartialHypothesis forcedHyp = matchFronteirForced.poll();
			PartialHypothesis vanillaHyp = f2v.get(forcedHyp);
			assert vanillaHyp != null : "forcedHyp should have been on error fronteir if it isn't aligned.";
			
			// need forward pointers?
		}
	}
}
