package failfinder.data;

import java.util.ArrayList;
import java.util.List;

public class SearchPath {
	public final List<PartialHypothesis> searchVertices;
	
	// search vertices must be in search order
	public SearchPath(List<PartialHypothesis> searchVertices) {
		this.searchVertices = searchVertices;
	}
	
	public PartialHypothesis getVertex(int id) {
		return searchVertices.get(id);
	}
}
