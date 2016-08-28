README.md
=========

Build: `sbcl --load main.lisp build`, this will generate an executable file `slider`.

Play slideshow(test.lisp): `./slider test.lisp`

Key:

* j: next
* k: previous
* R: reload
* q: quit

Dependency:
* sbcl
* Quicklisp
* cl-ncurses(libncursesw.so.5)
* uffi

**Attention**: The uffi function "find-foreign-library" is broken, causing cl-ncurses can NOT load libncursesw by itself. If you got any trouble with loading libncursesw, you must edit the file "main.lisp", change the library path "/lib/x86_64-linux-gnu/libncursesw.so.5"(works in Debian Testing(2016)) to suit your Linux distribution.

<img src="./screenshot.jpg" />
