------------------------------------------------------------------------------------
LBA Shape Editor
 editing lsh (shape) files from Little Big Adventure 2 (47th entry of ress.hqr)

Copyright (C) 2003/2004 Zink

     Version: 0.01
Release date: 23.07.2004
      Status: Freeware (GNU GPL license).
      E-mail: zink@poczta.onet.pl - any feedback is welcome

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details (License.txt).
------------------------------------------------------------------------------------

### Description:

 With this program you can edit shape file from LBA 2. This file contains shapes (some kind of vector graphics) such as: stars flying out of Twinsen when he gets hurt, and so on. Anyway, there are some of them, that I never saw in the game... 

 It was assumed to be simple, and I think it is. 
 The file generally contains some shapes, which can be chosen from the top of the window, then you may specify the colour in which the shape will be displayed in the game (the colour is index in the pallette). Each shape is made of "points" and "lines". Points are just pairs of coordinates, and lines are pairs of point numbers. It means, that one line consists of two numbers describing two points. Then these points consist of coordinates, so if, for example, a line's starting point is point no. 4 and this point's coordinates are (13,-43), the game will start drawing the line from point (13,-43), and will end somewhere where the ending point of the line is. 
 Points are not visible, they are only couples of coordinates for use by lines.

 This program was made quick and it has bugs, I know that :) It also doesn't have almost any error checking, so be careful and don't try to save a file until you have one opened ;)

 It is possible that there will not be any future version of this program (because this version will probably be sufficient for everyone), however, you may request a feature if you wish. If you do so, it will be considered.