package failfinder.algs;

import java.util.List;
import java.util.Map;
import java.util.Set;

import failfinder.data.PartialHypothesis;

public class SearchPathAnalysis {
	public Map<PartialHypothesis, PartialHypothesis> f2vAlignment;
	public Set<Integer> errorSet;
	public List<Integer> errorFrontier;
}
