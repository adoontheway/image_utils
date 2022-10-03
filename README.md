# ado_image

A flutter library intented to do some simple image process.


# Image 

## PNG
### five types of png
#### transformation of the reference image results i
* Truecolour with alpha: each pixel consists of four samples: red, green, blue, and alpha.
* Greyscale with alpha: each pixel consists of two samples: grey and alpha.
* Truecolour: each pixel consists of three samples: red, green, and blue. The alpha channel may be represented by a single pixel value. Matching pixels are fully transparent, and all others are fully opaque. If the alpha channel is not represented in this way, all pixels are fully opaque.
* Greyscale: each pixel consists of a single sample: grey. The alpha channel may be represented by a single pixel value as in the previous case. If the alpha channel is not represented in this way, all pixels are fully opaque.
* Indexed-colour: each pixel consists of an index into a palette (and into an associated table of alpha values, if present).
#### the pixel the samples appear 
* Truecolour with alpha: red, green, blue, alpha.
* Greyscale with alpha: grey, alpha.
* Truecolour: red, green, blue.
* Greyscale: grey.
* ghyr5tIndexed-colour: palette index.

## Reference
* [PNG Specification ](http://www.libpng.org/pub/png/spec/)
* [ PNG图像格式解析 ](https://blog.csdn.net/weixin_45715387/article/details/115181935)

