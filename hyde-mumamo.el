;; Mumamo Mode for hyde pages
;; by Lakshmi Vyas

;; Influenced by Jorge Dias' jekyll-mode
;; https://github.com/diasjorge/jekyll.el/blob/master/jekyll-mumamo.el

;; and Gearge Brandl's jinja-mode
;; https://raw.github.com/mitsuhiko/jinja2/master/ext/jinja.el

(defconst jinja-font-lock-keywords
  (list
;   (cons (rx "{% comment %}" (submatch (0+ anything))
;             "{% endcomment %}") (list 1 font-lock-comment-face))
   '("{# ?\\(.*?\\) ?#}" . (1 font-lock-comment-face))
   '("{%-?\\|-?%}\\|{{\\|}}" . font-lock-preprocessor-face)
   '("{#\\|#}" . font-lock-comment-delimiter-face)
   ;; first word in a block is a command
   '("{%-?[ \t\n]*\\([a-zA-Z_]+\\)" . (1 font-lock-keyword-face))
   ;; variables
   '("\\({{ ?\\)\\([^|]*?\\)\\(|.*?\\)? ?}}" . (1 font-lock-variable-name-face))
   ;; keywords and builtins
   (cons (rx word-start
             (or "in" "as" "recursive" "not" "and" "or" "if" "else"
                 "import" "with" "without" "context")
             word-end)
         font-lock-keyword-face)
   (cons (rx word-start
             (or "true" "false" "none" "loop" "self" "super")
             word-end)
         font-lock-builtin-face)
   ;; tests
   '("\\(is\\)[ \t]*\\(not\\)[ \t]*\\([a-zA-Z_]+\\)"
     (1 font-lock-keyword-face) (2 font-lock-keyword-face)
     (3 font-lock-function-name-face))
   ;; builtin filters
   (cons (rx
          "|" (* space)
          (submatch
           (or "abs" "batch" "capitalize" "capture" "center" "count" "default"
               "dformat" "dictsort" "e" "escape" "filesizeformat" "first"
               "float" "format" "getattribute" "getitem" "groupby" "indent"
               "int" "join" "jsonencode" "last" "length" "lower" "markdown"
               "pprint" "random" "replace" "reverse" "round" "rst" "slice"
               "sort" "string" "striptags" "sum" "textile" "title" "trim"
               "truncate" "upper" "urlencode" "urlize" "wordcount" "wordwrap"
               "xmlattr")))
         (list 1 font-lock-builtin-face))
   )
   "Minimal highlighting expressions for Jinja mode")

(define-derived-mode jinja-mode nil "Jinja"
  "Simple Jinja mode for use with `mumamo-mode'.
This mode only provides syntax highlighting."
  ;;(set (make-local-variable 'comment-start) "{#")
  ;;(set (make-local-variable 'comment-end)   "#}")
  (setq font-lock-defaults '(jinja-font-lock-keywords)))

;;; YAML chunks
(defun mumamo-chunk-yaml (pos min max)
  "Find yaml header.  Return range and 'yaml-mode.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-quick-static-chunk pos min max "---\n" "---\n" t 'yaml-mode t))

;;; markdown chunks
(defun mumamo-chunk-markdown (pos min max)
  "Find markdown blocks.  Return range and 'yaml-mode.
See `mumamo-find-possible-chunk' for POS, MIN and MAX."
  (mumamo-quick-static-chunk pos min max "\{\#md\#\}\n" "\{\#/md\#\}\n" t 'markdown-mode t))

;; mumamo stuff
(when (require 'mumamo nil t)

  (defun mumamo-chunk-jinja3 (pos min max)
    "Find {# ... #}"
    (mumamo-quick-chunk-forward pos min max "{#" "#}" nil 'jinja-mode 'borders))

  (defun mumamo-chunk-jinja2 (pos min max)
    "Find {{ ... }}"
    (mumamo-quick-chunk-forward pos min max "{{" "}}" nil 'jinja-mode 'borders))

  (defun mumamo-chunk-jinja (pos min max)
    "Find {% ... %}"
    (mumamo-quick-chunk-forward pos min max "{%" "%}" nil 'jinja-mode 'borders))

;;;###autoload
  (define-mumamo-multi-major-mode hyde-jinja-html-mumamo
    "Turn on multiple major modes for hyde with main mode `html-mode'.
This also covers inlined style and javascript."
    ("Hyde/Jinja HTML Family" nxml-mode
     (mumamo-chunk-jinja
      mumamo-chunk-jinja2
      mumamo-chunk-jinja3
      mumamo-chunk-inlined-style
      mumamo-chunk-inlined-script
      mumamo-chunk-style=
      mumamo-chunk-onjs=
      mumamo-chunk-markdown
      mumamo-chunk-yaml
      )))

(provide 'hyde-mumamo))
