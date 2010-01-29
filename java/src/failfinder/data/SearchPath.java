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
		List<PartialHypothesis> hyps = new ArrayList<PartialHypothesis>(10000);
		
		BufferedReader in = new BufferedReader(new FileReader(f));
		String line;
		int prevId = 0;
		int nLine = 0;
		while ((line = in.readLine()) != null) {
			nLine++;
			if(nLine % 2500 == 0) {
				System.err.println("Read " + nLine + " so far...");
			}
			
			PartialHypothesis hyp = PartialHypothesis.parse(line);
			hyps.add(hyp);
			
			if(hyp.sentNum != prevId) {
				prevId = hyp.sentNum;
				allSearchPaths.add(new SearchPath(hyps));
				hyps = new ArrayList<PartialHypothesis>(10000);
			}
		}
		in.close();
		
		allSearchPaths.add(new SearchPath(hyps));
		return allSearchPaths;
	}
}
