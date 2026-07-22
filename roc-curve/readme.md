This app shows how two score distributions and a classification threshold determine model performance. Scores at or above the threshold are predicted as positive; the colored regions correspond to true negatives, false positives, false negatives, and true positives.

**Theoretical** uses normal probability distributions to show population-level results. **Simulated** draws a reproducible sample and produces empirical densities, a stepwise ROC curve, and observed confusion-matrix counts. Changing the number of observations makes sampling variability easier to see.

The ROC curve compares the true positive rate with the false positive rate across all possible thresholds. Moving the threshold changes the current operating point and the metrics, but not the underlying sample.