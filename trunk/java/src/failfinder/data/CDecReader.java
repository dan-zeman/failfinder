package failfinder.data;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.InputMismatchException;
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
			try {
				Scanner barScan = new Scanner(line).useDelimiter(" \\|\\|\\| ");

				int sentId = barScan.nextInt();
				if (sentId != prevId) {
					prevId = sentId;
					allNbest.add(new NBestList(hyps));
					hyps = new ArrayList<Hypothesis>();
				}

				Hypothesis hyp = new Hypothesis();
				hyp.yield = barScan.next();
				PartialHypothesis.tokenizeFeats(barScan.next(), hyp);
				hyp.total = barScan.nextFloat();
				hyps.add(hyp);
			} catch (InputMismatchException e) {
				System.err.println(line);
				throw e;
			}
		}
		in.close();

		allNbest.add(new NBestList(hyps));
		return allNbest;
	}
}
