# Si Extension For Quarto

This extension creates a shortcode `si` for setting SI values and units. 

## Installing


```bash
quarto add GeorgRamer/si
```

This will install the extension under the `_extensions` subdirectory.
If you're using version control, you will want to check in this directory.

## Using



This extension creates a shortcode `si` for setting SI values and units. The structure of the shortcode is as follows 

```{shortcodes=false}
{{< si 1.45 m s-1 >}}
```

Briefly, this extensions reformats the space separated items inside the shortcode into a series of formatted entries. 
All spaces are converted to non-breaking spaces. 
Trailing numbers are formatted as exponents. Some other helpful functions are conversion of `+-` into `±`, some shortcuts for harder to type units such as 
`Å` and `Ω` and rewritting of `E` exponents into `⨉10`. 

Because the output is purely unicode, subscripts and superscripts, this extension is fairly agnostic in terms of output formats: HTML, Typst and LaTeX have been tested and work. 
There is no obvious reason why other formats would not work. 

## Example

More examples of this short code can be found in [example.qmd](example.qmd).

