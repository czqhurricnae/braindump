(TeX-add-style-hook
 "flask-0.1"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-class-options
                     '(("ctexart" "20pt")))
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("fontenc" "T1") ("ulem" "normalem") ("hyperref" "colorlinks" "linkcolor=black" "anchorcolor=black" "citecolor=black") ("geometry" "top=2.54cm" "bottom=2.54cm" "left=3.17cm" "right=3.17cm")))
   (add-to-list 'LaTeX-verbatim-environments-local "lstlisting")
   (add-to-list 'LaTeX-verbatim-environments-local "minted")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "url")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "nolinkurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperbaseurl")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperimage")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "hyperref")
   (add-to-list 'LaTeX-verbatim-macros-with-braces-local "lstinline")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "path")
   (add-to-list 'LaTeX-verbatim-macros-with-delims-local "lstinline")
   (TeX-run-style-hooks
    "latex2e"
    "ctexart"
    "ctexart10"
    "xeCJK"
    "fontenc"
    "fixltx2e"
    "graphicx"
    "longtable"
    "float"
    "wrapfig"
    "rotating"
    "ulem"
    "amsmath"
    "textcomp"
    "marvosym"
    "wasysym"
    "amssymb"
    "booktabs"
    "hyperref"
    "listings"
    "xcolor"
    "parskip"
    "minted"
    "color"
    "tikz"
    "CJKulem"
    "geometry")
   (LaTeX-add-labels
    "sec:org575fed7"
    "sec:org3066b27"
    "sec:org087781c"
    "sec:org4488ca0"
    "sec:orge68f23a"
    "sec:org6e01a86"
    "sec:org75703e1"
    "sec:orgf7a1455"
    "sec:org29c4795"
    "MapAdapter 类实例调用 match 时实例的参数"
    "sec:orge59eca0"
    "sec:org7219229"
    "sec:orga170e31"))
 :latex)

