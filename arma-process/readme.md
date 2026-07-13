An **ARMA process** combines two simple ideas: dependence on previous values and dependence on previous random shocks.

A simple \\(ARMA(1, 1)\\) model can be written as:

\\[
X_t = c + \\phi X_{t-1} + \\epsilon_t + \\theta \\epsilon_{t-1},
\\quad \\epsilon_t \\sim WN(0, \\sigma^2).
\\]

In this app, **AR** controls \\(\\phi\\) and **MA** controls \\(\\theta\\).

The **AR** slider controls how much the current value follows the previous value. Positive values create persistence, while negative values create alternation.

The **MA** slider controls how much the previous shock affects the current value.

The ACF and PACF panels compare the theoretical pattern with the pattern estimated from the simulated series as new observations arrive.
