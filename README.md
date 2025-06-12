# Summary

This is a simple openscad script you can use to generate a frame for a moxon rectangle antenna and print it on your 3D printer.

Just use a moxon online calculator and change the values for your desired frequency - then you can simply use some copper wire and snap it right in.

The intention was to use this to build cheap and simple antenna kits for kids, foxhunts etc.

![Moxon frame v1](https://github.com/gaspode-t-wonderdog/moxon-frame-generator/raw/main/images/moxon-frame_v1.png) 


# Further information

The script also lets you change a few few other variables, which should be self-explaining, except the "connector type" - the idea was to heat up and bend the end of the handle upwards, but you can also choose to have a simple screw hole for mounting it somewhere.

[Bild 2]

## difference between version 1 and version 2

The first version had a flat wire channel and was working quite well with thicker
copper wires but sometimes needs some glue for the wire to stay in.

The second version has a round recessed channel where the wire holds in by itself - and adds a hole where you can use side cutters to trim the wire.

![Moxon frame v2](https://github.com/gaspode-t-wonderdog/moxon-frame-generator/raw/main/images/moxon-frame_v2.png) 


This works better if you use a layer height <=0.15 for printing.

## Problems / TODO

While measuring our first antennas we found that they were way off - of course covering the antenna in plastic changes the frequency it operates at due to the dielectric property of the additional plastic. 
As the polymer increases the capacitance significantly, the antenna experiences capacitive shortening.


Currently we are in the phase of measuring antennas of different frequencies, various filament colors, materials and so on.

But for now it looks like we need a simple correction factor around 1.1 for the 1.0mm enameled copper wire and the PLA we are using.

![gnuplot](https://github.com/gaspode-t-wonderdog/moxon-frame-generator/raw/main/images/measurements.png) 



I'll update this when we come to a conclusion, build any revised models or get more measurements and I'll happily take your input and suggestions.
