;; CAUTION: FROM NOW, ALL OF PACKAGE EMACS ELPA WILL BE INSTALLED ON
;; ~/.emacs.d/.cask/
;; =================================================================
(setenv "MY_WORKSPACE" "arch")
(setenv "MONITOR_SIZE" "SMALL")
(setenv "EMACS_ROOT" "~/.emacs.d/")
(setq emacs-root (getenv "EMACS_ROOT"))
(setq bookmark-default-file  "~/.emacs.d/bookmarks-archlinux")
(defvar data-root "~/.emacs.d/data-root/"
      "My data directory - the root of my dataspace.")
;; ===============================================================================================================================
;; Init Preprocessing. Get from Hajime "init_preprocessing.el"
;; ============================================================
;; emacs lisp listing files with glob expansion
;; http://stackoverflow.com/questions/3515152/emacs-lisp-listing-files-with-glob-expansion
(require 'em-glob)
(defun directory-files-glob (path)
   (directory-files (file-name-directory path) nil (eshell-glob-regexp (file-name-nondirectory path))))

(setq path-cask (concat emacs-root (format ".cask/%s/elpa/" emacs-version)))

;; =================================================================
(setq path-use-package (concat path-cask (nth 0 (directory-files-glob (concat path-cask "use-package-[0-9]*")))))
(setq path-bind-key (concat path-cask (nth 0 (directory-files-glob (concat path-cask "bind-key-[0-9]*")))))
(add-to-list 'load-path path-use-package)
(add-to-list 'load-path path-bind-key)
(require 'use-package)
(require 'bind-key)

;; =================================================================
;; Package management: Pallet
(setq path-cask-lib (concat path-cask (nth 0 (directory-files-glob (concat path-cask "cask-[0-9]*")))))
(require 'cask (concat path-cask-lib "/cask.el"))
(cask-initialize)
(require 'pallet)
;; =================================================================================================================================
;; Init Helm, Get from Hajime "init_helm.el"
;; ==================================================================
;; prepare the load path for helm, helm-swoop
(setq path-helm (concat path-cask (nth 0 (directory-files-glob (concat path-cask "helm-[0-9]*")))))
(setq path-helm-swoop (concat path-cask (nth 0 (directory-files-glob (concat path-cask "helm-swoop-[0-9]*")))))
(setq path-helm-projectile (concat path-cask (nth 0 (directory-files-glob (concat path-cask "helm-projectile-[0-9]*")))))
(setq path-helm-w32-launcher (concat path-cask (nth 0 (directory-files-glob (concat path-cask "helm-w32-launcher-[0-9]*")))))

(add-to-list 'load-path path-helm)
(add-to-list 'load-path path-helm-swoop)
(add-to-list 'load-path path-helm-projectile)
(add-to-list 'load-path path-helm-w32-launcher)

;; =================================================================
;; helm-swoop: List match lines to another buffer, which is able to
;; squeeze by any words you input. At the same time, the original
;; buffer's cursor is jumping line to line according to moving up and
;; down the line list.
;; helm from https://github.com/emacs-helm/helm
(use-package helm
  :ensure t
  :bind (("C-x C-m"  .  helm-M-x)    ;; Steve Yegge - Invoke M-x without the Alt key
         ("C-c C-m"  .  helm-M-x)
         ;; some keybindings for helm-mode
         ;; http://emacs.stackexchange.com/questions/2867/how-should-i-change-my-workflow-when-moving-from-ido-to-helm
         ("M-t"      .  helm-recentf)
         ("M-y"      .  helm-do-grep)
         ("M-o"      .  helm-find)
         ("M-,"      .  helm-org-headlines)
         ("M-."      .  helm-yas-complete)
         ("C-M-y"    .  helm-show-kill-ring)
         ("C-M-t"    .  helm-bm)
         ("C-M-i"    .  helm-register)
         ("C-M-g"    .  helm-bookmarks)
         ("C-M-l"    .  fgd)
         ("C-x C-f"  .  helm-find-files)
         ("C-x b"    .  helm-mini)
         ("C-x C-b"  .  helm-buffers-list)
         ("C-x r l"  .  helm-filtered-bookmarks)
         ("C-h SPC"  .  helm-all-mark-rings)
         ("C-x c"    .  helm-semantic-or-imenu)
         ("C-x x"    .  helm-resume)
         ("C-h a"    .  helm-apropos)
         ("C-h i"    .  helm-info-emacs)
         ("C-h b"    .  helm-descbinds))
  :init
  (progn
    ;; A Package in a league of its own: Helm - http://tuhdo.github.io/helm-intro.html
    (require 'helm-config)

    ;; The default "C-x c" is quite close to "C-x C-c", which quits Emacs.
    ;; Changed to "C-c h". Note: We must set "C-c h" globally, because we
    ;; cannot change `helm-command-prefix-key' once `helm-config' is loaded.
    (global-set-key (kbd "C-c h") 'helm-command-prefix)
    (global-unset-key (kbd "C-x c"))

    (setq helm-split-window-in-side-p           t ; open helm buffer inside current window, not occupy whole other window
          helm-buffers-fuzzy-matching           t ; fuzzy matching buffer names when non--nil
          helm-move-to-line-cycle-in-source     t ; move to end or beginning of source when reaching top or bottom of source.
          helm-ff-search-library-in-sexp        t ; search for library in `require' and `declare-function' sexp.
          helm-scroll-amount                    8 ; scroll 8 lines other window using M-<next>/M-<prior>
          helm-ff-file-name-history-use-recentf t)

    ;; http://amitp.blogspot.com/2012/10/emacs-helm-for-finding-files.html
    (setq helm-idle-delay 0.1)
    (setq helm-input-idle-delay 0.1)

    (defun hajime-helm-action (action)
      "TKT's note: A bridge to activate helm-mode support actions."
      (interactive)
      (setq helm-saved-action action)
      (helm-maybe-exit-minibuffer))

    ;; some maximum parameters
    (setq helm-ff-history-max-length 1000)
    (setq helm-candidate-number-limit nil)
    (setq helm-multi-swoop-candidate-number-limit 1000)

    ;; initialize helm
    (helm-mode 1))
  :config
  (progn
    (define-key helm-map (kbd "M-r") (lambda() (interactive) (hajime-helm-action 'helm-open-dired)))
    (define-key helm-map (kbd "C-o") (lambda() (interactive) (hajime-helm-action 'helm-open-file-with-default-tool)))
    (define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action) ; rebind tab to run persistent action
    (define-key helm-map (kbd "C-i") 'helm-execute-persistent-action) ; make TAB works in terminal
    (define-key helm-map (kbd "C-z")  'helm-select-action) ; list actions using C-z
    (define-key helm-map (kbd "C-w")  'backward-kill-word)
    (set-face-attribute 'helm-selection nil :background "DarkSeaGreen2" :foreground "black" :weight 'bold)))


(eval-after-load 'helm-files
  '(progn
     (define-key helm-find-files-map (kbd "M-r") (lambda() (interactive) (hajime-helm-action 'helm-open-dired)))
     (define-key helm-find-files-map (kbd "C-o") (lambda() (interactive) (hajime-helm-action 'helm-open-file-with-default-tool)))))

;; Turn off ido mode in case I enabled it accidentally
(ido-mode -1)

;; =================================================================
(use-package wgrep-helm
  :ensure t
  :defer t)


(use-package helm-swoop
  :bind (("M-I"      .  helm-swoop-back-to-last-point)
         ;;(global-set-key (kbd "M-i") 'helm-swoop)
         ("C-c M-i"  .  helm-multi-swoop)
         ("M-i"      .  helm-multi-swoop-all))
  :ensure t
  :defer t
  :config
  (progn
    ;; https://github.com/mhayashi1120/Emacs-wgrep
    (require 'wgrep)

    ;; Save buffer when helm-multi-swoop-edit complete
    (setq helm-multi-swoop-edit-save t)
    ;; If this value is t, split window inside the current window
    (setq helm-swoop-split-with-multiple-windows nil)
    ;; Split direcion. 'split-window-vertically or 'split-window-horizontally
    (setq helm-swoop-split-direction 'split-window-vertically)
    ;; If nil, you can slightly boost invoke speed in exchange for text color
    (setq helm-swoop-speed-or-color nil)

    ;; From helm-swoop to helm-multi-swoop-all
    (define-key helm-swoop-map (kbd "M-i") 'helm-multi-swoop-all-from-helm-swoop)
    ;; When doing isearch, hand the word over to helm-swoop
    (define-key isearch-mode-map (kbd "M-i") 'helm-swoop-from-isearch)))


;; Lisp-mode keybinding
(define-key lisp-mode-map (kbd "C-M-i") 'helm-register)
(define-key emacs-lisp-mode-map (kbd "C-M-i") 'helm-register)

;; =================================================================
;; helm-w32-launcher
(use-package helm-w32-launcher
  :bind (("M-h"  .  helm-w32-launcher))
  :ensure t
  :defer t)

;; ===================================================================================================================================
;; Init Postprocessing, Get from Hajime "init_postprocessing.el"
;; =================================================================
;; Bookmark configuration
;; http://emacs-fu.blogspot.com/2009/11/bookmarks.html
;; http://ergoemacs.org/emacs/bookmark.html
(setq bookmark-save-flag 1)
(bookmark-load bookmark-default-file t)

;; ==============================================================
;; Create a scratch buffer if it doesn't exist
;; Ref:
;;   http://stackoverflow.com/questions/234963/re-open-scratch-buffer-in-emacs

(defun hajime-create-scratch-buffer ()
   "create a scratch buffer"
   (interactive)
   (if (not (buffer-live-p (get-buffer hajime-scratch-bar)))
       (get-buffer-create hajime-scratch-bar))
   (if (not (buffer-live-p (get-buffer hajime-scratch-buh)))
       (get-buffer-create hajime-scratch-buh))
   (if (buffer-live-p (get-buffer hajime-scratch-buffer))
       (kill-buffer hajime-scratch-buffer))
   (if (not (buffer-live-p (get-buffer hajime-scratch-foo)))
       (progn
         (switch-to-buffer (get-buffer-create hajime-scratch-foo))
         (lisp-interaction-mode))))

;; ==============================================================
(defvar is-hajime-startup nil
  "Indicate if the hajime-startup process has been activated or not.")

(defun hajime-startup ()
  "Doing some customization at startup time."
  (interactive)
  (unless is-hajime-startup
    (setq is-hajime-startup t)
    (hajime-elscreen)
    (hajime-create-scratch-buffer)))

;; =================================================================
;; at Emacs Frame Startup, run 'hajime-startup to open multiple
;; workspace of elscreen.
(add-hook 'window-setup-hook 'hajime-startup t)

;; =================================================================
;; Customize some existing major modes (such as: sql-mode/java-mode):
;; don't let it automatically add (whitespace-cleanup t) to local
;; variable `before-save-hook` which automatically trim the whitespace
;; and causes git diff issue:
;; "please stop committing source code with arbitrary whitespaces spread around"
;;
(add-hook 'sql-mode-hook
          (lambda() (remove-hook 'before-save-hook 'whitespace-cleanup t)))

(add-hook 'java-mode-hook
          (lambda() (remove-hook 'before-save-hook 'whitespace-cleanup t)))

(add-hook 'ruby-mode-hook
          (lambda() (remove-hook 'before-save-hook 'whitespace-cleanup t)))

(add-hook 'ruby-mode-hook (lambda () (setq require-final-newline nil)))

;; =================================================================
;; enable semantic-mode to use helm-semantic-or-imenu
;; http://tuhdo.github.io/helm-intro.html#sec-9
(semantic-mode 1)

;; =================================================================
;; Bypass the question: "Symbolic link to Git-controlled source file; follow link? (y or n)"
;; when visitng a symbolic file linked to a Control-verison file
;; http://stackoverflow.com/questions/15390178/emacs-and-symbolic-links
(setq vc-follow-symlinks t)

;; =================================================================
;; DeleteSelectionMode
;; http://www.emacswiki.org/emacs/DeleteSelectionMode
(delete-selection-mode 1)

;; =================================================================
;; Get visual indication of an exception instead of the Beep sound
;; http://www.emacswiki.org/emacs/AlarmBell#toc2
(setq visible-bell 1)

;; =================================================================
;; Highlight the current line whenever Emacs is idle more than a
;; certain number of seconds
(hl-line-toggle-when-idle)

;; =================================================================
;; TODO TKT
;; require: uniquify, easymenu

;; =================================================================
;; report the Emacs init time
(add-hook 'after-init-hook '(lambda () (message "TKT Emacs init time: %s" (emacs-init-time))))

;; =================================================================
;; How to maximize my Emacs frame on start-up?
;; http://emacs.stackexchange.com/questions/2999/how-to-maximize-my-emacs-frame-on-start-up
(toggle-frame-maximized)

;; ==================================================================================================================================
;; Init Bookmark, Get from Hajime "init_bm.el"
;; =================================================================
;; A Visual Bookmarks package for Emacs
;; ref
;; - http://emacsworld.blogspot.com/2008/09/visual-bookmarks-package-for-emacs.html

(use-package bm
  :bind (("S-SPC" . bm-toggle)          ;; set bookmark
         ("C-M-," . bm-previous)
         ("C-M-." . bm-next))
  :ensure t
  :defer t
  :commands (bm-buffer-save-all bm-buffer-save bm-buffer-restore bm-toggle)
  :config
  (progn
    (setq bm-highlight-style 'bm-highlight-only-fringe) ;;middle bookmark

    ;; https://github.com/snufkon/emacs_settings/blob/master/dot_emacs/minor/bm-settings.el
    (setq-default bm-buffer-persistence t)  ;; save bookmarks

    ;; Filename to store persistent bookmarks
    (setq bm-repository-file (concat data-root "org/.bm-repository"))

    ;; Loading the repository from file when on start up.
    (add-hook' after-init-hook 'bm-repository-load)

    ;; Restoring bookmarks when on file find.
    (add-hook 'find-file-hooks 'bm-buffer-restore)

    ;; Saving bookmark data on killing and saving a buffer
    (add-hook 'kill-buffer-hook 'bm-buffer-save)
    (add-hook 'auto-save-hook 'bm-buffer-save)
    (add-hook 'after-save-hook 'bm-buffer-save)

    ;; Saving the repository to file when on exit.
    ;; kill-buffer-hook is not called when emacs is killed, so we
    ;; must save all bookmarks first.
    (add-hook 'kill-emacs-hook (lambda nil (bm-buffer-save-all) (bm-repository-save)))))

;; =================================================================


;; ===================================================================================================================================
(package-initialize)
(require 'ace-jump-mode)
(require 'auto-complete)
(require 'ace-isearch)
(require 'highlight-symbol)
(global-ace-isearch-mode +1)
(global-linum-mode 1)

;; ===== Turn on Web mode =====
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))

;; ===== Change background color =====
(add-to-list 'default-frame-alist '(foreground-color . "#E0DFDB"))
(add-to-list 'default-frame-alist '(background-color . "#000000"))

(when (>= emacs-major-version 24)
  (require 'package)
  (add-to-list
   'package-archives
   '("melpa" . "http://melpa.org/packages/")
   t)
  (package-initialize))

;; ====================================================================
;; Emacs key binding
(global-set-key (kbd "C-u") 'kill-whole-line)
(global-set-key (kbd "M-p") 'backward-sentence)
(global-set-key (kbd "M-n") 'forward-sentence)
(global-set-key (kbd "M-a") 'beginning-of-buffer)
(global-set-key (kbd "M-e") 'end-of-buffer)
(global-set-key (kbd "M-l") 'backward-kill-word)
(global-set-key (kbd "C-x c") 'ace-jump-char-mode)
(global-set-key (kbd "<f3>") 'highlight-selected-region)
(global-set-key (kbd "M-<f3>") 'highlight-symbol-remove-all)

;; ====================================================================
;; Highlight feature
(defun highlight-selected-region()
  "Highlight text in selected region and other places."
  (interactive)
  (if (region-active-p)
      (progn
	(highlight-symbol-add-symbol (buffer-substring (region-beginning) (region-end)))
	(keyboard-escape-quit))
    (highlight-symbol-at-point)))



;; ====================================================================
;; Set ace-isearch jump
;; Description: You need to use isearch by C-g, type the word you search
;;              and C-x w your cursor will jump to the word you select
(custom-set-variables
 '(ace-isearch-input-length 7)
 '(ace-isearch-jump-delay 0.3)
 '(ace-isearch-function 'avy-goto-char)
 '(ace-isearch-use-jump 'printing-char))

(define-key isearch-mode-map (kbd "C-x w") 'ace-isearch-jump-during-isearch)

;; ====================================================================
;; Hide toolbar at startup
(tool-bar-mode -1)

;; =================================================================
;; keeping related buffers together with elscreen
;; Ref:
;;   http://emacs-fu.blogspot.com/2009/07/keeping-related-buffers-together-with.html

(load "elscreen" "ElScreen" )

;; Windowskey+F9 creates a new elscreen, Windowskey+F10 kills it
(global-set-key (kbd "<M-f9>"    ) 'elscreen-create)
(global-set-key (kbd "<M-f10>"  ) 'elscreen-kill)


;; Windowskey+PgUP/PgDown switches between elscreens
(global-set-key (kbd "<s-prior>") 'elscreen-previous)
(global-set-key (kbd "<s-next>")  'elscreen-next)
(global-set-key (kbd "M-0")  '(lambda() (interactive) (hajime-startup)))

(defvar is-hajime-startup nil
  "Indicate if the hajime-startup process has been activated or not.")

(defun hajime-startup ()
  "Doing some customization at startup time."
  (interactive)
  (unless is-hajime-startup
    (setq is-hajime-startup t)
    (hajime-elscreen))
  )

;; ;; startup settings
(defun hajime-elscreen ()
  (interactive)
  (elscreen-start)
  (elscreen-create)
  (elscreen-screen-nickname "box")
  (elscreen-create)
  (elscreen-screen-nickname "box")
  (elscreen-create)
  (elscreen-screen-nickname "box")
  (elscreen-create)
  (elscreen-screen-nickname "box")
  (elscreen-create)
  (elscreen-screen-nickname "box")
  (elscreen-create)
  (elscreen-screen-nickname "box")
  (elscreen-create)
  (elscreen-screen-nickname "shell")
  (elscreen-create)
  (elscreen-screen-nickname "reserved")
  (elscreen-create)
  (elscreen-screen-nickname "reserved")

  (elscreen-goto 0)
  (elscreen-kill)

  ;; keybinding for switching workspaces
  (global-set-key "\M-1" '(lambda () (interactive) (elscreen-goto 1)))
  (global-set-key "\M-2" '(lambda () (interactive) (elscreen-goto 2)))
  (global-set-key "\M-3" '(lambda () (interactive) (elscreen-goto 3)))
  (global-set-key "\M-4" '(lambda () (interactive) (elscreen-goto 4)))
  (global-set-key "\M-5" '(lambda () (interactive) (elscreen-goto 5)))
  (global-set-key "\M-6" '(lambda () (interactive) (elscreen-goto 6)))
  (global-set-key "\M-7" '(lambda () (interactive) (elscreen-goto 7)))
  (global-set-key "\M-8" '(lambda () (interactive) (elscreen-goto 8)))
  (global-set-key "\M-9" '(lambda () (interactive) (elscreen-goto 9)))

  ;; keybinding for moving a buffer to a specific workspace
  (global-set-key (kbd "<M-S-f1>") '(lambda () (interactive) (hajime-move-buffer-to-elscreen 1)))
  (global-set-key (kbd "<M-S-f2>") '(lambda () (interactive) (hajime-move-buffer-to-elscreen 2)))
  (global-set-key (kbd "<M-S-f3>") '(lambda () (interactive) (hajime-move-buffer-to-elscreen 3)))
  (global-set-key (kbd "<M-S-f4>") '(lambda () (interactive) (hajime-move-buffer-to-elscreen 4)))
  (global-set-key (kbd "<M-S-f5>") '(lambda () (interactive) (hajime-move-buffer-to-elscreen 5)))
  (global-set-key (kbd "<M-S-f6>") '(lambda () (interactive) (hajime-move-buffer-to-elscreen 6)))
  (global-set-key (kbd "<M-S-f7>") '(lambda () (interactive) (hajime-move-buffer-to-elscreen 7)))
  (global-set-key (kbd "<M-S-f8>") '(lambda () (interactive) (hajime-move-buffer-to-elscreen 8)))
  (global-set-key (kbd "<M-S-f9>") '(lambda () (interactive) (hajime-move-buffer-to-elscreen 9)))
)

;; =================================================================
;; insert separator line in the form of comment in respect to 'major-mode
(setq hajime-var-separator-char-number 65)

(defun hajime-char-multiply (char numberOfChars)
  (cond ((<= numberOfChars 0) "")
	((= numberOfChars 1) char)
	((> numberOfChars 1)
	 (let ((tmp-s (hajime-char-multiply char (/ numberOfChars 2))))
	   (if (oddp numberOfChars) (concat char tmp-s tmp-s)
	     (concat tmp-s tmp-s))))))

(global-set-key (kbd "M-<f6>")
		'(lambda () (interactive)
		   (let ((comment-char-begin ";; ")
			 (comment-char-end nil))
		     (cond
		      ((or (eq major-mode 'org-mode)
			   (eq major-mode 'python-mode)
			   (eq major-mode 'ruby-mode))
		       (setq comment-char-begin "# "))
		      ((or (eq major-mode 'js-mode)
			   (eq major-mode 'jde-mode)
			   (eq major-mode 'java-mode))
		       (setq comment-char-begin "// "))
		      ((eq major-mode 'sql-mode)
		       (progn
			 (setq comment-char-begin "/* ")
			 (setq comment-char-end " */")
			 ))
		      ((or (eq major-mode 'markdown-mode)
			   (eq major-mode 'html-mode)
			   (eq major-mode 'nxml-mode))
		       (progn
			 (setq comment-char-begin "<!-- ")
			 (setq comment-char-end " -->")))
		      )
		     (insert (concat comment-char-begin
				     (hajime-char-multiply "=" hajime-var-separator-char-number)
				     comment-char-end)))))

;; =================================================================
;; Jump to frequently used files

(global-set-key (kbd "<f8> 0") '(lambda() (interactive) (find-file "~/.emacs")))
(global-set-key (kbd "<f8> 1") '(lambda() (interactive) (find-file "E:\\MRWEN-DATA\\00 STUDY")))
(global-set-key (kbd "<f8> 2") '(lambda() (interactive) (find-file "K:\\repos\\stawell")))
(global-set-key (kbd "<f8> 3") '(lambda() (interactive) (find-file "C:\\Users\\MrKun\\Desktop\\")))

;; =================================================================

;; Install jshint for Nodejs
;;(add-to-list 'load-path "~/jshint-mode")
;;(require 'flymake-jshint)
;;(add-hook 'javascript-mode-hook
;;     (lambda () (flymake-mode t)))

;; Turns on flymake for all files which have a flymake mode
;;(add-hook 'find-file-hook 'flymake-find-file-hook)

;; =================================================================
;; Add auto-complete-mode
(add-to-list 'load-path "~/.emacs.d/elpa/auto-complete-20150618.1949")
; Load the default configuration
(require 'auto-complete-config)
; Make sure we can find the dictionaries
(add-to-list 'ac-dictionary-directories "~/.emacs.d/elpa/auto-complete-20150618.1949/dict")
; Use dictionaries by default
(setq-default ac-sources (add-to-list 'ac-sources 'ac-source-dictionary))
(global-auto-complete-mode t)
; Start auto-completion after 2 characters of a word
(setq ac-auto-start 2)
; case sensitivity is important when finding matches
(setq ac-ignore-case nil)

;; =================================================================
;; install flymake-jslint
(require 'flymake-jslint)
    (add-hook 'js-mode-hook 'flymake-jslint-load)
(add-to-list 'load-path "~/.emacs.d/elpa/flymake-cursor")
;; Nice Flymake minibuffer messages
;;(require 'flymake-cursor)
;;(require 'flymake-easy)
;; =================================================================

;; install jshint
;;(add-to-list 'load-path "~/.emacs.d/GitFile/jshint-mode")
;;(require 'flymake-jshint)
;;(add-hook 'js-mode-hook
;;     (lambda () (flymake-mode t)))

;;(setenv "PATH" (concat "/usr/local/bin:" (getenv "PATH")))
;;	(setq exec-path
;;	      '(
;;		"/usr/local/bin"
;;		"/usr/bin"
;;		))

;; =================================================================

;; install js-comint
;;(require 'js-comint)
;;(setq inferior-js-program-command "/usr/bin/java org.mozilla.javascript.tools.shell.Main")
;;(add-hook 'js2-mode-hook '(lambda () 
;;			    (local-set-key "\C-x\C-e" 'js-send-last-sexp)
;;			    (local-set-key "\C-\M-x" 'js-send-last-sexp-and-go)
;;			    (local-set-key "\C-cb" 'js-send-buffer)
;;			    (local-set-key "\C-c\C-b" 'js-send-buffer-and-go)
;;			    (local-set-key "\C-cl" 'js-load-file-and-go)
;;			    ))

;; =================================================================
;; install emms player
;; Reference Link: http://www.emacswiki.org/emacs/EMMS
;;                 http://wikemacs.org/wiki/Media_player
(add-to-list 'load-path "~/.emacs.d/GitFile/emms/lisp/")
(add-to-list 'load-path "~/.emacs.d/GitFile/mplayer/")
(add-to-list 'exec-path "~/.emacs.d/GitFile/mplayer/")
(require 'emms)
(require 'emms-setup)
        (emms-standard)
        (emms-default-players)
(require 'emms-player-mplayer)
(require 'emms-player-simple)
(require 'emms-source-file)
(require 'emms-source-playlist)
(setq emms-player-list '(emms-player-mpg321 
			 emms-player-ogg123 
			 emms-player-mplayer)
      emms-source-list '((emms-directory-tree "D:/My Music/")))

;; =================================================================
;; install magit
(require 'magit)
(add-to-list 'exec-path "C:/Program Files/Git/cmd/")

;; =================================================================
;; install flymake-html

(defun flymake-html-init ()
       (let* ((temp-file (flymake-init-create-temp-buffer-copy
                          'flymake-create-temp-inplace))
              (local-file (file-relative-name
                           temp-file
                           (file-name-directory buffer-file-name))))
         (list "tidy" (list local-file))))

(defun flymake-html-load ()
  (interactive)
  (when (and (not (null buffer-file-name)) (file-writable-p buffer-file-name))
    (set (make-local-variable 'flymake-allowed-file-name-masks)
         '(("\\.html\\|\\.ctp\\|\\.ftl\\|\\.jsp\\|\\.php\\|\\.erb\\|\\.rhtml" flymake-html-init))
         )
    (set (make-local-variable 'flymake-err-line-patterns)
         ;; only validate missing html tags
         '(("line \\([0-9]+\\) column \\([0-9]+\\) - \\(Warning\\|Error\\): \\(missing <\/[a-z0-9A-Z]+>.*\\|discarding unexpected.*\\)" nil 1 2 4))
         )
    (flymake-mode t)))

(add-hook 'web-mode-hook 'flymake-html-load)
(add-hook 'html-mode-hook 'flymake-html-load)
(add-hook 'nxml-mode-hook 'flymake-html-load)
(add-hook 'php-mode-hook 'flymake-html-load)

;; =================================================================
;; install flymake-jslint
;;(add-to-list 'load-path "~/.emacs.d/GitFile/jslint/")
;;(require 'flymake)
;;(require 'flymake-jslint)
;;(add-hook 'js-mode-hook 'flymake-jslint-load)
;;(add-hook 'javascript-mode-hook
;;          (lambda () (flymake-mode 1)))

;; =================================================================
;; set controlling the buffer
(global-set-key (kbd "C-x p") 'windmove-up)
(global-set-key (kbd "C-x n") 'windmove-down)
(global-set-key (kbd "C-x e") 'windmove-right)
(global-set-key (kbd "C-x a") 'windmove-left)

;; =================================================================
;; set window number. Use: C-x C-j number_of_buffer
(add-to-list 'load-path "~/.emacs.d/GitFile/window-number/")
 (autoload 'window-number-mode "window-number"
   "A global minor mode that enables selection of windows according to
 numbers with the C-x C-j prefix.  Another mode,
 `window-number-meta-mode' enables the use of the M- prefix."
   t)
(window-number-mode 1)  ;; always enable mode

;; =================================================================
;; Resize window buffer
(global-set-key (kbd "<C-up>") 'shrink-window)
(global-set-key (kbd "<C-down>") 'enlarge-window)
(global-set-key (kbd "<C-left>") 'shrink-window-horizontally)
(global-set-key (kbd "<C-right>") 'enlarge-window-horizontally)

;; =================================================================
;; Install NeoTree
(add-to-list 'load-path "~/.emacs.d/GitFile/neotree")
(require 'neotree)
(global-set-key [f7] 'neotree-toggle)

;; =================================================================
;; Install php mode
(require 'php-mode)

;; =================================================================
;; Install Jade-mode
(add-to-list 'load-path "~/.emacs.d/GitFile/jade-mode")
(require 'sws-mode)
(require 'jade-mode)
(add-to-list 'auto-mode-alist '("\\.styl\\'" . sws-mode))

;; =================================================================
;; Set tab indentation
(setq js-indent-level 2) ;; Set 2 spaces indentation for javascript

;; =================================================================
;; Set preserve clipboard content

;; =================================================================
;; Set indent hightlight
(add-to-list 'load-path "~/.emacs.d/elpa/highlight-indents/")
(require 'highlight-indentation)
(set-face-background 'highlight-indentation-face "#021E83")
(set-face-background 'highlight-indentation-current-column-face "#c3b3b3")
(add-hook 'prog-mode-hook #'highlight-indentation-mode) ;; auto enable programming mode

;; =================================================================
;; Turn on highlighting current line
(global-hl-line-mode 1) 
(set-face-background hl-line-face "gray25")

;; =================================================================
;; Matching parenthesis highlighted
(show-paren-mode 1) ; turn on paren match highlighting
(setq show-paren-style 'expression) ; highlight entire bracket expression
(set-face-background 'show-paren-match "#666")

;; =================================================================
;; Set comment, keyword, string color
(set-face-foreground 'font-lock-comment-face "#F541F6")
(set-face-foreground 'font-lock-string-face "#ff9933")
(set-face-foreground 'font-lock-keyword-face "#00ff00")

;; =================================================================
;; Make backup to a designated dir, mirroring the full path
(defun my-backup-file-name (fpath)
  "Return a new file path of a given file path.
If the new path's directories does not exist, create them."
  (let* (
        (backupRootDir "~/.emacs.d/emacs-backup/")
        (filePath (replace-regexp-in-string "[A-Za-z]:" "" fpath )) ; remove Windows driver letter in path, ⁖ “C:”
        (backupFilePath (replace-regexp-in-string "//" "/" (concat backupRootDir filePath "~") ))
        )
    (make-directory (file-name-directory backupFilePath) (file-name-directory backupFilePath))
    backupFilePath
  )
)

(setq make-backup-file-name-function 'my-backup-file-name)
(setq auto-save-default nil) ; stop creating those #autosave# files

;; =================================================================
;; Save/restore opened files
(desktop-save-mode 0)  ;; Enable: 1, Disable: 0

;; =================================================================
;; Set mark color
(set-face-attribute 'region nil :background "#021E83")

;; =================================================================
;; Set for running cygwin in emacs
(defun cygwin-shell ()
  "Run cygwin bash in shell mode."
  (interactive)
  (let ((explicit-shell-file-name "C:/cygwin/bin/bash"))
    (call-interactively 'shell)))
(setq explicit-bash-args '("--login" "-i"))

