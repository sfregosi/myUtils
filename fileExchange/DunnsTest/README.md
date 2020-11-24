# dunn
Dunn procedure for multiple non parametric comparisons.<br/>
This file is applicable for equal or unequal sample sizes

Syntax: 	DUNN(X,GROUP, CTRL)
     
    Inputs:
          X: data vector
          GROUP - specifies grouping variables G. Grouping variables must
          have one column per element of X.
          CTRL - The first sample is a control group (1); there is not a
          control group (0). (default=0).
    Outputs:
          - Sum of ranks and Mean rank vectors for each group.
          - Ties factor
          - Q-value for each comparison.
          - Q critical value.
          - whether or not Ho is rejected.

          Created by Giuseppe Cardillo
          giuseppe.cardillo-edta@poste.it

To cite this file, this would be an appropriate format:
Cardillo G. (2006). Dunn's Test: a procedure for multiple, not
parametric, comparisons.
http://www.mathworks.com/matlabcentral/fileexchange/12827
