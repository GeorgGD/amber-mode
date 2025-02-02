;;; amber-mode.el --- A major mode for the Amber programming language -*- lexical-binding: t -*-

;; Author: Pawel Karas <pawel.karas@icloud.com>

;; Maintainer: Georgios Davakos (GeorgGD) <georgios_davakos@hotmail.com>
;; URL: https://github.com/GeorgGD/amber-mode
;; Version: 0.0.1
;; Package-Requires: ((emacs "26.1"))
;; Keywords: amber, languages

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; A major mode for the Amber programming languages.

;; See documentation on https://github.com/GeorgGD/amber-mode

;;; Code:

;; TODO: Define mode keys for build/compiling amber to bash-scripts
;; TODO: Define mode keys for running amber code in a separate buffer
;; TODO: Turn amber-mode into a linter

(defvar amber-mode-hook nil)

(add-to-list 'auto-mode-alist '("\\.ab\\'" . amber-mode))

(defun amber-re-word (inner)
  (concat "\\<" inner "\\>"))

(defun amber-re-grab (inner)
  (concat "\\(" inner "\\)"))

(defconst amber-re-identifier "[[:word:]_][[:word:]_[:digit:]]*")

(defun amber-re-definition (dtype)
  (concat (amber-re-word dtype) "[[:space:]]+" (amber-re-grab amber-re-identifier)))

(defun amber-re-variable (dtype)
  (concat (amber-re-word dtype) "[[:space:]]+" "\\<\\(\\sw+\\)[[:space:]]+ ?="))

(defvar amber-font-lock-keywords
  (append
   `(
     (,(rx symbol-start
           (|
            ;; Keyworks
            "fun" "let" "return" "const" "ref" "pub" "import" "from" "main" "as"

            ;; Conditional
            "if" "else" "and" "not" "then"

            ;; Commands
            "fail" "failed" "trust" "silent"

            ;; Loops
            "loop" "for" "in" "break" "continue"

            ;; Builtins
            "echo" "cd" "len" "lines" "mv" "nameof")
           symbol-end)
      . font-lock-keyword-face)
     (,(rx symbol-start
           (|
            "true" "false" "null")
           symbol-end)
      . font-lock-constant-face)
     (,(rx symbol-start
           (|
            ;; Data types
            "Text" "Num" "Bool" "Null")
           symbol-end)
      . font-lock-type-face))

   ;; Definitions
   (mapcar (lambda (x)
             (list (amber-re-variable (car x))
                   1  'font-lock-variable-name-face))
           '(("const" . font-lock-variable-name-face)
             ("let" . font-lock-variable-name-face)))

   (mapcar (lambda (x)
             (list (amber-re-definition (car x))
                   1 'font-lock-function-name-face))
           '(("fun" . font-lock-function-name-face)))
   ))

(defun amber-indent-line ()
  "Indent current line."
  (interactive)
  (let ((savep (> (current-column) (current-indentation)))
        (indent (condition-case nil (max (amber-calculate-indentation) 0)
                  (error 0))))
    (if savep
        (save-excursion (indent-line-to indent))
      (indent-line-to indent))))

(defun amber-calculate-indentation ()
  "Return the column to which the current line should be indented."
  (* tab-width (min (car (syntax-ppss (line-beginning-position)))
                    (car (syntax-ppss (line-end-position))))))

(define-derived-mode amber-mode prog-mode "Amber"
  "A major mode for the Amber programming language."
  (setq-local comment-start "// ")
  (setq-local comment-start-skip "//+ *")
  (setq-local comment-end "")
  (setq buffer-file-coding-system 'utf-8-unix) ;; might be redundent
  (setq font-lock-defaults '(amber-font-lock-keywords))
  (setq-local indent-line-function 'amber-indent-line)
  (setq-local tab-width 4)
  (setq-local indent-tabs-mode t))

(provide 'amber-mode)

;;; amber-mode.el ends here
