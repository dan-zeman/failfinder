package failfinder.data;

import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class PartialHypothesis {
	public int sentNum;
	public int searchVertexId;
	public String coverageVector;
	public int i;
	public int j;
	public String nontermLabel;
	public int[] antecedents;
	public String yield;
	public float[] feats;
	public float totalCost;
	public List<Integer> possibleContinuations = new ArrayList<Integer>();

	public static PartialHypothesis parse(String str) {
		PartialHypothesis hyp = new PartialHypothesis();
		
		Scanner barScan = new Scanner(str);
		barScan.useDelimiter(" ||| ");
		hyp.sentNum = barScan.nextInt();
		hyp.searchVertexId = barScan.nextInt();
		
		Scanner spanScan = new Scanner(barScan.next());
		hyp.i = spanScan.nextInt();
		hyp.j = spanScan.nextInt();
		hyp.nontermLabel = spanScan.next();
		
		hyp.antecedents = tokenizeInts(barScan.next(), ",");
		hyp.yield = barScan.next();
		hyp.feats = tokenizeFloats(barScan.next(), " ");
		hyp.totalCost = barScan.nextFloat();
		
		return hyp;
	}

	public static float[] tokenizeFloats(String next, String string) {
		// TODO Auto-generated method stub
		return null;
	}

	public static int[] tokenizeInts(String next, String string) {
		// TODO Auto-generated method stub
		return null;
	}

	public String toString() {
		String strAntecedents = "TODO";
		String strFeatures = "TODO";
		return String.format("%d ||| %d ||| %d %d %s ||| %s ||| %s ||| %f", sentNum, searchVertexId,
				i, j, nontermLabel, strAntecedents, yield, strFeatures, totalCost);
	}
}
