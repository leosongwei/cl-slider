(ql:quickload 'cl-ncurses)

(defpackage slider
  (:use #:cl-ncurses #:cl #:cl-user #:uffi))

(in-package slider)

(defmacro with-cs (s &body body)
  `(let ,(mapcar (lambda (s)
                   (if (and (consp s)
                            (= 2 (length s)))
                     `(,(car s) (convert-to-cstring ,(cadr s)))
                     (error "with-cs: wrong pattern")))
                 s)
     ,@body
     ,@(mapcar (lambda (s) `(free-cstring ,(car s))) s)))

(defstruct as
  reverse bold underline)
(defparameter as-current (make-as :reverse nil
                                  :bold nil
                                  :underline nil))
(defparameter as-stack '())

(defun set-as (as lst)
  (dolist (i lst)
    (case i
      (reverse (setf (as-reverse as) t))
      (bold (setf (as-bold as) t))
      (underline (setf (as-underline as) t)))))

(defun copy-as (old)
  (let ((new (make-as)))
    (setf (as-reverse new) (as-reverse old))
    (setf (as-bold new) (as-bold old))
    (setf (as-underline new) (as-underline old))
    new))

(defun apply-as (as)
  (if (as-reverse as) (attron a_reverse))
  (if (as-bold as) (attron a_bold))
  (if (as-underline as) (attron a_underline)))

(defun cancel-as (as)
  (if (as-reverse as) (attroff a_reverse))
  (if (as-bold as) (attroff a_bold))
  (if (as-underline as) (attroff a_underline)))

(defmacro with-attr (attrs &body body)
  (let ((newas (gensym)))
    `(progn (push (copy-as as-current) as-stack)
            (let ((,newas (make-as)))
              (set-as ,newas (quote ,attrs))
              (setf as-current ,newas)
              (apply-as as-current)
              ,@body
              (cancel-as as-current)
              (setf as-current (pop as-stack))
              (apply-as as-current)))))

(defparameter *color-table* (make-hash-table))
(defun set-color-table (color-list)
  (dolist (i color-list)
    (let ((color (car i))
          (c (cdr i)))
      (setf (gethash color *color-table*) c))))
(set-color-table '((black . color_black)
                   (red . color_red)
                   (green . color_green)
                   (yellow . color_yellow)
                   (blue . color_blue)
                   (magenta . color_magenta)
                   (cyan . color_cyan)
                   (white . color_white)))
(defun get-color (c) (gethash c *color-table*))

(defun init-color-ncurses ()
  (start-color)
  (init-pair COLOR_BLACK   COLOR_BLACK   COLOR_BLACK)
  (init-pair COLOR_GREEN   COLOR_GREEN   COLOR_BLACK)
  (init-pair COLOR_RED     COLOR_RED     COLOR_BLACK)
  (init-pair COLOR_CYAN    COLOR_CYAN    COLOR_BLACK)
  (init-pair COLOR_WHITE   COLOR_WHITE   COLOR_BLACK)
  (init-pair COLOR_MAGENTA COLOR_MAGENTA COLOR_BLACK)
  (init-pair COLOR_BLUE    COLOR_BLUE    COLOR_BLACK)
  (init-pair COLOR_YELLOW  COLOR_YELLOW  COLOR_BLACK)
  (init-pair 80 color_white color_black)
  (bkgd (color-pair 80)))

