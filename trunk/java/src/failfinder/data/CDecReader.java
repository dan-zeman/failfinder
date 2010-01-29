package failfinder.data;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class CDecReader {
	public static List<NBestList> readNbest(File f) throws IOException {
		
		List<NBestList> allNbest = new ArrayList<NBestList>();
		List<Hypothesis> hyps = new ArrayList<Hypothesis>();
		
		BufferedReader in = new BufferedReader(new FileReader(f));
		String line;
		int prevId = 0;
		while ((line = in.readLine()) != null) {
			Scanner barScan = new Scanner(line).useDelimiter(" ||| ");
			Hypothesis hyp = new Hypothesis();

			int sentId = barScan.nextInt();
			if(sentId != prevId) {
				prevId = sentId;
				NBestList nbest = new NBestList(hyps);
				allNbest.add(nbest);
				hyps = new ArrayList<Hypothesis>();
			}
			hyp.yield = barScan.next();
			hyp.feats = PartialHypothesis.tokenizeFloats(barScan.next(), ";");
			hyp.total = barScan.nextFloat();
		}
		in.close();
		
		return allNbest;
	}
}
