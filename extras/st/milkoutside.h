/* Terminal colors (16 first used in escape sequence) */
static const char *colorname[] = {
    /* 8 normal colors */
    "#000000",
    "#fda1a0",
    "#92cf9c",
    "#f8e063",
    "#63c3dd",
    "#e79cfb",
    "#7dcfff",
    "#e0e0e0",

    /* 8 bright colors */

    "#303030",
    "#fda1a0",
    "#92cf9c",
    "#ffad00",
    "#62b9e8",
    "#f93a82",
    "#4fd1e0",
    "#e8e8e8",

    [255] = 0,

    /* more colors can be added after 255 to use with DefaultXX */
    "#e8e8e8",
    "#394b70",
    "#e8e8e8", /* default foreground colour */
    "#040607", /* default background colour */
};

/*
 * Default colors (colorname index)
 * foreground, background, cursor, reverse cursor
 */
unsigned int defaultfg = 258;
unsigned int defaultbg = 259;
unsigned int defaultcs = 256;
static unsigned int defaultrcs = 257;
