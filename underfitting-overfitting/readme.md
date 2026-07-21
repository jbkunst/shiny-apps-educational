This app shows how model flexibility can produce underfitting or overfitting.

The bandwidth controls the kernel smoother. A small bandwidth creates a flexible model that can follow noise in the training data. A large bandwidth creates a smoother model that can miss the underlying relationship.

Training data are always visible. Turn on **Show test data** to see how the fitted model behaves on unseen observations from the same process.

Turn on **Show true relationship** to compare the fitted model with the function that generated the data.

Errors are measured with **RMSE**: root mean squared error. A useful model should not only fit the training observations; it should also keep test error low.
