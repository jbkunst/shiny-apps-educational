In evey image each pixel have a color and every color have an rgb representation (a 3-coordinates point), so we can group the colors into clusters and see what happens.

The idea behind this app is taken from [dsparks' kmeans palette](https://gist.github.com/dsparks/3980277). I just add some features like 3d scatterplot and migrate the code to a shiny app. Feel free to make some comments in the [repository](https://github.com/jbkunst/shiny-apps).

Packages used: shiny, dplyr, jpeg, tidyr, ggplot2, scales, threejs.

Code by [Joshua Kunst](http://jkunst.com) | Repo [here](https://github.com/jbkunst/shiny-apps/tree/master/kmeans-images).