(defun set-background (color)
  (let ((bg (eval (let ((c (get-color color)))
                    (if c c 'COLOR_BLACK)))))
    (init-pair COLOR_BLACK   COLOR_BLACK   bg)
    (init-pair COLOR_GREEN   COLOR_GREEN   bg)
    (init-pair COLOR_RED     COLOR_RED     bg)
    (init-pair COLOR_CYAN    COLOR_CYAN    bg)
    (init-pair COLOR_WHITE   COLOR_WHITE   bg)
    (init-pair COLOR_MAGENTA COLOR_MAGENTA bg)
    (init-pair COLOR_BLUE    COLOR_BLUE    bg)
    (init-pair COLOR_YELLOW  COLOR_YELLOW  bg)
    (init-pair 80 color_white bg)
    (bkgd (color-pair 80))))

(defparameter color-stack '())
(defparameter color-current 0)

(defmacro with-color (color &body body)
  `(progn (push color-current color-stack)
          (setf color-current ,(get-color color))
          (attron (color-pair color-current))
          ,@body
          (attroff (color-pair color-current))
          (setf color-current (pop color-stack))
          (attron (color-pair color-current))))

(defun gen-render-code (render-exp)
  (if (consp render-exp)
    (case (car render-exp)
      (body `(progn ,@(mapcar #'gen-render-code (cdr render-exp))))
      (reverse (macroexpand
                 `(with-attr (reverse)
                    ,@(mapcar #'gen-render-code (cdr render-exp)))))
      (bold (macroexpand
              `(with-attr (bold)
                 ,@(mapcar #'gen-render-code (cdr render-exp)))))
      (underline (macroexpand
                   `(with-attr (underline)
                      ,@(mapcar #'gen-render-code (cdr render-exp)))))
      (br '(wprintw *stdscr* (format nil "~%")))
      (brer (let (stack r)
              (mapcar (lambda (x)
                        (push (gen-render-code x) stack)
                        (push (gen-render-code '(br)) stack))
                      (cdr render-exp))
              (dolist (i stack) (push i r))
              (append '(progn) r)))
      (color (macroexpand
               `(with-color ,(let ((c (cadr render-exp)))
                               (if (get-color c)
                                 c 'black))
                  ,@(mapcar #'gen-render-code (cddr render-exp)))))
      (lisp (cadr render-exp))
      (t (format t "gen-render-code: warning!! illegal tag: ~A~%"
                 render-exp)))
    (if (stringp render-exp)
      (let ((token (gensym)))
        (macroexpand `(with-cs ((,token ,render-exp))
                        (wprintw *stdscr* ,token))))
      (let ((str (format nil "*~A*" render-exp))
            (token (gensym)))
        (macroexpand `(with-cs ((,token ,str))
                        (wprintw *stdscr* ,token)))))))

(defun init-mainwindow ()
  (initscr)
  (raw)
  (noecho)
  (curs-set 0)
  (init-color-ncurses)
  (clear)
  (refresh))

(defun draw-slide (slide)
  (standend)
  (move 0 0)
  (setf color-current 0)
  (setf color-stack nil)
  (setf as-current (make-as))
  (setf as-stack nil)
  (init-color-ncurses)
  (funcall slide))

(defun make-slide (sexp)
  (let ((body nil)
        (bg nil))
    (if (equal :background (nth 1 sexp))
      (progn (setf bg `(set-background (quote ,(nth 2 sexp))))
             (setf body (nth 3 sexp)))
      (progn (setf bg `(set-background 'black))
             (setf body (nth 1 sexp))))
    (eval
      `(lambda ()
         ,bg
         ,(gen-render-code body)))))

(defun read-file (path)
  (let (r s)
    (with-open-file (in path :direction :input)
      (tagbody :start
               (let ((i (read in nil)))
                 (if i
                   (progn (push i s)
                          (go :start))
                   (go :end)))
               :end))
    (dolist (i s)
      (push i r))
    r))

(defparameter *index* 0)
(defparameter *renderers* nil)

(defun slideshow-length ()
  (array-dimension *renderers* 0))

(defun reload-slide ()
  (let* ((path (nth 1 sb-ext:*posix-argv*))
         (s (read-file path))
         (length (length s))
         (renderers (make-array length)))
    (let ((i 0))
      (dolist (e s)
        (setf (aref renderers i)
              (make-slide e))
        (incf i)))
    (setf *renderers* renderers)))

(defun draw-bottom-panel ()
  (let ((banner (format nil "~A/~A"
                        (1+ *index*)
                        (slideshow-length))))
    (with-cs ((c_banner banner)
              (c_space " "))
      (with-color black
        (with-attr (reverse bold)
          (dotimes (x *cols*)
            (mvprintw (1- *lines*) x c_space))
          (mvprintw (1- *lines*)
                    0
                    c_banner))))))

(defun main-loop ()
  (loop
    (let ((keystroke (code-char (getch))))
      (case keystroke
        (#\j
         (incf *index*))
        (#\k
         (decf *index*))
        (#\q
         (progn
           (clear)
           (endwin)
           (sb-ext:exit)))
        (#\R
         (reload-slide)))
      (progn
        (cond ((>= *index* (slideshow-length))
               (setf *index* 0))
              ((< *index* 0)
               (setf *index* (1- (slideshow-length)))))
        (clear)
        (draw-slide (aref *renderers* *index*))
        (draw-bottom-panel)
        (refresh)))))

(defun main ()
  (reload-slide)
  (init-mainwindow)
  (main-loop))

(main)

;(sb-ext:save-lisp-and-die "slider" :executable t :compression 3 :toplevel #'slider:main)
