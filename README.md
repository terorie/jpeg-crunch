### Processing JPEG Cruncher

Ever wondered what happens when you encode and decode an image 500 times
while removing a tiny amount of pixels each step?
Probably not because that's what happens to Internet memes all the time
when you screenshot-repost them on IG, 9gag and sadly, ifunny.

But looking at this from another angle we can conclude that
the resulting JPEG artifacts prove the quality of the meme.
It was screenshotted by lots of people after all.

Yes you can make your memes look popular!
Just let my JPEG cruncher run over it so hard that you can barely read 128px font!

*Requirements:*
 - Processing 3, open crunch.pde
 - Click play

*Sketch Controls:*
 - Click top half: Load & compress image
 - Click middle: Compress again
 - Click bottom half: Save compressed image

*Advanced options:*
 - Passes: How often to encode the image
 - Pixel percentage: Lower means less resolution
 - Crunch/Quality: JPEG quality setting
 - …
 - Procedurally scale image: Change the image size gradually each pass.
   Disabling this options scales the image down right at the beginning.

*Future:*
 - Different crunching algorithms (PNG, GIF)
 - Other scaling algorithms (nearest, area averaging …)
 - Other exporting algorithms
 - Video and image series export (Powered by FFMPEG)

##### 2017 by terorie
