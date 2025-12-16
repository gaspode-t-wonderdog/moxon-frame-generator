# Summary

This is a simple OpenSCAD script you can use to generate a frame for a moxon rectangle antenna and print it on your 3D printer.

"The Moxon rectangle is a 2-element parasitical beam or unidirectional antenna about 70% the length of a full size 2-element Yagi of standard driver-reflector design."
according to antenna2.net and conveniently comes with 50 Ohms impedance right out the box.

The original intention was to use this to assemble cheap and simple antenna kits for foxhunts with kids which can be attached right away to your handheld radio, but it's not limited to this usecase.

![Moxon frame v1](https://github.com/gaspode-t-wonderdog/moxon-frame-generator/raw/main/images/moxon-frame_v1.png)



# Further information

The script also lets you change variables, which should be self-explaining, except the "connector type" - 
the idea was to heat up and bend the end of the handle upwards, but you can also choose to have a simple screw hole for mounting it somewhere.

![prototype](https://github.com/gaspode-t-wonderdog/moxon-frame-generator/raw/main/images/photo1.jpg)

I'm open for suggestions for better mounting options.


## difference between versions

The first version had a flat wire channel and was working quite well with thicker
copper wires but sometimes needed some glue for the wire to stay in.

The second version has a round recessed channel where the wire holds in by itself - and adds a hole where you can use side cutters to trim the wire.

![Moxon frame v2](https://github.com/gaspode-t-wonderdog/moxon-frame-generator/raw/main/images/moxon-frame_v2.png)

This works better if you use a layer height <=0.15mm for printing.

For version 3 @gretel (DO2THX) added the calculation logic (based on the online calculator from antenna2.net) to the OpenSCAD script.

I still like to keep version 2 around, in case anyone wants to experiment with their own values.


## about correction factors

While measuring our first antennas we found that they were way off - of course covering the antenna in plastic changes the frequency it operates at due to the dielectric property of the additional plastic. 
As the polymer increases the capacitance significantly, the antenna experiences capacitive shortening.

So we need a correction factor (or velocity factor) to achieve the desired resonating frequency.


## printing

Either you trust our conclusion (see measurements below), that it always ends up with a factor of around 1.1, or you have to figure it out by yourself.

To do so the best strategy would be:

- For Version 2 calculate the antenna for your desired frequency with your favourite online calculator (I'd recommend https://antenna2.github.io/cebik/content/moxon/moxpage.html),
enter the values inside the script
- For Version 3 enter the frequency right on top and set the "correction_factor" to 1.0

Print and assemble the antenna, measure it with a VNA to find out at which frequency it plays best and divide desired_frequency / actual_frequency - that's your correction factor.

Now reprint by either calculating it for your_desired_frequency * factor or simply change the "correction_factor" in Version 3 of the script.


## connectors

There are various connector types and I only implemented those we had lying around, but it's also quite easy to add your own.
I'll add pics of the current types later.


## Assembly

- To set the wire you should roughly prepare the needed lenght first, and consider to prepare the wire for soldering beforehand.
	-   To set the wire inside the groove, start at the feedpoint, then firmly press the conductor down with the help of a solid plastic object.
    follow the groove all the way around and pay great attention to detail at the bends (those tend to be stubborn)
	- If it doesn't fit perfectly, adjust the "dia" variable in v2 or the "wire_tolerance" variable in version 3 and reprint.

- Cutting the conductor. Cutting the conductor at it's designated spots is simply done with flush cutters.
    press firmly against the frame so there is no overhang of wire within the gap. (in some cases, you might want to temporarily remove the wire)
	- Depending on the frequency, cutting it flush against the gap, is more difficult. the cut needs to be square to be most acurate.

- Optionally bend the boom at the end to attach the frame directly to your handheld radio. Heat the boom and bend to taste (OwO)
	- Use a heat gun or a lighter (this will take time in any way you do it - don't rush it or it'll char - as seen in the picture above)

- After setting the connector, you need to bridge the distance with 50 Ohm coaxial conductor like RG58 RG174 or similar. Take time for soldering.


I'll also add some detailed pictures later.


# Measurements

We did some measurements to figure out the correction factor for different frequencies and we planned to do more for various materials, filament colors and so on...
but due to a lack of time that didn't happen yet :) - but for most materials we ended up with a factor of around 1.1
(only higher frequencies (> 1 GHz) seem to be a bit off).

Here are some measurements for eSUN-PLA+:

![gnuplot](https://github.com/gaspode-t-wonderdog/moxon-frame-generator/raw/main/images/measurements.png)


# kthxbye

I'll happily take your input and suggestions, especially about mounting, adding more connectors and so on.

There's also a cubical quad antenna in the making, using similiar techniques. Stay tuned!
