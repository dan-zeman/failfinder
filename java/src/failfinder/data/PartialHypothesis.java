package failfinder.data;

import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import java.util.StringTokenizer;

public class PartialHypothesis extends Hypothesis {
	public int sentNum;
	public int searchVertexId;
	public String coverageVector;
	public int i;
	public int j;
	public String nontermLabel;
	public int[] antecedents;
	public String yield;
	public String[] featNames;
	public float[] feats;
	public float totalCost;
	public List<Integer> possibleContinuations = new ArrayList<Integer>();

	public static PartialHypothesis parse(String str) {
		PartialHypothesis hyp = new PartialHypothesis();

		Scanner barScan = new Scanner(str).useDelimiter(" \\|\\|\\| ");
		hyp.sentNum = barScan.nextInt();
		hyp.searchVertexId = barScan.nextInt();

		Scanner spanScan = new Scanner(barScan.next());
		hyp.i = spanScan.nextInt();
		hyp.j = spanScan.nextInt();
		hyp.nontermLabel = spanScan.next();

		hyp.antecedents = tokenizeInts(barScan.next(), ",");
		hyp.coverageVector = barScan.next();
		hyp.yield = barScan.next();
		tokenizeFeats(barScan.next(), hyp);
		hyp.totalCost = barScan.nextFloat();

		return hyp;
	}
	
	public static int[] tokenizeInts(String str, String delims) {
		StringTokenizer tok = new StringTokenizer(str, delims);
		int[] arr = new int[tok.countTokens()];
		for (int i = 0; i < arr.length; i++) {
			arr[i] = Integer.parseInt(tok.nextToken());
		}
		return arr;
	}

	public static void tokenizeFeats(String str, Hypothesis hyp) {

		StringTokenizer tok = new StringTokenizer(str, "; ");
		hyp.feats = new float[tok.countTokens()];
		hyp.featNames = new String[tok.countTokens()];
		for (int i = 0; i < hyp.feats.length; i++) {
			String pair = tok.nextToken();
			String[] nameValue = pair.split("=");
			hyp.featNames[i] = nameValue[0];
			hyp.feats[i] = Float.parseFloat(nameValue[1]);
		}
	}
	
	public static String untokenizeFeats(String[] featNames, float[] feats) {
		final StringBuilder builder = new StringBuilder();
		for (int i = 0; i < feats.length; i++) {
			builder.append(featNames[i] + "=" + feats[i] + ";");
		}

		if (builder.length() >= ";".length()) {
			builder.delete(builder.length() - ";".length(), builder.length());
		}

		return builder.toString();
	}

	public static String untokenizeInts(final int[] tokens, final String delim) {
		final StringBuilder builder = new StringBuilder();
		for (final int token : tokens)
			builder.append(token + delim);

		if (builder.length() >= delim.length())
			builder.delete(builder.length() - delim.length(), builder.length());

		return builder.toString();
	}

	public String toString() {
		String strAntecedents = untokenizeInts(antecedents, ",");
		String strFeatures = untokenizeFeats(featNames, feats);
		return String.format("%d ||| %d ||| %d %d %s ||| %s ||| %s ||| %s ||| %f", sentNum,
				searchVertexId, i, j, nontermLabel, strAntecedents, yield, strFeatures, totalCost);
	}
}
