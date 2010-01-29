package failfinder.data;

import java.util.HashSet;
import java.util.List;

public class NBestList {
	public final List<Hypothesis> nbest;
	public final HashSet<String> yields = new HashSet<String>();

	public NBestList(List<Hypothesis> nbest) {
		this.nbest = nbest;
		for (Hypothesis hyp : nbest) {
			yields.add(hyp.yield);
		}
	}

	public boolean contains(String desired) {
		return yields.contains(desired);
	}

	public float getBestScore() {
		if (nbest.size() == 0) {
			return Float.NEGATIVE_INFINITY;
		} else {
			float topbestScore = nbest.get(0).total;
			if (nbest.size() > 1) {
				float secondScore = nbest.get(1).total;
				if (topbestScore < secondScore) {
					throw new RuntimeException(
							"second-best score cannot be greater than topbest score. I thought we were using log probs...");
				}
			}
			return topbestScore;
		}
	}

	public float getBestScoreFor(String desired) {
		// TODO: hash
		for (Hypothesis hyp : nbest) {
			if (hyp.yield.equals(desired)) {
				return hyp.total;
			}
		}
		return Float.NEGATIVE_INFINITY;
	}

	public Hypothesis getBest() {
		if (nbest.size() > 0) {
			return nbest.get(0);
		} else {
			return null;
		}
	}
}
