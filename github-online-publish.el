;;; GITHUB-ONLINE-PUBLISH --- Minimal emacs installation to build the website -*- lexical-binding: t -*-
;;
;; Author: c <c@MacBook-Pro.local>
;; Copyright © 2022, c, all rights reserved.
;; Created:  1 July 2022
;;
;;; Commentary:
;;
;; - Requires NOTES_BASE_ORG_SOURCE environment variable
;;
;;; Code:

(require 'subr-x)

(toggle-debug-on-error)      ;; Show debug informaton as soon as error occurs.

(setq make-backup-files nil) ;; Disable "<file>~" backups.

(defconst notes-org-files
  (let* ((env-key "NOTES_ORG_SRC")
         (env-value (getenv env-key)))
    (if (and env-value (file-directory-p env-value))
        env-value
      (error (format "%s is not set or is not an existing directory (%s)" env-key env-value)))))

;; Setup packages using straight.el: https://github.com/raxod502/straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(setq straight-use-package-by-default t)
(straight-use-package 'use-package)

(require 'font-lock)

(use-package backtrace)

(use-package s
  :straight
  (:type git
   :host github
   :repo "magnars/s.el"))

(use-package dash
  :straight
  (:type git
   :host github
   :repo "magnars/dash.el"))

(use-package f
  :straight
  (:type git
   :host github
   :repo "rejeep/f.el"))

(use-package find-lisp)

(use-package org
  :straight
  (:type git
   :host github
   :repo "bzg/org-mode"))

(use-package ox-publish
  :straight
  (:type git
   :host github
   :repo "bzg/org-mode"))

(use-package ox-html
  :straight
  (:type git
   :host github
   :repo "bzg/org-mode"))

(use-package htmlize
  :straight
  (:type git
   :host github
   :repo "hniksic/emacs-htmlize"))

(use-package emacsql
  :straight
  (:type git
   :host github
   :repo "skeeto/emacsql"))

(use-package emacsql-sqlite
  :straight
  (:type git
   :host github
   :repo "skeeto/emacsql"))

(use-package org-roam
  :straight
  (:type git
   :host github
   :repo "org-roam/org-roam"))

(use-package org-roam-db
  :straight
  (:type git
   :host github
   :repo "org-roam/org-roam"))

(use-package ox-hugo
  :straight
  (
   :type git
   :host github
   :repo "kaushalmodi/ox-hugo"))

(use-package magit-section
  :straight
  (:type git
   :host github
   :repo "magit/magit"))

(use-package tomelr
  :straight
  (:type git
   :host github
   :repo "kaushalmodi/tomelr"))

(use-package org-transclusion
  :straight
  (:type git
   :host github
   :repo "nobiot/org-transclusion")
  :config
  (setq org-transclusion-include-first-section t)
  (setq org-transclusion-exclude-elements '(property-drawer org-drawer))

  (defun hurricane//org-transclusion-add-org-id (link plist)
    "Return a list for Org-ID LINK object and PLIST.
Return nil if not found."
    (when (string= "id" (org-element-property :type link))
      ;; when type is id, the value of path is the id
      (let* ((id (org-element-property :path link))
             (mkr (ignore-errors (org-id-find id t)))
             (payload '(:tc-type "org-id"))
             (content (org-transclusion-content-org-marker mkr plist))
             (footnote-content))
        (if mkr
            (progn
              (let* ((footnote-label-list
                      (with-temp-buffer
                        (insert (plist-get (org-transclusion-content-org-marker mkr plist) :src-content))
                        (org-element-map (org-element-parse-buffer) 'footnote-reference
                          (lambda (reference)
                            (org-element-property :label reference))))))
                (if (and mkr (marker-buffer mkr) (buffer-live-p (marker-buffer mkr)) footnote-label-list)
                    (with-temp-buffer
                      (insert-buffer (marker-buffer mkr))
                      (-map (lambda (label)
                              (setq footnote-content
                                    (concat footnote-content (buffer-substring-no-properties
                                                              (nth 1 (org-footnote-get-definition label))
                                                              (nth 2 (org-footnote-get-definition label))))))
                            footnote-label-list)
                      ))
                (message "%s" footnote-content)
                (setq content (plist-put content ':src-content (concat (plist-get content :src-content) "\n" footnote-content)))
                )
              (append payload content)
              )
          (message
           (format "No transclusion done for this ID. Ensure it works at point %d, line %d"
                   (point) (org-current-line)))
          nil))))

  (push 'hurricane//org-transclusion-add-org-id org-transclusion-add-functions))

(setq org-confirm-babel-evaluate nil)
(setq org-hugo-export-with-toc t)
(setq org-hugo-base-dir
      (let* ((env-key "HUGO_BASE_DIR")
             (env-value (getenv env-key)))
        (if (and env-value (file-directory-p env-value))
            env-value
          (error (format "%s is not set or is not an existing directory (%s)" env-key env-value)))))
(setq org-hugo-section "posts")
(setq org-roam-directory (concat notes-org-files "/"))
(setq org-roam-db-location (concat notes-org-files "/" "org-roam.db"))
(setq org-id-extra-files (find-lisp-find-files org-roam-directory "\.org$"))

(org-roam-db-sync)

(org-link-set-parameters
 "x-devonthink-item"
 :export (lambda (path desc backend)
           (cond
            ((eq 'md backend)
             (format "<font color=\"red\"> <a href=\"x-devonthink-item:%s\">%s </a> </font>"
                     path
                     desc)))))

(defun hurricane//org-video-link-export (path desc backend)
  (let ((ext (file-name-extension path)))
    (cond
     ((eq 'md backend)
      (format "<video preload='metadata' controls='controls'><source type='video/%s' src='%s' /></video>" ext path))
     ;; fall-through case for everything else.
     (t
      path))))

(org-link-set-parameters "video" :export 'hurricane//org-video-link-export)

(defun hurricane//collect-backlinks-string (backend)
  (when (org-roam-node-at-point)
    (let* ((source-node (org-roam-node-at-point))
           (source-file (org-roam-node-file source-node))
           (nodes-in-file (--filter (s-equals? (org-roam-node-file it) source-file)
                                    (org-roam-node-list)))
           (nodes-start-position (-map 'org-roam-node-point nodes-in-file))
           ;; Nodes don't store the last position, so get the next headline position
           ;; and subtract one character (or, if no next headline, get point-max)
           (nodes-end-position (-map (lambda (nodes-start-position)
                                       (goto-char nodes-start-position)
                                       (if (org-before-first-heading-p) ;; file node
                                           (point-max)
                                         (call-interactively
                                          'org-forward-heading-same-level)
                                         (if (> (point) nodes-start-position)
                                             (- (point) 1) ;; successfully found next
                                           (point-max)))) ;; there was no next
                                     nodes-start-position))
           ;; sort in order of decreasing end position
           (nodes-in-file-sorted (->> (-zip nodes-in-file nodes-end-position)
                                      (--sort (> (cdr it) (cdr other))))))
      (dolist (node-and-end nodes-in-file-sorted)
        (-when-let* (((node . end-position) node-and-end)
                     (backlinks (--filter (and (> (org-roam-node-level node) 0)
                                               (->> (org-roam-backlink-source-node it)
                                                    (org-roam-node-file)
                                                    (s-contains? "private/") (not)))
                                          (org-roam-backlinks-get node)))
                     (heading (format "\n\n%s Backlinks\n"
                                      (s-repeat (+ (org-roam-node-level node) 1) "*")))
                     (details-tag-heading "#+BEGIN_EXPORT html\n<details>\n  <summary>Click to expand!</summary>\n\n<blockquote>\n#+END_EXPORT
")
                     (details-tag-ending "#+BEGIN_EXPORT html\n  </blockquote>\n</details>\n\n#+END_EXPORT")
                     (reference-and-footnote-string-list
                      (-map (lambda (backlink)
                              (let* ((source-node (org-roam-backlink-source-node backlink))
                                     (source-file (org-roam-node-file source-node))
                                     (properties (org-roam-backlink-properties backlink))
                                     (outline (when-let ((outline (plist-get properties :outline)))
                                                (when (> (length outline) 1)
                                                  (mapconcat #'org-link-display-format outline " > "))))
                                     (point (org-roam-backlink-point backlink))
                                     (text (s-replace "\n" " " (org-roam-preview-get-contents
                                                                source-file
                                                                point)))
                                     (reference (format "%s [[id:%s][%s]]\n%s\n%s\n\n"
                                                        (s-repeat (+ (org-roam-node-level node) 2) "*")
                                                        (org-roam-node-id source-node)
                                                        (org-roam-node-title source-node)
                                                        (if outline (format "%s (/%s/)"
                                                                            (s-repeat (+ (org-roam-node-level node) 3) "*") outline) "")
                                                        text))
                                     (label-list (with-temp-buffer
                                                   (insert-file-contents source-file)
                                                   (org-element-map (org-element-parse-buffer) 'footnote-reference
                                                     (lambda (reference)
                                                       (org-element-property :label reference)))))
                                     (footnote-list
                                      (with-temp-buffer
                                        (insert-file-contents source-file)
                                        (-map (lambda (label) (buffer-substring-no-properties
                                                               (nth 1 (org-footnote-get-definition label))
                                                               (nth 2 (org-footnote-get-definition label))))
                                              label-list)))
                                     (footnote-string-list (string-join footnote-list "\n"))
                                     (reference-and-footnote-string (format "%s\n%s" reference footnote-string-list)))
                                reference-and-footnote-string)
                              ) backlinks)))
          (goto-char end-position)
          (insert (format "%s\n%s\n%s\n%s" heading details-tag-heading (string-join reference-and-footnote-string-list "\n")  details-tag-ending)))))))

(add-hook 'org-export-before-processing-hook 'hurricane//collect-backlinks-string)
(add-hook 'org-export-before-processing-hook 'org-transclusion-add-all)
(add-hook 'org-export-before-processing-hook 'org-transclusion-inhibit-read-only)

(defun hurricane//org-html-wrap-blocks-in-code (src backend info)
  "Wrap a source block in <pre><code class=\"lang\">.</code></pre>"
  (when (org-export-derived-backend-p backend 'md)
    (replace-regexp-in-string
     "\\(</pre>\\)" "</code>\n\\1"
     (replace-regexp-in-string "<pre class=\"src src-\\([^\"]*?\\)\">"
                               "<pre>\n<code class=\"\\1\">\n" src))))

(with-eval-after-load 'ox-html
  (add-to-list 'org-export-filter-src-block-functions
               'hurricane//org-html-wrap-blocks-in-code))

(defun batch-export-org-files-to-md (dir)
  "Export all org files in directory DIR to markdown."
  (let ((files (directory-files-recursively dir "\\`[^.#].*\\.org\\'")))
    (dolist (file files)
      (with-current-buffer (find-file-noselect file)
        (let ((org-id-extra-files (find-lisp-find-files org-roam-directory "\.org$")))
          (org-transclusion-mode)
          (org-transclusion-add-all)
          (org-hugo-export-wim-to-md t))))))

(defun hurricane/publish ()
  (batch-export-org-files-to-md org-roam-directory))

(provide 'hurricane/publish)
;;; github-online-publish.el ends here
