This app shows the bias-variance tradeoff with a simple smoothing model.

The bandwidth controls model flexibility. A small bandwidth follows the training data closely and can overfit. A large bandwidth creates a smoother model and can underfit.

The train error is computed on the observations used to fit the smoother. The test error is computed on held-out observations generated from the same process.

Errors are measured with **RMSE**: root mean squared error.

The best model is not always the one with the lowest train error. A useful model keeps test error low by balancing flexibility and stability.
