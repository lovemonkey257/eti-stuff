# Forked amendments
- Use of nlohmann/json library
- Addition of cmdline option "-J" to dump station details (creates file `ensemble-<channel>.json`)
- Addition of cmdline option "-x" to exit instead of play

# eti-cmdline

eti-cmdline is an experimental program for creating a stream of ETI frames 
from a selected DAB input channel. The program is fully command line driven.


## Table of Contents

* [Supported Devices](#supported-input-devices)
* [Installation under Windows](#installation-under-windows)
* [Installation Linux](#installation-under-linux)
* [Configuring CMake](#configuring-cmake)
* [Command line parameters](#command-line-parameters)
* [Writing to eti files](#writing-to-eti-files)
* [Piping to DABlin](#piping-to-dablin)
* [Copyright](#copyright)


## Supported input devices

eti-cmdline now supports a whole range of device (the device is for cmake command, see below):

    RTLSDR: for DABStickes based on Realtek 2832 chipset,
    AIRSPY: for Airspy R2 and Airspy mini devices (not for Airspy HF+),
    SDRPLAY: for SDRPlay RSP devices using the 2.13 SDRplay library,
    SDRPLAY_V3: for SDRPlay RSP devices using the 3.06/7 SDRplay library,
    PLUTO: for Adalm Pluto devices,
    HACKRF: for HackRF devices,
    LIMESDR: for LimeSDR devices
    RTL_TCP: for rtl_tcp input (and multiple DABsticks support),
    RAWFILES: for 8bit unsigned raw files
    WAVFILES: for 16bit wave files
    XMLFILES: for uff and xml files, created by Qt-DAB or Qirx


Of course one needs to have the library for device support installed.
Note that in the current version, no link to fftw libraries is needed,
the current version uses Kiss_fft.


## Installation under Windows

The directory contains a subdirectory "build-for-msvc" with the required
configuration files for compilation using MSVC. The configuration file
"eti-cmdline.vcxproj" is configured for the SDRplay device (using the 2.13
library). Change to your needs.


## Installation under Linux

For compiling and installing under Linux `cmake` needs to be installed. 

Note that for use of pluto both "libiio" and "libad9361" need to be
installed. Note further that older systems (e.g. Ubuntu 16.04) do not
have the correct implementations of these packages in their repositories


## Configuring CMake

The "normal" way for configuring and installing is 

   	mkdir build
  	cd build
   	cmake .. -DXXX=ON  [-DDUMPING=ON] [-DX64_DEFINED=ON|-DRPI_DEFINED=ON]
   	make

where XXX refers to the input device being supported, one of 
(RTLSDR, SDRPLAY, SDRPLAY_V3, AIRSPY, HACKRF, PLUTO, LIMESDR, RAWFILES, WAVFILES)

Note:
the SDRplay devices RSP 1, RSP II, RSP 1A, and RSP Duo are supported
by both the 2.13 library and the 3.0x library.
The RSP-Dx is only supported by the 3.0x library

Use `-DSDRPLAY=ON` for installing the support software linking to the 2.13 lib
Use `-DSDRPLAY_V3=ON` for installing the 3.0x support

If `-DDUMPING=ON` is added, the possibility for dumping the input to an ".sdr" 
file (note that an sdr-file is a ".wav" file, with a samplerate of 2048000 
and short int values).

If `-DX64_DEFINED=ON` is added, SSE instructions will be used in the viterbi decoding.

If `-DRPI_DEFINED=ON` is added and building takes place on an RPI, an attempt
is made to use neon insrtructions. Note however that there might
be problems with the toolchain: different toolchains require different
flags. See the section in the `CMakeLists.txt` file

The resulting program is named `eti-cmdline-XXX`, for XXX see above.

The command `(sudo) make install` will install the created executable in 
`/usr/local/bin` unless specified differently (note that it requires root permissions)


## Command line parameters

Once the executable is created, it needs to be told what channel you want to be read in and converted.

General parameters are

0. `-P number`, where the number indicates the degree of parallellism in the
processing of the subchannels
1. `-D number`, where number indicates the number of seconds used
   to collect information on the ensemble. The default value is 10.
   In 9 out of 10 cases, if no ensemble is detected within 10 seconds,
   there is none.
   
   Note that as soon as the software detects a DAB like signal, a message
   is printed (which can arrive as fast as in 1 or 2 seconds).
2. `-d number`, where number indicates the number of seconds used to wait for
    time synchronization. If time synchronization cannot be achieved within
    the specified time (default 5 seconds) it is pretty unlikely that a
    DAB signal is in the selected channel.
3. `-O filename`, for specifying the file onto which the ETI frames are written,
   "-O -" indicates that the output is to be written to stdout. Note that
   not specifying the "-O" option also causes the output to be written
   to stdout.

4. `-R filename`, for dumping the raw input to a file as mentioned above. This
   option only makes sense when dumping is configured.

For use with one of the physical devices, one may set the following parameters

5. `-B ("L_BAND" | "BAND III")` for selecting the band. Default BAND III is chosen.

6. `-C channel`,  for selecting the channel to be set, e.g. 11C, default 11C
   is chosen

7. `-S`, for silent processing, normally, while processing the program
shows a count on the amount of packages written on stderr.

For device specific settings: run `./eti-cmdline-xxx -h`


### Writing to eti files

Example:

	eti-cmdline-xxx -C 11C -G 80 > "11C_$(date +%F_%H%M).eti"
	
will write an ETI file (with date and time in the filename) to the current directory.

### Piping to dablin

You can use dablin or dablin_gtk from https://github.com/Opendigitalradio/dablin as a frontend by running
     
	eti-cmdline-xxx -C 11C -G 80 | dablin_gtk -L
     
where xxx refers to the input device being supported, one of (`rtlsdr`, `sdrplay`, `airspy`, `hackrf`, `limesdr', `rawfiles`, `wavfiles`).


## Copyright

	Copyright (C)  2016, 2017, 2018, 2019, 2020
	Jan van Katwijk (J.vanKatwijk@gmail.com)
	Lazy Chair Computing

The eti-cmdline software is made available under the GPL-2.0.
All SDR-J software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 See the GNU General Public License for more details.

