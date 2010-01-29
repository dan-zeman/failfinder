package failfinder.data;

public class Hypothesis {
	public String yield;
	public float[] feats;
	public String[] featNames;
	public float total;
	
	public boolean equals(Object obj) {
		if(obj instanceof Hypothesis) {
			Hypothesis other = (Hypothesis) obj;
			return this.yield.equals(other.yield);
		} else {
			return false;
		}
	}
}
