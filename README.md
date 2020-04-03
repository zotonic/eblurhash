# eblurhash - Blurhash for Erlang

This is an Erlang version of https://blurha.sh

Use the `magick` function to first let imagemagick resize (and secure) the
image, before using the blurhash program to calculate the hash.

    eblurhash:magick("path/to/image.jpg").

Return something like:

    {ok, <<"MlMF%n00%#Mwo}S|WCWEM{a$R*bbWBbHfl">>}

**Note:** you will need to have ImageMagick installed

The `magick` command check the image size and selects optimal X and Y size for the blurhash.
Where X and Y are in the range 1..5.

The blurhash command can also be called directly:

    eblurhash:hash(5, 3, "path/to/image.jpg").

Note that this uses the C version of blurhash on the supplied image file.
The C version uses `stb_image` to load images, which is not security-hardened, so it
is **not** recommended to use this version in production on untrusted data!

