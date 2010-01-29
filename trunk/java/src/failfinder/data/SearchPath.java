package failfinder.data;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
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

	public static List<SearchPath> read(File f) throws IOException {

		List<SearchPath> allSearchPaths = new ArrayList<SearchPath>();
		List<PartialHypothesis> hyps = new ArrayList<PartialHypothesis>();
		
		BufferedReader in = new BufferedReader(new FileReader(f));
		String line;
		int prevId = 0;
		while ((line = in.readLine()) != null) {
			PartialHypothesis hyp = PartialHypothesis.parse(line);
			
			if(hyp.sentNum != prevId) {
				prevId = hyp.sentNum;
				SearchPath nbest = new SearchPath(hyps);
				allSearchPaths.add(nbest);
				hyps = new ArrayList<PartialHypothesis>();
			}
		}
		in.close();
		
		return allSearchPaths;
	}
}
