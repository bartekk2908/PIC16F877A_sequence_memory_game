# PIC16F877A_sequence_memory_game

Simple game for PIC16F877A microcontroller that tests your sequence memory.

## Usage

You can run it on [PicSimLab](https://sourceforge.net/projects/picsim/) simulator.\
Run PicSimLab, select Board > Breadboard, Microcontroller > PIC16F877A, File > Load_Hex and select `sequence_memo.X.production.hex` file.\
Then go to Modules > Spare_parts, in second window go to File > Load_configuration and select `sequence_memo.pcf` file.\
Configuration shhould look like shown below

<img src="https://github.com/bartekk2908/PIC16F877A_sequence_memory_game/assets/104419783/4dd221c1-be24-44d0-a4c4-d94fd8dabdc8" width="500" />

<br />
<br />

Upper part is just set of eight leds that show you sequence and number of left lifes during a game.\
Bottom part is set of eight push buttons.

When you load `.hex` file, click any button to start a new game. After displayed sequence of colourful leds you have to click correct buttons under corresponding leds in same order as leds were lighted.\
Game starts with sequence of lenght 1 and will act correctly untill you get to the sequence of lenght 80. A sequence is being generated randomly. 
